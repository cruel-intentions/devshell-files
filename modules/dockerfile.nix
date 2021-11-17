{pkgs, config, lib, ...}: 
let
  cfg = config.files.dockerfile;
  # directives = pkgs.callPackage ./dockerfile/directives.nix { inherit lib; };
  toFile = name: value: {
    source = pkgs.writeTextFile {
      name = (builtins.baseNameOf name);
      text = value;
    };
    git-add = lib.mkIf config.files.git.auto-add true;
  };
in {
  options.files.dockerfile = lib.mkOption {
    type = lib.types.attrsOf lib.types.lines;
    description = "Dockerfile files";
    default = {};
  };
  config.file = lib.mapAttrs toFile cfg;
  config.files.dockerfile."/drunkfile" = ''
    FROM nixpkgs/nix-flakes
    ONBUILD AAAA Bbbbb
    ADD /home/hugosenari/.gitconfig /app
  '';
}
