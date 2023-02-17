{
  description = ''
    devShell file generator helper
  '';

  inputs.nixpkgs.url  = "github:nixos/nixpkgs/release-22.11";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, devshell, nixpkgs }:
  let
    templates.default.path        = ./template;
    templates.default.description = ''
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
    ];
    isPkg    = val: builtins.isString val && builtins.match "/.+" val == null;
    isntPkg  = val: !(isPkg val);
    mkShell  = imports': shell { inherit self devshell nixpkgs; } imports';
    overlay  = devshell.overlay;
    overlays = { default = overlay; };
    pkgs     = system: nixpkgs.legacyPackages.${system}.extend devshell.overlay;
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
      devShells.aarch64-darwin.default = (eval "aarch64-darwin").shell;
      devShells.aarch64-linux.default  = (eval "aarch64-linux" ).shell;
      devShells.x86_64-darwin.default  = (eval "x86_64-darwin" ).shell;
      devShells.x86_64-linux.default   = (eval "x86_64-linux"  ).shell;
    };
  in { inherit templates lib overlays; } // (mkShell [ ./project.nix ]);
}
