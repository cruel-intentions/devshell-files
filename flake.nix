{
  description = ''
    devShell file generator helper
  '';

  inputs.devshell.url    = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell, nixpkgs }@inputs:
  let
    modules = [
      ./modules/files.nix
      ./modules/inputs.nix
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
      ./modules/nim.nix
    ];
    pkgs     = system:  nixpkgs.legacyPackages.${system}.extend devshell.overlay;
    mkShell  = imports: flake-utils.lib.eachDefaultSystem (system: {
      devShellModules = { inherit imports; };
      devShell        = (pkgs system).devshell.mkShell {
        imports = modules 
        ++ [{ 
            files.inputs.flake-utils = "${flake-utils}";
            files.inputs.devshell    = "${devshell}";
          }]
          ++ imports;
      };
    });
    output   = other:   (mkShell [ ./project.nix ]) // other;
  in output {
    defaultTemplate.path        = ./template;
    defaultTemplate.description = ''
      nix flake new -t github:cruel-intentions/devshell-files project
    '';
    lib.importTOML = devshell.lib.importTOML;
    lib.mkShell    = mkShell;
    overlay        = devshell.overlay;
  };
}
