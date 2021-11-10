# devshell-files

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

With help of [Nix](https://nixos.org/guides/how-nix-works.html) and [devshell](https://github.com/numtide/devshell) you could install any development or deployment tool of its [80 000](https://search.nixos.org/) packages.

## Instructions

Installing [Nix](https://nixos.wiki/wiki/Flakes)

```sh
curl -L https://nixos.org/nix/install | sh

nix-env -f '<nixpkgs>' -iA nixUnstable

mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

Configuring new projects:

```sh
nix flake new -t github:cruel-intentions/devshell-files my-project
cd my-project
git init
git add .
```

Configuring existing projects:

```sh
nix flake new -t github:cruel-intentions/devshell-files ./
git add flake.nix, flake.lock project.nix
```

#### Generating files:

```sh
nix develop -c $SHELL
```

### Examples

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

Your file can be complemented with another module

```nix
# examples/world.nix
let 
  name = "hello"; # a variable
in  
{
  # if you think structural style is better
  # it works too
  config = {
    files = {
      json = {
        "/generated/${name}.json" = { 
          baz = ["foo" "bar" name];
        };
      };
      toml = {
        "/generated/${name}.toml" = { 
          baz = ["foo" "bar" name];
        };
      };
      yaml = {
        "/generated/${name}.yaml" = {
          baz = ["foo" "bar" name ];
        };
      };
    };
  };
}

```

Content generated by those examples are in [generated](./generated/)

```YAML
# ie ./generated/hello.yaml
baz:
- foo
- bar
- hello
hello: world

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
  # create my .gitignore coping ignore patterns from
  # github.com/github/gitignore
  config.files.gitignore.enable = true;
  config.files.gitignore.template."Global/Archives" = true;
  config.files.gitignore.template."Global/Backup" = true;
  config.files.gitignore.template."Global/Diff" = true;
  # install development or deployment tools
  # now we can use 'convco' command
  config.files.cmds.convco = true;
  # now we can use 'feat' command (alias to convco)
  config.files.alias.feat = ''convco commit --feat $@'';
  config.files.alias.fix = ''convco commit --fix $@'';
  # use the command 'menu' to list commands
}

```

This README.md is also a module defined as above

```nix
# There is a lot things we could use to write static file
# Basic intro to nix language https://github.com/tazjin/nix-1p
# Some nix functions https://teu5us.github.io/nix-lib.html
{lib, ...}:
{
  config.files.text."/README.md" = builtins.concatStringsSep "\n" [
    (builtins.readFile ./readme/title.md)
    (builtins.readFile ./readme/installation.md)
    (builtins.import ./readme/examples.nix)
    (builtins.readFile ./readme/todo.md)
    (builtins.readFile ./readme/issues.md)
    ((builtins.import ./readme/modules.nix) lib)
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

## Writing new modules

### Nix lang

Jump this part if aready know Nix Lang, if don't there is an small concise content of [Nix Lang](https://github.com/tazjin/nix-1p).

If one page is too much to you, the basic is:

- `:` defines a new function, `name: "Hello ''${name}"`
- that's why we use `=` instaed of `:`, `{ attr-key = "value"; }`
- `;` instead of `,` and they aren't optional
- array aren't separated by `,` ie. `[ "some" "value" ]`


### JSON as NIX

| name | JSON | NIX |
| -- | ---- | ---- |
| null | `null` | `null` |
| bool | `true` | `true` |
| int | `123` | `123` |
| float | `12.3` | `12.3` |
| string | `"string"` | `"string"` |
| array | `["some","array"]` | `["some" "array"]` |
| object | `{"some":"value"}` | `{ some = "value"; }` |
| multiline-string | | `''... multiline string ... ''` |
| variables | | `let my-var = 1; other-var = 2; in my-var + other-var` |
| function | | `my-arg: "Hello ${my-arg}!"` |
| variable-function | | `let my-function = my-arg: "Hello ${my-arg}!"; in ...` |
| calling-a-function | | `... in my-function "World"` |

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

The cool point is that to create our yaml file we only need one config we proposed first.

```nix
{ lib, config, ... }:
{ 
  config.files.yaml."/.github/workflows/ci-cd" = {
    on = "push";
    jobs.ci-cd.runs-on = "ubuntu-latest";
    jobs.ci-cd.steps = [
      { uses = "actions/checkout@v1"; }
      { uses = "cachix/install-nix-action@v13"; with.nix_path = "channel:nixos-unstable"; }
      { run = "nix develop"; }
      # this config comes from arguments
      { run = config.gh-actions.ci-cd.pre-build; }
      { run = config.gh-actions.ci-cd.build; }
      { run = config.gh-actions.ci-cd.test; }
      { run = config.gh-actions.ci-cd.deploy; }
    ]
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

