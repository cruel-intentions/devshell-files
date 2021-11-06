# devshell-files

Helps static file/configuration creation with [Nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell).

There is a bunch of ways static file/configuration are hard, this will help you generate, validate and distribute JSON, YAML, TOML or TXT.

### Generate

Your content will be defined in [Nix Language](https://github.com/tazjin/nix-1p), it means you can use variables, functions, imports, read files, etc.

The modular system helps layering configurations, hiding complexity and making it easier for OPS teams.

### Validate

Your content [modules](https://nixos.org/manual/nixos/stable/index.html#ex-module-syntax) could optionally be well defined and type checked in build proccess with this same tool.

Or you could use [Nix](https://nixos.org/manual/nix/stable/) as package manager and [install any tool](https://search.nixos.org/packages?query=validator) to validate your configuration (ie integrating it with existing JSON Schema).


### Distribute

Nix integrates well with git and http, it could be also used to read JSON, YAML, TOML, zip and gz files.

In fact Nix isn't a configuration tool but a package manger, we are only using it as configuration tool because the language is simple and flexible.

With help of [Nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell) you could install any development or deployment tool of its [80 000](https://search.nixos.org/) packages.

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
  config.files.text."/generated/hello.txt" = "world";
}

```

Your file can be complemented with another file

```nix
# examples/world.nix
{
  # if you think structural style is better
  # it works too
  config = {
    files = {
      json = {
        "/generated/hello.json" = { 
          baz = ["foo" "bar"];
        };
      };
      toml = {
        "/generated/hello.toml" = { 
          baz = ["foo" "bar"];
        };
      };
      yaml = {
        "/generated/hello.yaml" = {
          baz = ["foo" "bar"];
        };
      };
    };
  };
}

```

Content generated by those examples are in [generated](./generated/)

```YAML
# ie ./generated/hello.yaml
hello: world
world:
- foo
- bar

```

### Dogfooding

This project is configured by module [project.nix](./project.nix)

```nix
# ./project.nix
{
  # import other modules
  imports = [
    ./examples/hello.nix
    ./examples/world.nix
    ./examples/readme.nix
  ];
  # install development or deployment tools
  config.commands = [
    { package = "devshell.cli"; }
    { package = "convco"; }
  ];
  # create my .gitignore coping ignore patterns from
  # github.com/github/gitignore
  config.files.gitignore.enable = true;
  config.files.gitignore.template."Global/Archives" = true;
  config.files.gitignore.template."Global/Backup" = true;
  config.files.gitignore.template."Global/Diff" = true;
}

```

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

Fun fact: it import [examples.nix](./examples/readme/examples.nix)
that also include [readme.nix](./examples/readme.nix), as we can see above



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
