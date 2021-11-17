{pkgs, config, lib, ...}:
let
  cfg = config.files.alias;
  toAlias = name: {
    inherit name;
    help = builtins.head (lib.splitString "\n" cfg.${name});
    command = ''
      ${cfg.${name}}
    '';

  };
  aliasses = map toAlias (builtins.attrNames cfg);
in {
  options.files.alias = lib.mkOption {
    type = lib.types.attrsOf lib.types.string;
    example = "echo hello";
    description = "Description for use in the NixOS manual.";
    default = {};
  };
  config.commands = aliasses;
}
