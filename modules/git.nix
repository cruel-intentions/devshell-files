{pkgs, config, lib, ...}: 
{
  options.files.git.auto-add = lib.mkEnableOption "auto add files to git after creation";
}
