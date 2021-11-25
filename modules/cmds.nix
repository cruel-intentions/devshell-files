{pkgs, config, lib, ...}:
let
  cfg = config.files.cmds;
  toCmds = name: { package = name; };
  cmds = map toCmds (builtins.attrNames cfg);
in {
  options.files.cmds = lib.mkOption {
    example.convco = true;
    example.nodejs-16_x = true;
    example.yarn = true;
    example.python39 = true;
    example.pipenv = true;
    example.conda = true;
    example.ruby_3_0 = true; # installs ruby and gem
    example.go_1_17 = true;
    example.rustc = true;
    example.cargo = true;
    example.awscli = true;
    example.azure-cli = true;
    example.terraform = true;
    type = lib.types.attrsOf lib.types.bool;
    description = ''
      Add commands to the environment.

      https://search.nixos.org for more tools
    '';
    default = {};
  };
  config.commands = cmds;
}
