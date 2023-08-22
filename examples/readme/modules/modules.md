### Module

Modules can be defined in two formats:


#### As attrset, aka. object (JSON), dict (Python):

```nix
{                            #  <|
  imports = [];              #   |
  config  = {};              #   | module info
  options = {};              #   |
}                            #  <|
```

All those attributes are optional

- imports: array  with paths to other modules
- config:  object with actual configurations
- options: object with our config type definition


#### As function:

Functions has following arguments:

- `config` with all evaluated configs values, 
- `pkgs` with all [nixpkgs](https://search.nixos.org/) available.
- `lib` [library](https://teu5us.github.io/nix-lib.html#nixpkgs-library-functions) of useful functions.
- And may receive others (we use `...` to ignore them)

```nix
{ config, pkgs, lib, ... }:  #  <| function args
{                            #  <|
  imports = [];              #   |
  config  = {};              #   | module info
  options = {};              #   |
}                            #  <|
```


#### Imports

Points to other modules files to be imported in this module

```nix
{ 
  imports = [
    ./gh-actions-options.nix
    ./gh-actions-impl.nix
  ];
}
```

Hint, split modules in two files:
- One mostly with options, where your definition goes
- Other with config, where your information goes

It has two advantages, let share options definitions across projects more easily.

And it hides complexity, [hiding complexity is what abstraction is all about](http://mourlot.free.fr/english/fmtaureau.html),
we didn't share options definitions across projects to type less, but because we could reuse an abstraction that helps hiding complexity.


#### Config

Are values to our options

We can set value by ourself, or use lib functions to import json/toml/text files.


```nix
{ lib, ...}:
{
  config.files.text."/HW.txt" = "Hello World!";
  config.files.text."/EO.txt" = lib.concatStringsSep "" ["48" "65" "6c" "6c" "6f"];
  config.files.text."/LR.txt" = (lib.importJSON   ./hello.json).msg; # { "msg": "Hello World!" }
  config.files.text."/LL.txt" = (lib.importTOML   ./hello.toml).msg; # msg = Hello World!
  config.files.text."/OD.txt" = lib.readFile      ./hello.txt;       # Hello World!
}
```

If file has no `options.`, `config.` can be ommited.

And this file produce the same result

```nix
{ lib, ...}:
{
  files.text."/HW.txt" = "Hello World!";
  files.text."/EO.txt" = lib.concatStringsSep "" ["48" "65" "6c" "6c" "6f"];
  files.text."/LR.txt" = (lib.importJSON   ./hello.json).msg; # { "msg": "Hello World!" }
  files.text."/LL.txt" = (lib.importTOML   ./hello.toml).msg; # msg = Hello World!
  files.text."/OD.txt" = lib.readFile      ./hello.txt;       # Hello World!
}
```

#### Options

Options are schema definition for configs values.

Example, to create a github action file, it could be done like this:

```nix
{
  config.files.yaml."/.github/workflows/ci-cd.yaml" = {
    on = "push";
    jobs.ci-cd.runs-on = "ubuntu-latest";
    jobs.ci-cd.steps   = [
      { uses = "actions/checkout@v2.4.0"; }
      { run = "npm i"; }
      { run = "npm run build"; }
      { run = "npm run test"; }
      { run = "aws s3 sync ./build s3://some-s3-bucket"; }
    ];
  };
}
```

This only works because this project has another module with:


```nix
{lib, ...}:
{
  options.files = submodule {
    options.yaml.type = lib.types.attrsOf lib.types.anything;
  };
}
```

But if we always set ci-cd.yaml like that,
no complexity has been hidden, and requires copy and past it in every project.

Since most CI/CD are just: 'Pre Build', 'Build', 'Test', 'Deploy'

What most projects really need is something like:

```nix
# any module file (maybe project.nix)
{
  # our build steps
  config.gh-actions.setup  = "npm i";
  config.gh-actions.build  = "npm run build";
  config.gh-actions.test   = "npm run test";
  config.gh-actions.deploy = "aws s3 sync ./build s3://some-s3-bucket";
}
```

Adding this to project.nix, throws an error `undefined config.gh-actions`, and command fails.

It doesn't knows these options.

To make aware of it, we had to add `options` schema of that.

```nix
# gh-actions-options.nix
{ lib, ...}:
{
  # a property 'gh-actions.setup'
  options.gh-actions.setup = lib.mkOption {
    default     = "echo setup";
    description = "Command to run before build";
    example     = "npm i";
    type        = lib.types.str;
  };
  # a property 'gh-actions.build'
  options.gh-actions.build = lib.mkOption {
    default     = "echo build";
    description = "Command to run as build step";
    example     = "npm run build";
    type        = lib.types.str;
  };
  # a property 'gh-actions.test'
  options.gh-actions.test = lib.mkOption {
    default     = "echo test";
    description = "Command to run as test step";
    example     = "npm test";
    type        = lib.types.str;
  };
  # a property 'gh-actions.deploy'
  options.gh-actions.deploy = lib.mkOption {
    default     = "echo deploy";
    description = "Command to run as deploy step";
    example     = "aws s3 sync ./build s3://my-bucket";
    type        = lib.types.lines;
  };
}
```

Or using `lib.types.fluent`

```nix
# gh-actions-options.nix
{ lib, ...}:
lib.types.fluent {
  options.gh-actions.options = {
    # defines a property 'gh-actions.setup'
    setup.default  = "echo setup";  #default is string
    setup.mdDoc    = "Command to run before build";
    setup.example  = "npm i";
    # defines a property 'gh-actions.build'
    build.default  = "echo build";
    build.mdDoc    = "Command to run as build step";
    build.example  = "npm run build";
    # defines a property 'gh-actions.test'
    test.default   = "echo test";
    test.mdDoc     = "Command to run as test step";
    test.example   = "npm test";
    # defines a property 'gh-actions.deploy'
    deploy.default = "echo deploy";
    deploy.mdDoc   = "Command to run as deploy step";
    deploy.example = "aws s3 sync ./build s3://my-bucket";
    deploy.type    = lib.types.lines;
  };
}
```

Now, previous config can be used, but it does nothing, it doesn't create yaml.

It knowns what options can be accepted as `config`, but not what to do with it.

The following code uses parameter `config` that has all evaluated `config` values.


```nix
# gh-actions.nix
{ config, lib, ... }:
{
  imports = [ ./gh-actions-options.nix ];
  # use other module that simplify file creation to create config file
  files.yaml."/.github/workflows/ci-cd.yaml".jobs.ci-cd.steps   = [
    { uses = "actions/checkout@v2.4.0"; }

    { run  = config.gh-actions.setup;   }  # 
    { run  = config.gh-actions.build;   }  #  Read step scripts from
    { run  = config.gh-actions.test;    }  #  config.gh-actions
    { run  = config.gh-actions.deploy"; }  # 
  ];
  files.yaml."/.github/workflows/ci-cd.yaml".on = "push";
  files.yaml."/.github/workflows/ci-cd.yaml".jobs.ci-cd.runs-on = "ubuntu-latest";
}
```

Now it can be imported and set 'setup', 'build', 'test' and 'deploy' configs

```nix
# any other module file, maybe project.nix
{
  imports = [ ./gh-actions.nix ];
  gh-actions.setup  = "echo 'paranaue'";
  gh-actions.build  = "echo 'paranaue parana'";
  gh-actions.build  = "echo 'paranaue'";
  gh-actions.deploy = ''
    echo "paranaue 
            parana"
  '';
}
```

If something that is not a string is set, an error will raise, cheking it against the options schema.

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
- lib.optionals     : to return an array  or an empty array
- lib.optionalString: to return an string or an empty string
