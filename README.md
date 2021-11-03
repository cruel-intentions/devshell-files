# devshell-files

Modules to help static file creation with [nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell)

## Usage

- [Install Nix](https://nixos.org/download.html#nix-quick-install)
- [Enable experimental-features](https://nixos.wiki/wiki/Flakes#Non-NixOS)
- Create a new project: `nix flake new -t "github:cruel-intentions/devshell-files" my-project`
- Init or add my-project to a git repository
- Into my-project directory run: `nix develop`

## Configuration Examples

```nix
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
            devshell-files.devShellModules.${system}
            ./my-project-module.nix
          ];
        };
    });
}

```

## Module Examples

Creating JSON, TEXT, TOML or YAML files

```nix
# examples/hello.nix
#
# this is one nix file
{
  config.files.json."/generated/hello.json".hello = "world";
  config.files.toml."/generated/hello.toml".hello = "world";
  config.files.yaml."/generated/hello.yaml".hello = "world";
  config.files.text."/generated/hello.text" = "world";
}

```

Your file can be complemented with another file

```nix
# examples/world.nix
{
  config.files.json."/generated/hello.json".world = "hello";
  config.files.toml."/generated/hello.toml".world = "hello";
  config.files.yaml."/generated/hello.yaml".world = "hello";
}

```

Content generated by those examples

/generated/hello.json
```JSON
{
  "hello": "world",
  "world": "hello"
}

```

/generated/hello.txt
```text
hello world

```

/generated/hello.toml
```TOML
hello = "world"
world = "hello"

```

/generated/hello.yaml
```YAML
hello: world
world: hello

```

This README.md is also a module
```nix
# There is a lot things we could use to write dynamic static file
# Basic intro to nix language https://github.com/tazjin/nix-1p
# Some nix functions https://teu5us.github.io/nix-lib.html

{pkgs, lib, ...}:
{
  config.files.text."/README.md" = builtins.concatStringsSep "\n" [
    (builtins.readFile ./readme/title.md)
    (builtins.readFile ./readme/installation.md)
    (import ./readme/examples.nix)
    (builtins.readFile ./readme/todo.md)
    (builtins.readFile ./readme/issues.md)
  ];
}

```

## TODO

- Add modules for especific cases:
  - gitignore
  - most common ci/cd configuration
  - ini files
- License (part copy and paste from home-manager)
- Documentation
- Verify if devshell could add it as default
- Auto commit generated files

## Issues

This project uses git as version control, if your are using other version control system it may not work.

It also means that it can you work with versioned files.
