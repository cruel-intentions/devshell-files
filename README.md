# devshell-files

Modules to help static file creation with [nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell)

## Usage

- [Install Nix](https://nixos.org/download.html#nix-quick-install)
- [Enable experimental-features](https://nixos.wiki/wiki/Flakes#Non-NixOS)
- [Add devshell to your flake.nix file](https://github.com/numtide/devshell/blob/master/template/flake.nix#L5)
- Add this project to your inputs in flake.nix file: `inputs.devshell-files.url = "github:cruel-intentions/devshell-files"`
- Add this modules to your devshell in flake.nix file: `imports = [ devshell-files.${system}.devShellModules ];`
- Add any other modules you need

## Install Examples

<!-- this is also a example o string interpolation -->
```nix
{
  description = "devShell file generator helper";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShellModules = {
        imports = [
          ./modules/files.nix
          ./modules/json.nix
          ./modules/text.nix
          ./modules/toml.nix
          ./modules/yaml.nix
        ];
      };
      devShell =
        let pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
        in
        pkgs.devshell.mkShell {
          imports = [
            self.devShellModules.${system}
            ./examples/hello.nix
            ./examples/world.nix
            ./examples/readme.nix
          ];
        };
    });
}

```

## Module Examples

Creating JSON, TEXT, TOML or YAML files

```nix
# this is one nix file
# see world.nix also as another nix style
{
  config = {
    files = {
      json = {
        "/generated/hello.json" = { hello = "world"; };
      };
      toml = {
        "/generated/hello.toml" = { hello = "world"; };
      };
      yaml = {
        "/generated/hello.yaml" = { hello = "world"; };
      };
      text = {
        "/generated/hello.txt" = ''
          hello world
        '';
      };
    };
  };
}

```

Your file can be complemented with another file

```nix
# this is another nix file
{
  config.files.json."/generated/hello.json".world = "hello";
  config.files.toml."/generated/hello.toml".world = "hello";
  config.files.yaml."/generated/hello.yaml".world = "hello";
}

```

## TODO

- Add modules for especific cases:
  - gitignore
  - most common ci/cd configuration
  - ini files
- License (part copy and past from home-manager)
- Documentation
- Verify if devshell could add it as default
- Auto commit generated files
