{
  description = ''
    devShell file generator helper
  '';

  inputs.devshell.inputs.nixpkgs.follows     = "nixpkgs";
  inputs.devshell.inputs.flake-utils.follows = "flake-utils";
  inputs.devshell.url    = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url     = "github:nixos/nixpkgs/22.05";

  outputs = { self, flake-utils, devshell, nixpkgs }:
  let
    defaultTemplate.path        = ./template;
    defaultTemplate.description = ''
      nix flake new -t github:cruel-intentions/devshell-files project
    '';
    lib.importTOML = devshell.lib.importTOML;
    lib.mkShell    = mkShell;
    modules' = [
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
      ./modules/mdbook.nix
      ./modules/direnv.nix
      ./modules/services.nix
      ./modules/services/rc-devshell.nix
      ./modules/nim.nix
    ];
    isPkg    = val: builtins.isString val && builtins.match "/.+" val == null;
    isntPkg  = val: !(isPkg val);
    mkShell  = args: 
    let 
      imports  = modules' ++ modules;
      modules  = builtins.filter isntPkg args;
      packages = builtins.filter isPkg   args;
    in flake-utils.lib.eachDefaultSystem (system: {
      devShellModules  = { inherit modules; };
      devShell         = (pkgs system).devshell.mkShell {
        inherit packages imports;
      };
    });
    pkgs    = system: nixpkgs.legacyPackages.${system}.extend devshell.overlay;
    overlay = devshell.overlay;
  in { inherit defaultTemplate lib overlay; } // (mkShell [ ./project.nix ]);
}
