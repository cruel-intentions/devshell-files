{pkgs, config, lib, ...}:
let
  cfg = config.files.alias;
  toAlias = name: {
    inherit name;
    help    = builtins.head (lib.splitString "\n" cfg.${name});
    command = ''
      ${cfg.${name}}
    '';

  };
  aliasses = map toAlias (builtins.attrNames cfg);
in {
  options.files.alias = lib.mkOption {
    default       = {};
    description   = "bash script to create an alias";
    example.hello = "echo hello";
    type          = lib.types.attrsOf lib.types.string;
  };
  config.commands = aliasses;
}
