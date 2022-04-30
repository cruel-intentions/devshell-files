let
  exclib = import ./execline.nix;
in
rec {
  log     = { name, flags ? "" }: with exclib; ''
    ${loadEnv "PRJ_SVCS_LOG"}
      s6-log ${flags} "''${PRJ_SVCS_LOG}/${name}"'';
  scan    = { flags ? "" }: with exclib; ''
    ${loadEnv "PRJ_SVCS_DIR"}
      ${errToOut} 
      s6-svscan ''${PRJ_SVCS_DIR}'';
  scanCtl = { flags ? ""}: with exclib; ''
    ${loadEnv "PRJ_SVCS_DIR"}
      ${errToOut}
      s6-svscanctl ${flags} ''${PRJ_SVCS_DIR}'';
  scanAndLog = { scanFlags ? "", logFlags ? "-b n4 s100000" }: with exclib; ''
    ${pipeline (scan { flags = scanFlags; })}
    ${log { name = "scan"; flags = logFlags;}}
  '';
  scanCtlAndLog = { ctlFlags ? "", logFlags ? "-b n4 s100000" }: with exclib; ''
    ${pipeline (scanCtl { flags = ctlFlags; })}
    ${log { name = "scanCtl"; flags = logFlags; }}
  '';
}
