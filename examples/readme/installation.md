## Usage

- [Install Nix](https://nixos.org/download.html#nix-quick-install)
- [Enable experimental-features](https://nixos.wiki/wiki/Flakes#Non-NixOS)
- Create a new project: `nix flake new -t "github:cruel-intentions/devshell-files" my-project`
- Add my-project to a git repository
- To create files run `nix develop` in my-project directory
