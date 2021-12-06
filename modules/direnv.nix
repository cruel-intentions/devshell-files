{ config, lib, ... }:
let
  cfg = config.files.direnv;
in
{
  options.files.direnv.enable = lib.mkEnableOption ''
    Create .envrc file configured to use devShell
  '';
  config.files.text."/.envrc" = lib.mkIf cfg.enable (builtins.readFile ../.envrc);
}
