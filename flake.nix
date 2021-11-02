{
  description = "devshell file generator helper";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShellModules = {
        imports = [
          ./modules/files.nix
          ./modules/hello.nix
        ];
      };
      devShell =
        let pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
        in
        pkgs.devshell.mkShell self.devShellModules.${system};
    });
}
