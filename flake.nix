{
  description = "devShell file generator helper";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nmd.url = "gitlab:rycee/nmd";
  inputs.nmd.flake = false;

  outputs = { self, flake-utils, devshell, nixpkgs, nmd }:
  let
    modules = [
      ./modules/files.nix
      ./modules/cmds.nix
      ./modules/alias.nix
      ./modules/json.nix
      ./modules/text.nix
      ./modules/toml.nix
      ./modules/yaml.nix
      ./modules/hcl.nix
      ./modules/git.nix
      ./modules/gitignore.nix
      ./modules/spdx.nix
      ./modules/docs.nix
    ];
    overlays = [ devshell.overlay ];
    pkgs = system: import nixpkgs { inherit system overlays; };
    mkShell = userModules: flake-utils.lib.eachDefaultSystem (system: {
      devShellModules.imports = userModules;
      devShell = (pkgs system).devshell.mkShell { imports = modules ++ userModules; };
    });
    output = other: (mkShell [ ./project.nix ]) // other;
  in output {
    lib.mkShell = mkShell;
    lib.importTOML = devshell.lib.importTOML;
    overlay = devshell.overlay;
    defaultTemplate.path = ./template;
    defaultTemplate.description = "nix flake new -t github:cruel-intentions/devshell-files project";
  };
}
