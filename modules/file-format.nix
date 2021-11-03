format: {pkgs, config, lib, ...}: 
let 
  cfg = config.files.${format};
  generator = pkgs.formats.${format} {};
  toFile = name: value: {
    source = generator.generate (builtins.baseNameOf name) value;
    git-add = lib.mkIf config.files.git.auto-add true;
  };
in {
  options.files.${format} = lib.mkOption {
    type = lib.types.attrsOf generator.type;
    description = "${format} files";
    default = {};
  };
  config.file = lib.mapAttrs toFile cfg;
}
