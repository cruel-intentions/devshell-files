{pkgs, config, lib, ...}: 
let 
  cfg = config.files.git;
in {
  options.files.git.auto-add = lib.mkEnableOption "Auto add files after creation";
}
