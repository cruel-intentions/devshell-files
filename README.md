# devshell-files

Modules to help static file creation with [nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell)

## Usage

- [Install Nix](https://nixos.org/download.html#nix-quick-install)
- [Enable experimental-features](https://nixos.wiki/wiki/Flakes#Non-NixOS)
- Create a new project: `nix flake new -t "github:cruel-intentions/devshell-files" my-project`
- Add my-project to a git repository
- To create files run `nix develop` in my-project directory

## Examples

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

Content generated by those examples are in [./generated/](./generated/)

```YAML
# ie ./generated/hello.yaml
hello: world
world: hello

```

[/generated/hello.yaml](./generated/hello.yaml)

### Dogfooding

This README.md is also a module defined as above

```nix
# There is a lot things we could use to write static file
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

Fun fact it import [examples.nix](./examples/readme/examples.nix)
that also include [readme.nix](./examples/readme.nix), as we can see above

### Configuration Examples

To integrate it with existing project

Copy files of [template](./template/) to your project

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

```nix
{
  config.commands = [
    { package = "devshell.cli"; }

    # for more tools search (ie. linters)
    # https://search.nixos.org/packages?query=lint
  
    # convential commit helper
    # https://github.com/convco/convco
    { package = "convco"; }
  ];
  config.files.text."/hello.txt" = "Hello World!!";
}

```

## TODO

- Add modules for especific cases:
  - gitignore
  - most common ci/cd configuration
  - ini files
- Use more this project in it self
- License (part copy and paste from home-manager)
- Documentation
- Verify if devshell could add it as default
- Auto commit generated files

## Issues

This project uses git as version control, if your are using other version control system it may not work.

It also means that it can you work with versioned files.
