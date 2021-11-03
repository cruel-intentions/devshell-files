{
  description = "Dev Environment";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell-files.url = "github:cruel-intentions/devshell-files";

  outputs = { self, flake-utils, devshell, devshell-files, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell =
        let pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
        in
        pkgs.devshell.mkShell {
          imports = [
            devshell-files.${system}.devShellModules
            ./my-project-module.nix
          ];
        };
    });
}
