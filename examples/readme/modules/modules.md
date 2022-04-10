### Module

Modules can be defined in two formats:

#### As function:

These functions has at least these params: 

- `config` with all evaluated configs values, 
- `pkgs` with all [nixpkgs](https://search.nixos.org/) available.
- `lib` [library](https://teu5us.github.io/nix-lib.html#nixpkgs-library-functions) of useful functions.
- And may receive other named params (use `...` to ignore them)

```nix
{ config, pkgs, lib, ... }: # function parms
{                           # function result/module info
  imports = [];
  config  = {};
  options = {};
}  
```

#### As attrset, aka. object (JS), dict (Python):

```nix
{  # module info
  imports = [];
  config  = {};
  options = {};
}
```

All those attributes are optional

- imports: array  with paths to other modules
- config:  object with project configurations
- options: object with our config type definition

We adivise you to split your modules in two files:
- One mostly with options, where your definition goes
- Other with config, where your information goes

It has two advantages, you could share options definitions across projects more easily.

And it hides complexity, [hiding complexity is what abstraction is all about](http://mourlot.free.fr/english/fmtaureau.html),
we didn't share options definitions across projects to type less, but because we could reuse an abstraction that helps hiding complexity.

#### Imports

Points to other module files we want import in this module

```nix
{ 
  imports = [
    ./gh-actions-options.nix
    ./some-other-module.nix
  ];
}
```

If your need import a plain nix file (not a module) you can use `builtins.import` function

```nix
{
  # hello.txt: Hello World!
  config.files.text."/foo/hello.txt" = import ./hello.txt;
}
```

There are also a JSON and TOML helpers
```nix
{ lib, ...}:
{
  # hello.json: { "msg": "Hello World!"; }
  config.files.text."/foo/hello.txt" = (lib.importJSON ./hello.json).msg;
  config.files.text."/foo/hellO.txt" = 
    let hello = lib.importTOML ./hello.toml) 
    in hello.msg;
}
```

#### Config

Are values to your options

```nix
{
  config.gh-actions.ci-cd.pre-build = "npm i";
}
```

If your file has only `imports` or `config` we could ommit `config`.

And this file produce the same result

```nix
{
  gh-actions.ci-cd.pre-build = "npm i";
}
```

#### Options

Them we need to learn how to create options.

Lets start with simple example:

We need create our github action file, it could be done as something like this:

```nix
{
  files.yaml."./.github/workflows/ci-cd.yaml" = {
    on = "push";
    # ... rest of github action definition
  };
}
```

As we can see, we aren't hiding complexity and we may copy and past it in every project.

Since most of our config are just: 'get code', 'build', 'test', 'install'

What project user (maybe us) really needs to define is:

```nix
# any module file (maybe project.nix)
{
  # commands required to run your build steps
  files.cmds.aws-cli     = true;
  files.cmds.nodejs-14_x = true;

  # our build steps
  gh-actions.ci-cd.pre-build = "npm i";
  gh-actions.ci-cd.build     = "npm run build";
  gh-actions.ci-cd.test      = "npm run test";
  gh-actions.ci-cd.deploy    = "aws s3 sync ./build s3://some-s3-bucket";
}
```

Now we're hiding (some) complexity.

If we add this to our project.nix we discover that there is no `gh-actions` config available, and command to generate project files fails.

To create it we add `options` definition of that.

```nix
# gh-actions-options.nix
{ lib, ...}:
{
  # defines um gh-actions.ci-cd option of type dict/object/attrset (submodule)
  options.gh-actions.ci-cd = lib.mkOption {
    type = lib.types.submodule {
      # defines a property 'gh-actions.ci-cd.pre-build'
      options.pre-build = lib.mkOption {
        default     = "echo pre-building";
        description = "Command to run before build";
        example     = "npm i";
        type        = lib.types.str;
      };
      # defines a property 'gh-actions.ci-cd.build'
      options.build = lib.mkOption {
        default     = "echo building";
        description = "Command to run as build step";
        example     = "npm run build";
        type        = lib.types.str;
      };
      # defines a property 'gh-actions.ci-cd.test'
      options.test = lib.mkOption {
        default     = "echo testing";
        description = "Command to run as test step";
        example     = "npm test";
        type        = lib.types.str;
      };
      # defines a property 'gh-actions.ci-cd.deploy'
      options.deploy = lib.mkOption {
        default     = "echo deploying";
        description = "Command to run as deploy step";
        example     = "aws s3 sync ./build s3://my-bucket";
        type        = lib.types.str;
      };
    };
    default     = {};
    description = "Configure your github actions CI/CD";
  };
}
```

Good, that is it, now we can set config as we said before, but it does nothing, it doesn't create our yaml file.

Usually people put the next part in same file of previous code, it isn't a requirement, and spliting it here make it simplier to explain.

The cool point is that to create our yaml file we only need one config like we proposed first.

```nix
# gh-actions.nix
{ lib, config, ... }:
{ 
  # import our options definitions
  imports = [ ./gh-actions-options.nix ];

  # define output file usiging user defined configurations
  files.yaml."/.github/workflows/ci-cd.yaml" = {
    on = "push";
    jobs.ci-cd.runs-on = "ubuntu-latest";
    jobs.ci-cd.steps   = [
      { uses = "actions/checkout@v2.4.0"; }
      # read step scripts from `config.gh-actions.ci-cd`
      { name = "Pre Build"; run = config.gh-actions.ci-cd.pre-build; }
      { name = "Build";     run = config.gh-actions.ci-cd.build";    }
      { name = "Test";      run = config.gh-actions.ci-cd.test";     }
      { name = "Deploy";    run = config.gh-actions.ci-cd.deploy";   }
    ];
  };
}
```

Now we only need to import it on our project and set 'pre-build', 'build', 'test' and 'deploy' configs

```nix
# any other module file, maybe project.nix
{
  imports = [ ./gh-actions.nix ];
  gh-actions.ci-cd.pre-build = "echo 'paranaue'";
  gh-actions.ci-cd.build     = "echo 'paranaue parana'";
  gh-actions.ci-cd.build     = "echo 'paranaue'";
  gh-actions.ci-cd.deploy    = ''
    echo "paranaue 
            parana"
  '';
}
```

If we try to set something that is not a string to it, an error will raise, typecheking it.

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

And lib has some modules [helpers functions](https://teu5us.github.io/nix-lib.html#lib.modules.mkif) like:
- lib.mkIf          : to only set a property if some informaiton is true
- lib.optionals     : to return an array or an empty array
- lib.optionalString: to return an array or an empty string
