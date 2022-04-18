{pkgs, config, lib, ...}:
let
  # https://skarnet.org/software/execline/index.html
  shBang   = "#!${pkgs.execline}/bin/execlineb -S0";
  errToOut = "fdmove -c 2 1 # stderr to stdout";
  mkS6Run  = name: {
    name  = "/.data/services/${name}/run";
    value.executable = true;
    value.text       = ''
      ${shBang}
      ${errToOut}
      ${name}
    '';
  };
  mkS6Log  = name: {
    name  = "/.data/services/${name}/log/run";
    value.executable = true;
    value.text       = ''
      ${shBang}
      tryexec -n #try {name}-log or s6-log if name-log fails
        { 
          importas LOG_DIR PRJ_SRVS_LOG
          s6-log -b n4 s100000 ''${LOG_DIR}/${name}/
        }
        ${errToOut} ${name}-log
    '';
  };
  mkS6Stop = name: {
    name  = "/.data/services/${name}/finish";
    value.executable = true;
    value.text       = ''
      ${shBang}
      tryexec #try ${name}-finish or echo finished
        {
          ${errToOut}
          echo ${name} finished
        }
        ${errToOut}
        ${name}-finish
    '';
  };
  rmS6Srv  = name: {
    name  = "00-rm-service-${name}-file";
    value.text = "rm -rf $PRJ_SRVS_DIR/${name}";
  };
  mkLogDir = name: {
    name  = "00-add-service-${name}-log-dir";
    value.text = "mkdir -p $PRJ_SRVS_LOG/${name}";
  };
  mkS6Runs = names: builtins.listToAttrs (map mkS6Run  names);
  mkS6Logs = names: builtins.listToAttrs (map mkS6Log  names);
  mkS6Ends = names: builtins.listToAttrs (map mkS6Stop names);
  rmS6Srvs = names: builtins.listToAttrs (map rmS6Srv  names);
  mkS6Dirs = names: builtins.listToAttrs (map mkLogDir names);
  filtSrvs = boole: lib.filterAttrs (n: v: n != "initSrvs" && v == boole);
  liveSrvs = builtins.attrNames (filtSrvs true  config.files.services);
  deadSrvs = builtins.attrNames (filtSrvs false config.files.services);
  initSrvs = ''
    ${shBang}
    # init all services
    background {
      foreground { sleep 1 }
      importas SRVS_DIR PRJ_SRVS_DIR
      importas LOG_DIR  PRJ_SRVS_LOG
      redirfd -w 1 ''${LOG_DIR}/scan.log
      ${errToOut}
      s6-svscan ''${SRVS_DIR}
    }
  '';
  scanSrvs = ''
    ${shBang}
    # rescan all services
    importas SRVS_DIR PRJ_SRVS_DIR
    importas LOG_DIR  PRJ_SRVS_LOG
    redirfd -w 1 ''${LOG_DIR}/sctl.log
    ${errToOut}
    s6-svscanctl -h ''${SRVS_DIR}
  '';
  stopSrvs = ''
    ${shBang}
    # stop all services
    importas SRVS_DIR PRJ_SRVS_DIR
    ${errToOut}
    s6-svscanctl -t ''${SRVS_DIR}
  '';
  stUpSrvs = lib.optionalAttrs haveSrvs { 
    "zzzzzz-ssssss-services-start".text = ''
      # set down all services
      find $PRJ_SRVS_DIR -maxdepth 1 -mindepth 1 -type d -exec touch {}/down \; \
        &>/dev/null || true
      # set up enabled services
      rm $PRJ_SRVS_DIR/{.s6-svscan,${builtins.concatStringsSep "," liveSrvs}}/down \
        &>/dev/null || true
      # rescan services
      scanSrvs ${lib.optionalString autoSrvs "|| initSrvs"}
    '';
  };
  haveSrvs = builtins.length liveSrvs > 0;
  autoSrvs = haveSrvs && config.files.services.initSrvs or false;
in
{
  options.files.services = lib.mkOption {
    default       = {};
    example.hello = true;
    type          = lib.types.attrsOf lib.types.bool;
    description   = ''
      Service name/command to enable

      {name} must be a executable command that runs forever.

      Optionally could exist a {name}-finish command to stop it properly.

      Optionally could exist a {name}-log    command to log  it properly.

      Default log informations goes to $PRJ_SRVS_LOG/{name}/current .

      `initSrvs` is a special name to auto start the process supervisor 
      [s6](http://skarnet.org/software/s6/), it control all other services.

      If we don't set initSrvs service, we can start it running `initSrvs`.
 
      S6 wont stop by itself, we should run `stopSrvs` when it's done.

      It defines two env vars:
      - PRJ_SRVS_DIR: $PRJ_DATA_DIR/services
      - PRJ_SRVS_LOG: $PRJ_DATA_DIR/log

      See [S6 documentation](http://skarnet.org/software/s6/s6-supervise.html).

      We can use config.files.alias to help create your services scripts.

      examples:

      Use some program as service

      Configure httplz (http static server) as service

      ```nix
      ${builtins.readFile ../examples/services.nix}
      ```

      Create your own service with bash

      ```nix
      {
        # Make all services start when you enter in shell
        files.services.initSrvs = true;

        # Use hello configured below as service
        files.services.hello    = true;

        # Creates an hello command in terminal
        files.alias.hello       = ${"''"}
          while :
          do
            echo "Hello World!"
          	sleep 60
          done
        ${"''"};
      }
       ```


      Know bugs:
      - Integration with direnv isn't, ok when configured to auto start
    '';
  };
  config.files.alias.stopSrvs = lib.mkIf haveSrvs stopSrvs;
  config.files.alias.initSrvs = lib.mkIf haveSrvs initSrvs;
  config.files.alias.scanSrvs = lib.mkIf haveSrvs scanSrvs;
  config.devshell.packages    = lib.mkIf haveSrvs [ pkgs.s6 pkgs.s6-rc pkgs.execline];
  config.devshell.startup     = stUpSrvs // (rmS6Srvs deadSrvs) // (mkS6Dirs liveSrvs);
  config.file = (mkS6Runs liveSrvs) // (mkS6Logs liveSrvs) // (mkS6Ends liveSrvs);
  config.env = lib.optionals haveSrvs [
    { name = "PRJ_SRVS_DIR"; eval = "$PRJ_DATA_DIR/services"; }
    { name = "PRJ_SRVS_LOG"; eval = "$PRJ_DATA_DIR/log"; }
  ];
}
