{ config, lib, ... }:
let
  cfg   = config.files.direnv;
  envRC = ./direnvrc;
in
{
  options.files.direnv.enable = lib.mkEnableOption ''
    Create .envrc file configured to use devShell
  '';
  options.files.direnv.auto-build.enable = lib.mkEnableOption ''
    A service to watch direnv and reduce reload time
  '';

  config.files.services.auto-build = cfg.auto-build.enable;

  config.files.alias.auto-build = lib.mkIf cfg.auto-build.enable ''
    # Rebuild direnv nix hook
    while true
    do
      direnvdir=$PRJ_ROOT/.direnv
      DEVSHELL_FILES_WATCHING=$(find . -name '*.nix')
      DEVSHELL_FILES_CHANGED=$(stat -c '%y' flake.lock $DEVSHELL_FILES_WATCHING|sort -u|tail -n 1)
      if ! $(cmp --silent -- <(echo "$DEVSHELL_FILES_CHANGED") "$direnvdir/session"); then
        notify-desktop -i network-server "Building env";
        mkdir -p "$direnvdir"
        nix print-dev-env --profile "$direnvdir/flake-profile" "$@" \
          > "$direnvdir/flake-profile.sh"
        chmod +x "$direnvdir/flake-profile.sh"
        cp -f <(echo "$DEVSHELL_FILES_CHANGED") "$direnvdir/session"
      fi
      sleep 1
    done
  '';

  config.file."/.direnv/use_devshell_files.sh" = lib.mkIf cfg.enable {
    executable  = true;
    text        = ''
      use_devshell_files() {
        watch_file *.nix
        watch_file */*.nix
        watch_file flake.lock
        local direnvdir
        direnvdir=$(direnv_layout_dir)
        export DEVSHELL_FILES_WATCHING=$(find . -name '*.nix')
        export DEVSHELL_FILES_CHANGED=$(stat -c '%y' flake.lock $DEVSHELL_FILES_WATCHING|sort -u|tail -n 1)
        if ! $(cmp --silent -- <(echo "$DEVSHELL_FILES_CHANGED") "$direnvdir/session"); then
          mkdir -p "$direnvdir"
          nix print-dev-env --profile "$direnvdir/flake-profile" "$@" \
            > "$direnvdir/flake-profile.sh"
          chmod +x "$direnvdir/flake-profile.sh"
          cp -f <(echo "$DEVSHELL_FILES_CHANGED") "$direnvdir/session"
        fi
        source "$direnvdir/flake-profile.sh"
      }
    '';
  };

  config.file."/.direnv/rm_old_env_builds.sh" = lib.mkIf cfg.enable {
    executable  = true;
    text        = ''
      #!/usr/bin/env bash
      ACTIVE=$(readlink $PRJ_ROOT/.direnv/flake-profile)
      find $PRJ_ROOT/.direnv -name 'flake-profile-*-link' -not -name "$ACTIVE" -delete
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
