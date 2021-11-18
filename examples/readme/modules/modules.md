### Modules

Modules could be defined in two formats:

#### As function:

These functions has at least these params: 

- `config` with all evaluated configs values, 
- `pkgs` with all [nixpkgs](https://search.nixos.org/) available.
- `lib` [library](https://teu5us.github.io/nix-lib.html#nixpkgs-library-functions) of useful functions.
- And may receive other named params (use `...` to ignore them)

```nix
{ config, pkgs, lib, ... }:  # parms
{ imports = []; config = {}; options = {}; }
```

#### As object:

```nix
{ imports = []; config = {}; options = {}; }
```

All those attributes are optional

- imports: array with paths to other modules
- config: object with user configurations
- options: object with our config type definition

We adivise you to divide your modules in two files:
- One mostly with options, where your definition goes
- Other with config, where your information goes

It has two advantages, you could share options definitions across projects more easily.

And it hides complexity, [hiding complexity is what abstraction is all about](http://mourlot.free.fr/english/fmtaureau.html),
we didn't share options definitions across projects to type less, but because we could reuse an abstraction that helps hiding complexity.

#### Options

Imports and configs are simple, and you saw all those examples till now.
Please open an issue to clarify any question about them.

Them we need to learn how to create options.

Lets start with simple example:

We need create our github action file, it could be done as something like this:

```nix
{
  config.files.yaml."./.github/workflows/ci-cd.yaml" = {
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

If we add this to our project.nix we discover that there is no `gh-actions` config available.

To create it we add `options` definition of that.

```nix
{ lib, ...}:
{
  options.gh-actions.ci-cd = lib.mkOption {
    type = lib.types.submodule {
      options.pre-build = lib.mkOption {
        type = lib.types.str;
        default = "echo pre-building";
        example = "npm i";
        description = "Command to run before build";
      };
      options.build = lib.mkOption {
        type = lib.types.str;
        default = "echo building";
        example = "npm run build";
        description = "Command to run as build step";
      };
      options.test = lib.mkOption {
        type = lib.types.str;
        default = "echo testing";
        example = "npm test";
        description = "Command to run as test step";
      };
      options.deploy = lib.mkOption {
        type = lib.types.str;
        default = "echo deploying";
        example = "aws s3 sync ./build s3://my-bucket";
        description = "Command to run as deploy step";
      };
    };
    default = {};
    description = "Configure your github actions CI/CD";
  };
}
```

Good, that is it, now we can set config as we said before, but it does nothing, it doesn't create our yaml file.

Usually people put the next part in same file of previous code, it isn't a requirement, and spliting it here make it simplier to explain.

The cool point is that to create our yaml file we only need one config like we proposed first.

```nix
{ lib, config, ... }:
let
  cfg = config.gh-actions.ci-cd;
  cmd = step: "nix develop --command gh-actions-ci-cd-${step}";
in
{ 
  imports = [ ./gh-actions-options.nix ];
  config.files.alias = lib.mkIf cfg.enable {
    gh-actions-ci-cd-pre-build = cfg.pre-build;
    gh-actions-ci-cd-build = cfg.build;
    gh-actions-ci-cd-test = cfg.test;
    gh-actions-ci-cd-deploy = cfg.deploy;
  };
  config.files.yaml."/.github/workflows/ci-cd.yaml" = lib.mkIf cfg.enable {
    on = "push";
    jobs.ci-cd.runs-on = "ubuntu-latest";
    jobs.ci-cd.steps = [
      { uses = "actions/checkout@v2.4.0"; }
      { 
        uses = "cachix/install-nix-action@v15";
        "with".nix_path = "channel:nixos-unstable";
        "with".extra_nix_config = ''
          access-tokens = github.com=${"$"}{{ secrets.GITHUB_TOKEN }}
        '';
      }
      # this config comes from arguments
      { run = cmd "pre-build"; name = "Pre Build"; }
      { run = cmd "build"; name = "Build"; }
      { run = cmd "test"; name = "Test"; }
      { run = cmd "deploy"; name = "Deploy"; }
    ];
  };
}
```

Now we only need to import it on our project and set 'pre-build', 'build', 'test' and 'deploy' configs

```nix
{
  config.gh-actions.ci-cd.enable = true;
  config.gh-actions.ci-cd.deploy = "echo 'habemus lux'";
}
```

If we try to set something that is not a string to it, one error will raise, typecheking it.

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
