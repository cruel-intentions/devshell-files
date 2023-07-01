{
  description = ''devShell file generator helper'';

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flu.url      = "github:cruel-intentions/flu-type-a";
  inputs.nixpkgs.url  = "github:nixos/nixpkgs/release-23.05";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flu.inputs.nixpkgs.follows      = "nixpkgs";

  outputs = { self, devshell, flu, nixpkgs }:
  let
    templates.default.path        = ./templates/default;
    templates.default.description = ''nix flake new -t github:cruel-intentions/devshell-files .'';
    lib.importTOML = devshell.lib.importTOML;
    lib.mkShell    = mkShell;
    lib.shell      = shell;
    modules' = [
      ./modules/files.nix
      ./modules/cmds.nix
      ./modules/alias.nix
      ./modules/json.nix
      ./modules/text.nix
      ./modules/toml.nix
      ./modules/yaml.nix
      ./modules/hcl.nix
      ./modules/startup.nix
      ./modules/git.nix
      ./modules/gitignore.nix
      ./modules/spdx.nix
      ./modules/docs.nix
      ./modules/mdbook.nix
      ./modules/direnv.nix
      ./modules/services.nix
      ./modules/services/rc-devshell.nix
      ./modules/nim.nix
      ./modules/nushell.nix
      ./modules/nush.nix
      ./modules/nuon.nix
      ./modules/watch
    ];
    isPkg    = val: builtins.isString val && builtins.match "/.+" val == null;
    isntPkg  = val: !(isPkg val);
    mkShell  = imports': shell { inherit self devshell nixpkgs; } imports';
    overlay  = devshell.overlay;
    overlays = { default = overlay; };
    pkgs     = system: (nixpkgs.legacyPackages.${system}.extend flu.overlays.default).extend devshell.overlays.default;
    shell    = inputs: imports':
    let 
      imports  = modules' ++ modules;
      modules  = builtins.filter isntPkg imports';
      packages = builtins.filter isPkg   imports';
      devShellModules  = { inherit modules; };
      devShellInputs   =
      let
        inputsVals   = builtins.attrValues inputs;
        inputInputs  = input: input.devShellInputs or {};
        inputsInputs = map inputInputs inputsVals;
      in builtins.foldl' builtins.intersectAttrs {} inputsInputs // inputs;
      eval = system: (pkgs system).devshell.eval {
        configuration    = { inherit packages imports; };
        extraSpecialArgs = { inputs = devShellInputs;  };
      };
    in {
      inherit devShellInputs devShellModules;
      devShells = builtins.mapAttrs (system: v: { default = (eval system).shell; } ) devshell.devShells;
    };
  in { inherit templates lib overlays; } // (mkShell [ ./project.nix ]);
}
