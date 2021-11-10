## Instructions

Installing [Nix](https://nixos.wiki/wiki/Flakes)

```sh
curl -L https://nixos.org/nix/install | sh

nix-env -f '<nixpkgs>' -iA nixUnstable

mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

Configuring new projects:

```sh
nix flake new -t github:cruel-intentions/devshell-files my-project
cd my-project
git init
git add .
```

Configuring existing projects:

```sh
nix flake new -t github:cruel-intentions/devshell-files ./
git add flake.nix, flake.lock project.nix
```

#### Generating files:

```sh
nix develop --build
```

or entering in shell with all commands and alias

```sh
nix develop -c $SHELL
# to list commands and alias
# now run: menu 
```
