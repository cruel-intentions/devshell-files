{ config, lib, ... }:
let
  cfg   = config.files.direnv;
  envRC = ../.envrc;
in
{
  options.files.direnv.enable = lib.mkEnableOption ''
    Create .envrc file configured to use devShell
  '';

  config.files.text."/.envrc" = lib.mkIf cfg.enable (builtins.readFile ../.envrc);

  config.devshell.startup = lib.mkIf cfg.enable {
    direnv.text = ''
      if [[ ! -f "$PRJ_ROOT/.envrc" ]]; then
        cp --preserve=timestamps ${envRC} $PRJ_ROOT/.envrc
        chmod u+rw $PRJ_ROOT/.envrc
      fi
    '';
  };
}
