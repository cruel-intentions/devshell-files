{pkgs, config, lib, ...}:
let
  # https://skarnet.org/software/execline/index.html
  shBang   = "#!${pkgs.execline}/bin/execlineb -S0";
  errToOut = "fdmove -c 2 1";
  mkS6Run  = name: {
    name  = "/.data/services/${name}/run";
    value.executable = true;
    value.text       = ''
      ${shBang}
      ifthenelse { sh -c "command -v ${name} > /dev/null" } 
      {
        ${errToOut}
        ${name}
      }
      {
        echo "command ${name} not found"
      }
    '';
  };
  mkS6Log  = name: {
    name  = "/.data/services/${name}/log/run";
    value.executable = true;
    value.text       = ''
      ${shBang}
      ifthenelse { sh -c "command -v ${name}-log > /dev/null" } 
      {
        ${errToOut}
        ${name}-log
      }
      {
        importas LOG_DIR PRJ_SRCS_LOG
        ${errToOut}
        s6-log -b n4 s100000 ''${LOG_DIR}/${name}/
      }
    '';
  };
  mkS6Stop = name: {
    name  = "/.data/services/${name}/finish";
    value.executable = true;
    value.text       = ''
      ${shBang}
      ifthenelse { sh -c "command -v ${name}-finish > /dev/null" } 
      {
        ${errToOut}
        ${name}-finish
      }
      {
        echo ${name} finished
      }
    '';
  };
  rmS6Svc  = name: {
    name  = "00-rm-service-${name}-file";
    value.text = "rm -rf $PRJ_SVCS_DIR/${name}";
  };
  mkLogDir = name: {
    name  = "00-add-service-${name}-log-dir";
    value.text = "mkdir -p $PRJ_SVCS_LOG/${name}";
  };
  mkS6Runs = names: builtins.listToAttrs (map mkS6Run  names);
  mkS6Logs = names: builtins.listToAttrs (map mkS6Log  names);
  mkS6Ends = names: builtins.listToAttrs (map mkS6Stop names);
  rmS6Svcs = names: builtins.listToAttrs (map rmS6Svc  names);
  mkS6Dirs = names: builtins.listToAttrs (map mkLogDir names);
  filtSvcs = boole: lib.filterAttrs (n: v: n != "initSvcs" && v == boole);
  liveSvcs = builtins.attrNames (filtSvcs true  config.files.services);
  deadSvcs = builtins.attrNames (filtSvcs false config.files.services);
  initSvcs = ''
    ${shBang}
    # init all services
    background {
      foreground { sleep 1 }
      importas SVCS_DIR PRJ_SVCS_DIR
      importas LOG_DIR  PRJ_SVCS_LOG
      redirfd -w 1 ''${LOG_DIR}/scan.log
      ${errToOut}
      s6-svscan ''${SVCS_DIR}
    }
  '';
  scanSvcs = ''
    ${shBang}
    # rescan all services
    importas SVCS_DIR PRJ_SVCS_DIR
    importas LOG_DIR  PRJ_SVCS_LOG
    redirfd -w 1 ''${LOG_DIR}/sctl.log
    ${errToOut}
    s6-svscanctl -h ''${SVCS_DIR}
  '';
  stopSvcs = ''
    ${shBang}
    # stop all services
    importas SVCS_DIR PRJ_SVCS_DIR
    ${errToOut}
    s6-svscanctl -t ''${SVCS_DIR}
  '';
  stUpSvcs = lib.optionalAttrs haveSvcs { 
    "zzzzzz-ssssss-services-start".text = ''
      # set down all services
      find $PRJ_SVCS_DIR -maxdepth 1 -mindepth 1 -type d -exec touch {}/down \; \
        &>/dev/null || true
      # set up enabled services
      rm $PRJ_SVCS_DIR/{.s6-svscan,${builtins.concatStringsSep "," liveSvcs}}/down \
        &>/dev/null || true
      # rescan services
      scanSvcs ${lib.optionalString autoSvcs "|| initSvcs"}
    '';
  };
  haveSvcs = builtins.length liveSvcs > 0;
  autoSvcs = haveSvcs && config.files.services.initSvcs or false;
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

      Default log informations goes to $PRJ_SVCS_LOG/{name}/current .

      `initSvcs` is a special name to auto start the process supervisor 
      [s6](http://skarnet.org/software/s6/), it control all other services.

      If we don't set initSvcs service, we can start it running `initSvcs`.
 
      S6 wont stop by itself, we should run `stopSvcs` when it's done.

      It defines two env vars:
      - PRJ_SVCS_DIR: $PRJ_DATA_DIR/services
      - PRJ_SVCS_LOG: $PRJ_DATA_DIR/log

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
        files.services.initSvcs = true;

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
  config.files.alias.stopSvcs   = lib.mkIf haveSvcs stopSvcs;
  config.files.alias.initSvcs   = lib.mkIf haveSvcs initSvcs;
  config.files.alias.scanSvcs   = lib.mkIf haveSvcs scanSvcs;
  config.files.alias.svcCtl     = lib.mkIf haveSvcs "s6-svc $2 $PRJ_SVCS_DIR/$1";
  config.files.alias.stopSvc    = lib.mkIf haveSvcs "svcCtl $1 -d";
  config.files.alias.restartSvc = lib.mkIf haveSvcs "svcCtl $1 -r";
  config.files.alias.initSvc    = lib.mkIf haveSvcs "svcCtl $1 -u";
  config.devshell.packages    = lib.mkIf haveSvcs [ pkgs.s6 pkgs.s6-rc pkgs.execline];
  config.devshell.startup     = stUpSvcs // (rmS6Svcs deadSvcs) // (mkS6Dirs liveSvcs);
  config.file = (mkS6Runs liveSvcs) // (mkS6Logs liveSvcs) // (mkS6Ends liveSvcs);
  config.env = lib.optionals haveSvcs [
    { name = "PRJ_SVCS_DIR"; eval = "$PRJ_DATA_DIR/services"; }
    { name = "PRJ_SVCS_LOG"; eval = "$PRJ_DATA_DIR/log"; }
  ];
}
