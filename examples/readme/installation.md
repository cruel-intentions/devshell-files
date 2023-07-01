## Instructions

Installing [Nix](https://nixos.wiki/wiki/Flakes)

```sh
curl -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Configuring new projects:

```sh
nix flake new -t github:cruel-intentions/devshell-files my-project
cd my-project
git init
git add *.nix flake.lock
```

Configuring existing projects:

```sh
nix flake new -t github:cruel-intentions/devshell-files ./
git add *.nix
git add flake.lock
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
