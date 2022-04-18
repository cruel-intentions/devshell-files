{ config, lib, pkgs, ...}:
let
  cfgs     = config.files.rc;
  liveSrvs = lib.filterAttrs (n: v: v.enable) cfgs;
  haveSrvs = builtins.length (builtins.attrNames liveSrvs) > 0;
  asS6Srv  = name: srv:
  let
    srvTypes   = srv: builtins.attrNames (
      lib.filterAttrs 
        (n: v: (v != null) && !(builtins.isBool v))
        srv
    );
    srvType    = srv: builtins.head   (srvTypes srv);
    chekType   = srv: builtins.length (srvTypes srv) == 1;
    typesStr   = builtins.toString (srvTypes srv);
    errMsgToo  = "${name} have more than one type: ${typesStr}";
    type       = assert lib.assertMsg (chekType srv) errMsgToo; (srvType srv);
    isEssential= lib.optionalString srv.${type}.essential "touch $out/flag-essential";
    touchType  = ''echo "${type}" > $out/type'';
    info       = srv.${type};
    mkDeps     = n: as:
    let deps = map (dep: "touch $out/${as}/${dep}") info.${n};
    in lib.optionalString (builtins.length info.${n} > 0) 
      ''
        mkdir -p $out/${as}
        ${builtins.concatStringsSep "\n" deps}
      '';
    mkScript   = n: as:
    if info.${n} or null != null then
      ''cp ${pkgs.writeScript "${name}-${n}" info.${n}} $out/${as}''
    else 
      ''echo "${name}-${as}" > $out/${as}'';
    mkAttrFile = n: as: lib.optionalString (info.${n} or null != null)
      ''printf "${builtins.toString info.${n}}\n" > $out/${as}'';
    mkListFile = n: as: lib.optionalString (info.${n} != [])
      ''echo "${builtins.concatStringsSep "\n" info.${n}}" > $out/${as}'';
    mkCp       = n: lib.optionalString (info.${n} or null != null)
      ''cp -r ${info.${n}} $out/'';
    mkStart    =
    let 
      readiness = info.readiness;
      startCmd  = 
      if info.start != null 
      then info.start 
      else "${name}-start";
      readyCmd  = 
      if readiness.command != null 
      then readiness.command 
      else "${name}-ready";
      readySrc  = pkgs.writeScript "${name}-ready" 
        ''
          #!/usr/bin/env -S execlineb -P
          ${readyCmd}
        '';
      runSrc    = pkgs.writeScript "${name}-run"
        ''
          s6-notifyoncheck ${lib.optionalString readiness.fork-fork "-d" }
            -s "${builtins.toString readiness.initial-delay}"
            -T "${builtins.toString readiness.timeout}"
            -w "${builtins.toString readiness.interval}"
            -n "${builtins.toString readiness.attempts}"
            -c "${readySrc}"
            ${startCmd}
        '';
    in 
    if readiness == null
    then mkScript "start" "run"
    else ''cp ${runSrc} $out/run'';
    mkSrv.bundle = pkgs.runCommand "s6-srv-${name}" {}
      ''
        mkdir $out
        ${isEssential}
        ${touchType}
        ${mkDeps "deps" "contents.d"}
      '';
    mkSrv.oneshot = pkgs.runCommand "s6-srv-${name}" {} 
      ''
        mkdir $out
        ${isEssential}
        ${touchType}
        ${mkDeps     "deps"         "dependencies.d"}
        ${mkAttrFile "timeout"      "timeout-up"}
        ${mkAttrFile "timeout-down" "timeout-down"}
        ${mkScript   "start"        "up"} 
        ${mkScript   "stop"         "down"}
      '';
    mkSrv.longrun = pkgs.runCommand "s6-srv-${name}" {}
      ''
        mkdir $out
        ${isEssential}
        ${touchType}
        ${mkStart}
        ${mkDeps     "deps"              "dependencies.d"}
        ${mkAttrFile "timeout"           "timeout-up"}
        ${mkAttrFile "timeout-down"      "timeout-down"}
        ${mkAttrFile "signal"            "down-signal"}
        ${mkAttrFile "kill-after"        "timeout-kill"}
        ${mkAttrFile "kill-finish-after" "timeout-finish"}
        ${mkAttrFile "lock-descriptor"   "lock-fd"}
        ${mkAttrFile "max-restarts"      "max-death-tally"}
        ${mkAttrFile "pipeline-name"     "pipeline-name"}
        ${mkAttrFile "producer-for"      "producer-for"}
        ${mkAttrFile "ready-descriptor"  "notification-fd"}
        ${mkListFile "consumer-for"      "consumer-for"}
        ${mkScript   "stop"              "finish"}
        ${mkCp       "data"}
        ${mkCp       "env"}
      '';
  in mkSrv.${type};
  asRCSvrs =  
  let
    srvFiles   = name: srv:
      ''
        mkdir -p $out/etc/s6-rc/source/${name}
        cp -r ${asS6Srv name srv}/* $out/etc/s6-rc/source/${name}/
      '';
    srvsFiles  = lib.attrsets.mapAttrsToList srvFiles liveSrvs;
  in pkgs.runCommand "s6-rc-compiled-services" {}
    ''
      ${builtins.concatStringsSep "\n" srvsFiles}
      ${pkgs.s6-rc}/bin/s6-rc-compile \
        $out/etc/s6-rc/compiled \
        $out/etc/s6-rc/source
    '';
in
{
  inherit haveSrvs asRCSvrs asS6Srv liveSrvs;
}
