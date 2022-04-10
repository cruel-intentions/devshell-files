{pkgs, config, lib, ...}:
let
  mkS6Run  = name: {
    name  = "/.data/services/${name}/run";
    value.executable = true;
    value.text       = ''
      #!/usr/bin/env sh
      exec 2>&1
      exec ${name}
    '';
  };
  mkS6Log  = name: {
    name  = "/.data/services/${name}/log/run";
    value.executable = true;
    value.text       = ''
      #!/usr/bin/env sh
      if command -v ${name}-log &> /dev/null
      then
        exec 2>&1
        exec ${name}-log
      else
        exec 2>&1
        exec s6-log -b n4 s100000 $PRJ_DATA_DIR/log/${name}/
      fi
    '';
  };
  mkS6Stop = name: {
    name  = "/.data/services/${name}/finish";
    value.executable = true;
    value.text       = ''
      #!/usr/bin/env sh
      if command -v ${name}-finish &> /dev/null
      then
        exec 2>&1
        exec ${name}-finish
      fi
    '';
  };
  rmS6Srv  = name: {
    name  = "00-rm-service-${name}-file";
    value.text = "rm -rf $PRJ_DATA_DIR/services/${name}";
  };
  mkLogDir = name: {
    name  = "00-add-service-${name}-log-dir";
    value.text = "mkdir -p $PRJ_DATA_DIR/log/${name}";
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
    s6-svscan       $PRJ_DATA_DIR/services &> \
      $PRJ_ROOT/.data/services/scan-errors.log &
  '';
  scanSrvs = ''
    s6-svscanctl -h $PRJ_DATA_DIR/services &> \
      $PRJ_ROOT/.data/services/sctl-errors.log
  '';
  stopSrvs = ''
    s6-svscanctl -t $PRJ_DATA_DIR/services
  '';
  stUpSrvs = lib.optionalAttrs haveSrvs { 
    "zzzzzz-ssssss-start".text = "scanSrvs" + lib.optionalString autoSrvs "|| initSrvs &";
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

      Default log informations goes to $PRJ_DATA_DIR/log/{name}/current .

      `initSrvs` is a special name to auto start the process supervisor 
      [s6](http://skarnet.org/software/s6/), it control all other services.

      If we don't set initSrvs service, we can start it running `initSrvs`.
 
      S6 wont stop by itself, we should run `stopSrvs` when it's done.

      See [S6 documentation](http://skarnet.org/software/s6/s6-supervise.html).

      We can use config.files.alias to help create your services scripts.

      examples:

      Create your own service with bash

      ```nix
      {
        # Make all services start when you enter in shell
        files.services.initSrvs    = true;

        # Use hello configured below as service
        files.services.hello = true;

        # Creates an hello command in terminal
        files.alias.hello    = ${"''"}
          while :
          do
            echo "Hello World!"
          	sleep 60
          done
        ${"''"};
      }
       ```

      Use some program as service

      Configure httplz (http static server) as service

      ```nix
      ${builtins.readFile ../examples/services.nix}
      ```

      Know bugs:

      - Turning off service by removing its entry may not work
        - please set it to false at least once
        - or remove all .data/services directory
    '';
  };
  config.files.alias.stopSrvs = lib.mkIf haveSrvs stopSrvs;
  config.files.alias.initSrvs = lib.mkIf haveSrvs initSrvs;
  config.files.alias.scanSrvs = lib.mkIf haveSrvs scanSrvs;
  config.devshell.packages    = lib.mkIf haveSrvs [ pkgs.s6 ];
  config.devshell.startup     = stUpSrvs // (rmS6Srvs deadSrvs) // (mkS6Dirs liveSrvs);
  config.file = (mkS6Runs liveSrvs) // (mkS6Logs liveSrvs) // (mkS6Ends liveSrvs);
}
