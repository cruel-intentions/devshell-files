{pkgs, config, lib, ...}: 
{
  options.files.on-call = lib.mkEnableOption "Files will be created when devshell-files command is called instead of when start the shell";
}
