{ config, lib, pkgs, ...}:
let 
  rc = import ./rc.nix { inherit config lib pkgs; };
  shBang   = "#!${pkgs.execline}/bin/execlineb -S0";
  errToOut = "fdmove -c 2 1 # stderr to stdout";
  start.r6-rc-start.text =
    ''
      mkdir -p $PRJ_RC_LOG
      mkdir -p $PRJ_RC_COMPILED
      # I'm not sure why point direclty to compiled didn't work
      cp -r $DEVSHELL_DIR/etc/s6-rc/compiled/*  $PRJ_RC_COMPILED/
      chown -R $(whoami) $PRJ_RC_COMPILED
      chmod -R ugo+w -R  $PRJ_RC_COMPILED

      mkdir -p $PRJ_RC_SCAN
      chown -R $(whoami) $PRJ_DATA_DIR/run/s6*
      chmod -R ugo+w -R $PRJ_DATA_DIR/run/s6*
    '';
  startRC = ''
    ${shBang}
    # init all services
    importas     SCAN_DIR PRJ_RC_SCAN
    importas      LOG_DIR PRJ_RC_LOG
    importas COMPILED_DIR PRJ_RC_COMPILED
    importas     LIVE_DIR PRJ_RC_LIVE
    background {
      background { 
        redirfd -w 1 ''${LOG_DIR}/scan.log
        ${errToOut}
        s6-svscan ''${SCAN_DIR}
      }
      ifelse { 
        redirfd -w 1 /dev/null
        ls ''${LIVE_DIR}/state
      }
      {
        redirfd -w 1 ''${LOG_DIR}/update.log
        ${errToOut}
        s6-rc-update
          -l     ''${LIVE_DIR}
             ''${COMPILED_DIR}
      }
      redirfd -w 1 ''${LOG_DIR}/init.log
      ${errToOut}
      s6-rc-init
        -c ''${COMPILED_DIR}
        -l     ''${LIVE_DIR}
               ''${SCAN_DIR}
    }
  '';
  stopRC = ''
    ${shBang}
    # stop all services
    importas SCAN_DIR PRJ_RC_SCAN
    ${errToOut}
    foreground {
      s6-svscanctl -t ''${SCAN_DIR}
    }
    rm -rf .data/run/s6-scandir/*
  '';
in
{
  imports = [ ./rc-options.nix ];
  config.devshell.packages = lib.mkIf rc.haveSrvs [
    pkgs.s6
    pkgs.s6-rc
    pkgs.execline
    rc.asRCSvrs
  ];
  config.files.alias.stopRC  = lib.mkIf rc.haveSrvs stopRC;
  config.files.alias.startRC = lib.mkIf rc.haveSrvs startRC;
  config.devshell.startup  = lib.mkIf rc.haveSrvs start;
  config.env = lib.optionals rc.haveSrvs [
    { name = "PRJ_RC_COMPILED"; eval = "$PRJ_DATA_DIR/etc/s6-rc/compiled"; }
    { name = "PRJ_RC_LIVE";     eval = "$PRJ_DATA_DIR/run/s6-rc"; }
    { name = "PRJ_RC_SCAN";     eval = "$PRJ_DATA_DIR/run/s6-scandir"; }
    { name = "PRJ_RC_LOG";      eval = "$PRJ_DATA_DIR/var/log/"; }
  ];
}
