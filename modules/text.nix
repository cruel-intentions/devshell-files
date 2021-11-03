{pkgs, config, lib, ...}: 
let 
  format = "text";
  cfg = config.files.${format};
  toFile = name: value: {
    git-add = lib.mkIf config.files.git.auto-add true;
    source = pkgs.writeTextFile {
      name = (builtins.baseNameOf name);
      text = value;
    };
  };
in {
  options.files.${format} = lib.mkOption {
    type = lib.types.attrsOf lib.types.string;
    description = "${format} files";
    default = {};
  };
  config.file = lib.mapAttrs toFile cfg;
}
