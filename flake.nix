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
    mkShell  = imports': shell { inherit self flake-utils devshell nixpkgs; } imports';
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
        extraSpecialArgs = { inputs = devShellInputs; };
      };
    in flake-utils.lib.eachDefaultSystem (system: {
      inherit devShellInputs devShellModules;
      devShell = (eval system).shell;
    });
    pkgs    = system: nixpkgs.legacyPackages.${system}.extend devshell.overlay;
    overlay = devshell.overlay;
  in { inherit defaultTemplate lib overlay; } // (mkShell [ ./project.nix ]);
}
