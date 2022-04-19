let
  exclib   = import ./execline.nix;
in
rec {
  log     = { name, flags ? "" }: with exclib; ''
    ${getEnv "PRJ_SVCS_LOG"}
      ${errToOut}
      s6-log ${flags} "''${PRJ_SVCS_LOG}/${name}"'';
  scan    = { flags ? ""}: with exclib; ''
    ${getEnv "PRJ_SVCS_DIR"}
      ${errToOut} 
      s6-svscan ''${PRJ_SVCS_DIR}'';
  scanCtl = { flags ? ""}: with exclib; ''
    ${getEnv "PRJ_SVCS_DIR"}
      ${errToOut}
      s6-svscanctl ${flags} ''${PRJ_SVCS_DIR}'';
  scanAndLog = { scanFlags ? "", logFlags ? "-b n4 s100000" }: with exclib; ''
    ${getEnv "PRJ_SVCS_LOG"}
    ${getEnv "PRJ_SVCS_DIR"}
    ${redirfd "\${PRJ_SVCS_LOG}/svscan/log"}
    ${errToOut}
    s6-svscan ${scanFlags} ''${PRJ_SVCS_DIR}
  '';
  scanCtlAndLog = { ctlFlags ? "", logFlags ? "-b n4 s100000" }: with exclib; ''
    ${getEnv "PRJ_SVCS_LOG"}
    ${getEnv "PRJ_SVCS_DIR"}
    ${redirfd "\${PRJ_SVCS_LOG}/svscanctl/log"}
    ${errToOut}
    s6-svscanctl ${ctlFlags} ''${PRJ_SVCS_DIR}
  '';
}
