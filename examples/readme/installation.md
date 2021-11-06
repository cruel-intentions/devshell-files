## How

### Install [Nix Flakes](https://nixos.wiki/wiki/Flakes)

```sh
curl -L https://nixos.org/nix/install | sh

nix-env -f '<nixpkgs>' -iA nixUnstable

mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

### New projects:

- Create a new project: `nix flake new -t "github:cruel-intentions/devshell-files" my-project`
- Add `my-project` to a git repository


### Existing projects:

- In your project run `nix flake new -t "github:cruel-intentions/devshell-files" ./`
- Add flake.nix, flake.lock and project.nix to a git repository


### Usage

- To create your static files, run `nix develop` in your project directory
