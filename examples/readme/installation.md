## Usage

* [Install Nix](https://nixos.org/download.html#nix-quick-install)
* [Enable experimental-features](https://nixos.wiki/wiki/Flakes#Non-NixOS)
* [Add devshell to your flake.nix file](https://github.com/numtide/devshell/blob/master/template/flake.nix#L5)
* Add this project to your inputs in flake.nix file: `inputs.devshell-files.url = "github:cruel-intentions/devshell-files"`
* Add this modules to your devshell in flake.nix file: `imports = [ devshell-files.${system}.devShellModules ];`
* Add any other modules you need
