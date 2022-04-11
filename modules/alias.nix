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
    type          = lib.types.attrsOf lib.types.string;
    example.hello = "echo hello";
    example.world = ''
      #!/usr/bin/env python
      print("world")
    '';
  };
  config.commands = aliasses;
}
