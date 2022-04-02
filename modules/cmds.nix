{pkgs, config, lib, ...}:
let
  cfg    = config.files.cmds;
  toCmds = name: { package = name; };
  cmds   = map toCmds (builtins.attrNames cfg);
in {
  options.files.cmds = lib.mkOption {
    example.awscli      = true;
    example.azure-cli   = true;
    example.cargo       = true;
    example.conda       = true;
    example.convco      = true;
    example.go_1_17     = true;
    example.nodejs-16_x = true;
    example.pipenv      = true;
    example.python39    = true;
    example.ruby_3_0    = true; # installs ruby and gem
    example.rustc       = true;
    example.terraform   = true;
    example.yarn        = true;
    type = lib.types.attrsOf lib.types.bool;
    description = ''
      Add commands to the environment.

      https://search.nixos.org for more tools
    '';
    default = {};
  };
  config.commands = cmds;
}
