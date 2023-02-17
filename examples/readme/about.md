## About

Helps static file/configuration creation with [Nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell).

There is a bunch of ways static file/configuration are hard, this will help you generate, validate and distribute JSON, YAML, TOML or TXT.

#### Generate

Your content will be defined in [Nix Language](https://github.com/tazjin/nix-1p), it means you can use variables, functions, imports, read files, etc.

The modular system helps layering configurations, hiding complexity and making it easier for OPS teams.

#### Validate

Your content [modules](https://nixos.org/manual/nixos/stable/index.html#ex-module-syntax) could optionally be well defined and type checked in build proccess with this same tool.

Or you could use [Nix](https://nixos.org/manual/nix/stable/) as package manager and [install any tool](https://search.nixos.org/packages?query=validator) to validate your configuration (ie integrating it with existing JSON Schema).


#### Distribute

Nix integrates well with git and http, it could be also used to read JSON, YAML, TOML, zip and gz files.

In fact Nix isn't a configuration tool but a package manger, we are only using it as configuration tool because the language is simple and flexible.

You can recreate files of a repository directly to your local machine by running `nix develop <flake-uri> --build`, example:

```bash
# copy all my dogfood ot your current folder
nix develop github:cruel-intentions/devshell-files --build
```

With help of [Nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell) you could install any development or deployment tool of its [80 000](https://search.nixos.org/) packages.
