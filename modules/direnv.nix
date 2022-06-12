{ config, lib, ... }:
let
  cfg   = config.files.direnv;
  envRC = ./direnvrc;
in
{
  options.files.direnv.enable = lib.mkEnableOption ''
    Create .envrc file configured to use devShell
  '';

  config.file."/.direnv/use_devshell_files.sh" = lib.mkIf cfg.enable {
    executable  = true;
    text        = ''
      use_devshell_files() {
        local direnvdir
        direnvdir=$(direnv_layout_dir)
      
        if ! $(cmp --silent -- <(echo "$DIRENV_WATCHES") "$direnvdir/session"); then
          mkdir -p "$direnvdir"
          nix print-dev-env --profile "$direnvdir/flake-profile" "$@" \
            > "$direnvdir/flake-profile.sh"
          chmod +x "$direnvdir/flake-profile.sh"
          cp -f <(echo "$DIRENV_WATCHES") "$direnvdir/session"
        fi
      
        source "$direnvdir/flake-profile.sh"
      }
    '';
  };

  config.devshell.startup = lib.mkIf cfg.enable {
    direnv.text = ''
      if [[ ! -f "$PRJ_ROOT/.envrc" ]]; then
        cp --preserve=timestamps ${envRC} $PRJ_ROOT/.envrc
        chmod u+rw $PRJ_ROOT/.envrc
      fi
    '';
  };
}
