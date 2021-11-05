# devshell-files

Helps static configuration creation with [Nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell).

There is a bunch of ways configuration is hard, this will help you generate, validate and distribute JSON, YAML, TOML or TXT.

### Generate

Your content will be defined in [Nix Language](https://github.com/tazjin/nix-1p), it means you can use variables, functions, imports, read files, etc.

The modular system helps layering configurations, hiding complexity and making it easier for OPS team.

### Validate

[Nix Modules](https://nixos.org/manual/nixos/stable/index.html#ex-module-syntax) defined configuration could optionally be well defined and type checked in content build proccess.

As another option, you could use [Nix](https://nixos.org/manual/nix/stable/) as package manager and [install any tool](https://search.nixos.org/packages?query=validator) to validate your configuration (ie integrating it with existing JSON Schema).


### Distribute

Nix integrates well with git and http, it could be also used to read JSON, YAML, TOML, zip and gz files.

In fact Nix isn't a configuration tool but a package manger, we are only using it as configuration tool because the language is simple and flexible.

With help of [Nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell) you could install any development or deployment tool of its [80 000](https://search.nixos.org/) packages.
