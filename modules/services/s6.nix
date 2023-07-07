let
  exclib = import ./execline.nix;
in
rec {
  defaultLogFlags = "-b n10 s1000000 T";
  log     = { name, flags ? defaultLogFlags }: with exclib; ''
    ${loadEnv "PRJ_SVCS_LOG"}
      s6-log ${flags} "''${PRJ_SVCS_LOG}/${name}"'';
  scan    = { flags ? "" , supervisor ? "" }: with exclib; ''
    ${loadEnv "PRJ_SVCS_DIR"}
      ${errToOut} 
      ${supervisor} s6-svscan ''${PRJ_SVCS_DIR}'';
  scanCtl = { flags ? "" }: with exclib; ''
    ${loadEnv "PRJ_SVCS_DIR"}
      ${errToOut}
      s6-svscanctl ${flags} ''${PRJ_SVCS_DIR}'';
  scanAndLog = { scanFlags ? "", logFlags ? defaultLogFlags, supervisor ? "" }: with exclib; ''
    ${pipeline (scan { flags = scanFlags; supervisor = supervisor; })}
    ${log { name = "scan"; flags = logFlags;}}
  '';
  scanCtlAndLog = { ctlFlags ? "", logFlags ? defaultLogFlags }: with exclib; ''
    ${pipeline (scanCtl { flags = ctlFlags; })}
    ${log { name = "scanCtl"; flags = logFlags; }}
  '';
}
