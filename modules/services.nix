{pkgs, config, lib, ...}:
let
  # https://skarnet.org/software/execline/index.html
  exclib   = import ./services/execline.nix;
  s6lib    = import ./services/s6.nix;
  shBang   = exclib.execBang pkgs.execline;
  mkS6Run  = name: {
    name  = "/.data/services/${name}/run";
    value.executable = true;
    value.text       = ''
      #!${pkgs.bash}/bin/bash
      set -e
      exec "${name}" 2>&1
    '';
  };
  mkS6Log  = name: {
    name  = "/.data/services/${name}/log/run";
    value.executable = true;
    value.text       = with exclib;''
      ${shBang}
      ${cdPrj}
      ${hasCmdRun "ifelse" "${name}-log"}
        ${s6lib.log {inherit name; flags = s6lib.defaultLogFlags;}}
    '';
  };
  mkS6Stop = name: {
    name  = "/.data/services/${name}/finish";
    value.executable = true;
    value.text       = ''
      #!${pkgs.bash}/bin/bash
      ${name}-finish $1 &>/dev/null || true
      if [ "$1" == "127" ]; then
        echo "${name} not found, aborting"
        exit 125 # Signal a permanent failure
      fi
      echo ${name} finished
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
  initSvcsd= with exclib;''
    ${shBang}
    # init all services in foreground
    ${s6lib.scanAndLog { 
      supervisor = 
        (lib.optionalString config.files.services-opts.namespace.enable "unshare ${config.files.services-opts.namespace.options}") +
        (lib.optionalString config.files.services-opts.tini.enable "${pkgs.tini}/bin/tini ${config.files.services-opts.tini.options} --");
    }}
  '';
  autoSvcsd= ''
    # Start services in background
    background() {
      exec 0>&-
      exec 1>&-
      exec 2>&-
      exec 3>&-
      initSvcsd &
      disown $!
    }
    background
  '';
  stopSvcsd = ''
    # Stop services when all registered procs died
    while true
    do
      # stop services if folder is empty
      find $PRJ_SVCS_DIR/stopSvcsd/procs/ -type  d -empty -exec stopSvcs \;
      # delete dead procs links
      find $PRJ_SVCS_DIR/stopSvcsd/procs/ -xtype l -delete
      # give a change to a new process before we stop
      sleep 1
    done
  '';
  initSvcs = with exclib;''
    ${shBang}
    # init all services
    ${bg "initSvcsd"}
  '';
  scanSvcs = with exclib;''
    ${shBang}
    # rescan all services
    ${s6lib.scanCtlAndLog { ctlFlags = "-h"; }}
  '';
  stopSvcs = with exclib;''
    ${shBang}
    # stop all services
    ${s6lib.scanCtlAndLog { ctlFlags = "-aq"; }}
  '';
  stUpSvcs = lib.optionalAttrs haveSvcs {
    "zzzzzz-ssssss-services-start".text = ''
      mkdir -p $PRJ_SVCS_LOG/svscan
      mkdir -p $PRJ_SVCS_LOG/svscanctl
      # set down all services
      find $PRJ_SVCS_DIR -maxdepth 1 -mindepth 1 -type d -exec touch {}/down \; \
        &>/dev/null || true
      # set up enabled services
      rm $PRJ_SVCS_DIR/{.s6-svscan,${builtins.concatStringsSep "," liveSvcs}}/down \
        &>/dev/null || true
      # rescan services
      scanSvcs
    '' + lib.optionalString autoStop ''
      AUTO_STOP_SERIVCES () {
        mkdir -p $PRJ_SVCS_DIR/stopSvcsd/procs
        local SESSION_PID=$$
        local PARENT_PID=$PPID
        while grep -q direnv /proc/$PARENT_PID/comm
        do
          SESSION_PID=$(ps -o ppid= $PARENT_PID|tr -d \[:space:\])
          PARENT_PID=$SESSION_PID
        done
        ln -s /proc/$SESSION_PID/comm $PRJ_SVCS_DIR/stopSvcsd/procs/$SESSION_PID &>/dev/null
      }
      AUTO_STOP_SERIVCES
    '' + lib.optionalString autoSvcs ''
      autoSvcsd
    '';
  };
  haveSvcs = builtins.length liveSvcs > 0;
  autoSvcs = haveSvcs && config.files.services.initSvcs  or false;
  autoStop = haveSvcs && config.files.services.stopSvcsd or false;
  completes."/.data/fish_complete/s6.fish" = lib.mkIf haveSvcs {
    executable = true;
    text       = builtins.readFile ./services/complete.fish;
  };
  completes."/.data/bash_complete/s6.sh"   = lib.mkIf haveSvcs {
    executable = true;
    text       = ''
      PRJ_SVCS=$(ls $PRJ_SVCS_DIR)
      complete -W "$PRJ_SVCS" stopSvc
      
      complete -W "$PRJ_SVCS" restartSvc
      
      complete -W "$PRJ_SVCS" restartSvc
      
      complete -W "$PRJ_SVCS" logSvc

      complete -W "$PRJ_SVCS" svcCtl
    '';
  };
in
{
  options.files.services-opts.namespace.enable  = lib.mkEnableOption "[Linux Namespaces](https://docs.kernel.org/userspace-api/unshare.html)";
  options.files.services-opts.namespace.options = lib.mkOption  { type = lib.types.str; default = "--pid --fork --map-root-user";};
  options.files.services-opts.tini.enable       = lib.mkEnableOption "[Tini](https://github.com/krallin/tini) Supervisor";
  options.files.services-opts.tini.options      = lib.mkOption  { type = lib.types.str; default = "-sp SIGTERM"; };
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

      `stopSvcsd` is a special name to auto stop the process supervisor
      If S6 wont stop by itself, we could run `stopSvcs` when it's done.

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

      See also:

       - `files.services-opts.tini.enable` to use [Tini](https://github.com/krallin/tini) as supervisor supervisor
       - `files.services-opts.namespace.enable` to use [namespace](https://docs.kernel.org/userspace-api/unshare.html)

      Know bugs:

      If we don't use `exec` in our alias, some necromancer could
      form an army of undead process, and start a war against our
      system, since they both may require the most scarse resource
      of our lands.

      You can enable namespace if it is an problem
    '';
  };
  config.files.alias = lib.mkIf haveSvcs {
    initSvcs   = initSvcs;
    initSvcsd  = initSvcsd;
    autoSvcsd  = autoSvcsd;
    scanSvcs   = scanSvcs;
    stopSvcs   = stopSvcs;
    stopSvcsd  = stopSvcsd;
    initSvc    = "# Start   service $1\nsvcCtl $1 -u";
    restartSvc = "# Restart service $1\nsvcCtl $1 -r";
    stopSvc    = "# Stop    service $1\nsvcCtl $1 -d";
    svcCtl     = "# Send command $2 to service $1\nIT=$1\nshift\ns6-svc $@ $PRJ_SVCS_DIR/$IT";
  };
  config.devshell.packages = lib.mkIf haveSvcs [ pkgs.s6 pkgs.s6-rc pkgs.execline];
  config.devshell.startup  = stUpSvcs // (rmS6Svcs deadSvcs) // (mkS6Dirs liveSvcs);
  config.file = (mkS6Runs liveSvcs)   // (mkS6Logs liveSvcs) // (mkS6Ends liveSvcs) // completes;
  config.env  = lib.optionals haveSvcs [
    { name = "PRJ_SVCS_DIR"; eval = "$PRJ_DATA_DIR/services"; }
    { name = "PRJ_SVCS_LOG"; eval = "$PRJ_DATA_DIR/log"; }
  ];
}
