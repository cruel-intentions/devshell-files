{pkgs, config, lib, ...}: 
let 
  cfg = config.files.git;
in {
  options.files.git.auto-add = lib.mkEnableOption "auto add files to git after creation";
}
