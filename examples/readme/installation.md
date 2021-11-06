## Usage

- [Install Nix](https://nixos.org/download.html#nix-quick-install)
- [Enable experimental-features](https://nixos.wiki/wiki/Flakes#Non-NixOS)
- New projects:
  - Create a new project: `nix flake new -t "github:cruel-intentions/devshell-files" my-project`
  - Add `my-project` to a git repository
- Existing projects:
  - In your project run `nix flake new -t "github:cruel-intentions/devshell-files" ./`
  - Add flake.nix, flake.lock and my-project-module.nix to a git repository
- To create your static files, run `nix develop` in your project directory
