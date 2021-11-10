### Modules

Modules could be defined in two formats: Functions that return an Object or just Object without any function resulting it.

These functions has at least these named params: 

- `config` with all evaluated configs values, 
- `pkgs` with all [nixpkgs](https://search.nixos.org/) available.
- `lib` [library](https://teu5us.github.io/nix-lib.html#nixpkgs-library-functions) of useful functions.

And may receive other named params (use `...` to ignore them)

Nix function with named params:

```nix
{ config, pkgs, lib, ...}:  # named params fuction
{ imports = []; config = {}; options = {}; }
```

All those attributes are optional

- imports: array with paths that points to other modules
- config: object with information expected at the output (think as inputs)
- options: object with expected input definition 

We adivise you to divide your modules in at two files:
- One mostly with options, where your definition goes
- Other with config, where your information goes

It has two advantages, you could share options definitions across projects more easily.

And it hides complexity, [hiding complexity is what abstraction is all about](http://mourlot.free.fr/english/fmtaureau.html),
we didn't share options definitions across projects to type less, but because we could reuse an abstraction that helps hiding complexity.

#### Options

Imports and configs are simple, and you may saw all those examples till now.
Please open an issue to clarify if any question about are left.

Them we need to learn how to create options.

Lets start with simple example:

We need create our github action file, it could be done as something like this:

```nix
{
  config.files.yaml."./.github/workflows/ci-cd" = {
    on = "push";
    # ... rest of github action definition
  };
}
```

As we can see, we aren't hiding complexity and we may copy and past it in every project.

Since most of our config are just: 'get code', 'build', 'test', 'install'

What project user (maybe us) really needs to define is:

```nix
{
  config.gh-actions.ci-cd.pre-build = "npm i";
  config.gh-actions.ci-cd.build = "npm run build";
  config.gh-actions.ci-cd.test = "npm run test";
  config.gh-actions.ci-cd.deploy = "aws s3 sync ./build s3://some-s3-bucket";
  # in the best of worlds this two aren't required but craw command
  # to seek dependecies is hard (we sucked at hiding complexity)
  config.files.cmds.aws-cli = true;
  config.files.cmds.nodejs-14_x = true;
}
```

Now we're hiding complexity, not all, but some.

If we add this to your project.nix we sadly discover that there is no `gh-actions` config available.

What need should to is create options definition of that

```nix
{ lib, ...}:
{
  options.gh-actions.ci-cd = lib.mkOption {
    type = lib.types.submodule {
      pre-build = lib.mkOption {
        type = lib.types.string;
        default = "echo pre-building";
        example = "npm i";
        description = "Command to run before build";
      };
      build = lib.mkOption {
        type = lib.type.string;
        default = "echo building";
        example = "npm run build";
        description = "Command to run as build step";
      };
      test = lib.mkOption {
        type = lib.type.string;
        default = "echo testing";
        example = "npm test";
        description = "Command to run as test step";
      };
      deploy = lib.mkOption {
        type = lib.type.string;
        default = "echo deploying";
        example = "aws s3 sync ./build s3://my-bucket";
        description = "Command to run as deploy step";
      };
    };
    default = {};
    description = "Configure your github actions CI/CD"
  };
}
```

Good that is it, now we can set config as we said before, but it does nothing, it doesn't create you yaml file.

Usually people put this next part in same file of previous code, it isn't a requirent, and spliting it here make it simplier to explain.

The cool point is that to create our yaml file we only need one config like we proposed first.

```nix
{ lib, config, ... }:
{ 
  config.files.yaml."/.github/workflows/ci-cd" = {
    on = "push";
    jobs.ci-cd.runs-on = "ubuntu-latest";
    jobs.ci-cd.steps = [
      { uses = "actions/checkout@v1"; }
      { uses = "cachix/install-nix-action@v13"; "with".nix_path = "channel:nixos-unstable"; }
      { run = "nix develop"; }
      # this config comes from arguments
      { run = config.gh-actions.ci-cd.pre-build; }
      { run = config.gh-actions.ci-cd.build; }
      { run = config.gh-actions.ci-cd.test; }
      { run = config.gh-actions.ci-cd.deploy; }
    ];
  };
}
```

Now we only need to import it our project and set 'pre-build', 'build', 'test' and 'deploy' configs

If we try to set something that is not a string to it, one error will raise

There are [other types](https://nixos.org/manual/nixos/stable/index.html#sec-option-types) that can be used (some of them):
- lib.types.bool 
- lib.types.path 
- lib.types.package 
- lib.types.int 
- lib.types.ints.unsigned
- lib.types.ints.positive
- lib.types.ints.port
- lib.types.ints.between
- lib.types.str
- lib.types.lines
- lib.types.enum
- lib.types.submodule
- lib.types.nullOr (typed nullable)
- lib.types.listOf (typed array)
- lib.types.attrsOf (typed hash map)
- lib.types.uniq (typed set)
