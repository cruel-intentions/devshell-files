# Devshell Files Maker
- [About](#about)
  - [Generate](#generate)
  - [Validate](#validate)
  - [Distribute](#distribute)
- [Instructions](#instructions)
  - [Generating files](#generating-files)
- [Examples](#examples)
  - [Dogfooding](#dogfooding)
- [Writing new modules](#writing-new-modules)
  - [Nix lang](#nix-lang)
  - [JSON as NIX](#json-as-nix)
  - [Modules](#modules)
    - [As function](#as-function)
    - [As object](#as-object)
    - [Options](#options)
  - [Sharing our module](#sharing-our-module)
  - [Document our module](#document-our-module)
- [Builtin modules](#builtin-modules)
- [TODO](#todo)
- [Issues](#issues)
- [See also](#see-also)

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
git add *.nix
git add flake.lock
```

#### Generating files:

```sh
nix develop --build
```

or entering in shell with all commands and alias

```sh
nix develop -c $SHELL
# to list commands and alias
# now run: menu 
```

### Examples

Creating JSON, TEXT, TOML or YAML files

```nix
# examples/hello.nix
#
# this is one nix file
{
  files.json."/generated/hello.json".hello = "world";
  files.toml."/generated/hello.toml".hello = "world";
  files.yaml."/generated/hello.yaml".hello = "world";
  files.hcl."/generated/hello.hcl".hello   = "world";
  files.text."/generated/hello.txt" = "world";
}

```

Your file can be complemented with another module

```nix
# examples/world.nix
# almost same as previous example
# but show some language feature
let 
  name = "hello"; # a variable
in
{
  files = {
    json."/generated/${name}.json".baz = ["foo" "bar" name];
    toml."/generated/${name}.toml".baz = ["foo" "bar" name];
    yaml = {
      "/generated/${name}.yaml" = {
        baz = [
          "foo"
          "bar"
          name
        ];
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
    ./examples/gitignore.nix
    ./examples/license.nix
    ./examples/docs.nix
    ./examples/book.nix
    ./examples/services.nix
    ./examples/nim.nix
    ./examples/nushell.nix
  ];

  # install development or deployment tools
  packages = [
    "convco"
    # now we can use 'convco' command https://convco.github.io

    # but could be:
    # "awscli"
    # "azure-cli"
    # "cargo"
    # "conda"
    # "go"
    # "nim"
    # "nodejs"
    # "nodejs-18_x"
    # "nushell"
    # "pipenv"
    # "python39"
    # "ruby"
    # "rustc"
    # "terraform"
    # "yarn"
    # look at https://search.nixos.org for more packages
  ];

  # create alias
  files.alias.feat = ''convco commit --feat $@'';
  files.alias.fix  = ''convco commit --fix  $@'';
  files.alias.docs = ''convco commit --docs $@'';
  files.alias.alou = ''
    #!/usr/bin/env python
    print("Alo!") # is hello in portuguese
  '';

  # now we can use feat, fix, docs and alou commands

  # create .envrc for direnv
  files.direnv.enable = true;
}

```

This README.md is also a module defined as above

```nix
# There is a lot things we could use to write static file
# Basic intro to nix language https://github.com/tazjin/nix-1p
# Some nix functions https://teu5us.github.io/nix-lib.html
{lib, ...}:
{
  files.text."/README.md" = builtins.concatStringsSep "\n" [
    "# Devshell Files Maker"
    (builtins.readFile ./readme/toc.md)
    (builtins.readFile ./readme/about.md)
    (builtins.readFile ./readme/installation.md)
    (builtins.import ./readme/examples.nix)
    ((builtins.import ./readme/modules.nix) lib)
    (builtins.readFile ./readme/todo.md)
    (builtins.readFile ./readme/issues.md)
    (builtins.readFile ./readme/seeAlso.md)
  ];
}

```

Our .gitignore is defined like this
```nix
# ./examples/gitignore.nix
{
  # create my .gitignore coping ignore patterns from
  # github.com/github/gitignore
  files.gitignore.enable = true;
  files.gitignore.template."Global/Archives" = true;
  files.gitignore.template."Global/Backup"   = true;
  files.gitignore.template."Global/Diff"     = true;
  files.gitignore.pattern."**/.data"         = true;
  files.gitignore.pattern."**/.direnv"       = true;
  files.gitignore.pattern."**/.envrc"        = true;
  files.gitignore.pattern."**/.gitignore"    = true;
  files.gitignore.pattern."**/flake.lock"    = true;
}

```

And our LICENSE file is
```nix
# ./examples/license.nix
{
  # LICENSE file creation
  # using templates from https://github.com/spdx/license-list-data
  files.license.enable = true;
  files.license.spdx.name = "MIT";
  files.license.spdx.vars.year = "2023";
  files.license.spdx.vars."copyright holders" = "Cruel Intentions";
}

```

## Writing new modules

### Nix lang

Jump this part if aready know Nix Lang, if don't there is a small concise content of [Nix Lang](https://github.com/tazjin/nix-1p).

If one page is too much to you, the basic is:

- `:` defines a new function, `arg: "Hello ${arg}"`
- that's why we use `=` instaed of `:`, `{ attr-key = "value"; }`
- `;` instead of `,` and they **aren't optional**
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

### Module

Modules can be defined in two formats:


#### As attrset, aka. object (JS), dict (Python):

```nix
{                            #  <|
  imports = [];              #   |
  config  = {};              #   | module result
  options = {};              #   |
}                            #  <|
```


#### As function:

Functions has following arguments:

- `config` with all evaluated configs values, 
- `pkgs` with all [nixpkgs](https://search.nixos.org/) available.
- `lib` [library](https://teu5us.github.io/nix-lib.html#nixpkgs-library-functions) of useful functions.
- And may receive others (use `...` to ignore them)

```nix
{ config, pkgs, lib, ... }:  #  <| function args
{                            #  <|
  imports = [];              #   |
  config  = {};              #   | module result
  options = {};              #   |
}                            #  <|
```


All those attributes are optional

- imports: array  with paths to other modules
- config:  object with actual configurations
- options: object with our config type definition

Hint, split modules in two files:
- One mostly with options, where your definition goes
- Other with config, where your information goes

It has two advantages, let share options definitions across projects more easily.

And it hides complexity, [hiding complexity is what abstraction is all about](http://mourlot.free.fr/english/fmtaureau.html),
we didn't share options definitions across projects to type less, but because we could reuse an abstraction that helps hiding complexity.


#### Imports

Points to other modules files to be imported in this module

```nix
{ 
  imports = [
    ./gh-actions-options.nix
    ./some-other-module.nix
  ];
}
```


#### Config

Are values to our options

```nix
{
  config.gh-actions.setup = "npm i";
}
```

Use builtin functions to import nix/json/toml/text files.

```nix
{ lib, ...}:
{
  config.files.text."/hi.txt" = (builtins.import  ./hello.nix ).msg; # { msg = "Hello World!"; }
  config.files.text."/hI.txt" = (lib.importJSON   ./hello.json).msg; # { "msg": "Hello World!" }
  config.files.text."/h1.txt" = (lib.importTOML   ./hello.toml).msg; # msg = Hello World!
  config.files.text."/Hi.txt" = builtins.readFile ./hello.txt;       # Hello World!
}
```

If file has no `options.`, `config.` can be ommited.

And this file produce the same result

```nix
{ lib, ...}:
{
  files.text."/hi.txt" = (builtins.import  ./hello.nix ).msg; # { msg = "Hello World!"; }
  files.text."/hI.txt" = (lib.importJSON   ./hello.json).msg; # { "msg": "Hello World!" }
  files.text."/h1.txt" = (lib.importTOML   ./hello.toml).msg; # msg = Hello World!
  files.text."/Hi.txt" = builtins.readFile ./hello.txt;       # Hello World!
  gh-actions.setup = "npm i";
}
```

#### Options

Options are schema definition for config.

Example, to create a github action file, it could be done like this:

```nix
{
  files.yaml."/.github/workflows/ci-cd.yaml" = {
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

No complexity has been hidden, and requires copy and past it in every project.

Since most CI/CD are just: 'Pre Build', 'Build', 'Test', 'Deploy'

What project user really needs to define is:

```nix
# any module file (maybe project.nix)
{
  # our build steps
  gh-actions.setup  = "npm i";
  gh-actions.build  = "npm run build";
  gh-actions.test   = "npm run test";
  gh-actions.deploy = "aws s3 sync ./build s3://some-s3-bucket";
}
```

Adding this to project.nix, throw an error `undefined config.gh-actions`, and command fails.

To create it, add `options` definition of that.

```nix
# gh-actions-options.nix
{ lib, ...}:
{
  # defines a property 'gh-actions.setup'
  options.gh-actions.setup = lib.mkOption {
    default     = "echo setuping";
    description = "Command to run before build";
    example     = "npm i";
    type        = lib.types.str;
  };
  # defines a property 'gh-actions.build'
  options.gh-actions.build = lib.mkOption {
    default     = "echo building";
    description = "Command to run as build step";
    example     = "npm run build";
    type        = lib.types.str;
  };
  # defines a property 'gh-actions.test'
  options.gh-actions.test = lib.mkOption {
    default     = "echo testing";
    description = "Command to run as test step";
    example     = "npm test";
    type        = lib.types.str;
  };
  # defines a property 'gh-actions.deploy'
  options.gh-actions.deploy = lib.mkOption {
    default     = "echo deploying";
    description = "Command to run as deploy step";
    example     = "aws s3 sync ./build s3://my-bucket";
    type        = lib.types.str;
  };
}
```

Now, previous config can be used, but it does nothing, it doesn't create yaml.

It knowns what options can be accepted as `config`, but not what to do with it.

Usually the next part is in same file of `options`, it isn't a requirement, and spliting it here make it simplier to explain.


```nix
# gh-actions.nix
{ config, lib, ... }:
{
  # use other module that simplify file creation to create config file
  files.yaml."/.github/workflows/ci-cd.yaml".jobs.ci-cd.steps   = [
    { uses = "actions/checkout@v2.4.0"; }

    { run  = config.gh-actions.setup;   }  # 
    { run  = config.gh-actions.build";  }  #  Read step scripts from
    { run  = config.gh-actions.test";   }  #  config.gh-actions
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
  imports = [ ./gh-actions-options.nix ./gh-actions.nix ];
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

### Sharing our module

Now to not just copy and past it everywhere, we could create a git repository, ie. [gh-actions](https://github.com/cruel-intentions/gh-actions)

Then we could let nix manage it for us adding it to flake.nix file like

```nix
{
  description = "Dev Environment";

  inputs.dsf.url = "github:cruel-intentions/devshell-files";
  inputs.gha.url = "github:cruel-intentions/gh-actions";
  # for private repository use git url
  # inputs.gha.url = "git+ssh://git@github.com/cruel-intentions/gh-actions.git";

  outputs = inputs: inputs.dsf.lib.mkShell [
    "${inputs.gha}/gh-actions.nix"
    ./project.nix
  ];
}
```

Or manage version adding it directly to project.nix (or any other module file)

```nix
{
  imports = 
    let gh-actions = builtins.fetchGit {
      url = "git+ssh://git@github.com/cruel-intentions/gh-actions.git";
      ref = "master";
      rev = "46eead778911b5786d299ecf1a95c9ed4c130844";
    };
    in [
      "${gh-actions}/gh-actions.nix"
    ];
}
```

### Document our module

To documento our modules is simple, we just need to use `config.files.docs` as follow

```nix
# examples/docs.nix

{lib, pkgs, ...}:
{
  files.docs."/gh-pages/src/modules/alias.md".modules     = [ ../modules/alias.nix       ];
  files.docs."/gh-pages/src/modules/cmds.md".modules      = [ ../modules/cmds.nix        ];
  files.docs."/gh-pages/src/modules/files.md".modules     = [ ../modules/files.nix       ];
  files.docs."/gh-pages/src/modules/git.md".modules       = [ ../modules/git.nix         ];
  files.docs."/gh-pages/src/modules/gitignore.md".modules = [ ../modules/gitignore.nix   ];
  files.docs."/gh-pages/src/modules/hcl.md".modules       = [ ../modules/hcl.nix         ];
  files.docs."/gh-pages/src/modules/json.md".modules      = [ ../modules/json.nix        ];
  files.docs."/gh-pages/src/modules/mdbook.md".modules    = [ ../modules/mdbook.nix      ];
  files.docs."/gh-pages/src/modules/nim.md".modules       = [ ../modules/nim.nix         ];
  files.docs."/gh-pages/src/modules/nushell.md".modules   = [ ../modules/nushell.nix     ];
  files.docs."/gh-pages/src/modules/rc.md".modules        = [ ../modules/services/rc-devshell.nix ];
  files.docs."/gh-pages/src/modules/services.md".modules  = [ ../modules/services.nix    ];
  files.docs."/gh-pages/src/modules/spdx.md".modules      = [ ../modules/spdx.nix        ];
  files.docs."/gh-pages/src/modules/text.md".modules      = [ ../modules/text.nix        ];
  files.docs."/gh-pages/src/modules/toml.md".modules      = [ ../modules/toml.nix        ];
  files.docs."/gh-pages/src/modules/yaml.md".modules      = [ ../modules/yaml.nix        ];
}

```

<details>
<summary>We could also generate a mdbook with it</summary>
<br>


```nix
# examples/book.nix

{lib, ...}:
let
  project   = "devshell-files";
  author    = "cruel-intentions";
  org-url   = "https://github.com/${author}";
  edit-path = "${org-url}/${project}/edit/master/guide/{path}";
in
{
  files.mdbook.authors      = ["Cruel Intentions <${org-url}>"];
  files.mdbook.enable       = true;
  files.mdbook.gh-author    = author;
  files.mdbook.gh-project   = project;
  files.mdbook.language     = "en";
  files.mdbook.multilingual = false;
  files.mdbook.summary      = builtins.readFile ./summary.md;
  files.mdbook.title        = "Nix DevShell Files Maker";
  files.mdbook.output.html.edit-url-template   = edit-path;
  files.mdbook.output.html.fold.enable         = true;
  files.mdbook.output.html.git-repository-icon = "fa-github";
  files.mdbook.output.html.git-repository-url  = "${org-url}/${project}";
  files.mdbook.output.html.no-section-label    = true;
  files.mdbook.output.html.site-url            = "/${project}/";
  files.gitignore.pattern.gh-pages             = true;
  files.text."/gh-pages/src/introduction.md" = builtins.readFile ./readme/about.md;
  files.text."/gh-pages/src/installation.md" = builtins.readFile ./readme/installation.md;
  files.text."/gh-pages/src/examples.md"     = builtins.import   ./readme/examples.nix;
  files.text."/gh-pages/src/modules.md"      = "## Writing new modules";
  files.text."/gh-pages/src/nix-lang.md"     = builtins.readFile ./readme/modules/nix-lang.md;
  files.text."/gh-pages/src/json-nix.md"     = builtins.import   ./readme/modules/json-vs-nix.nix lib;
  files.text."/gh-pages/src/module-spec.md"  = builtins.readFile ./readme/modules/modules.md;
  files.text."/gh-pages/src/share.md"        = builtins.readFile ./readme/modules/share.md;
  files.text."/gh-pages/src/document.md"     = builtins.import   ./readme/modules/document.nix;
  files.text."/gh-pages/src/builtins.md"     = builtins.readFile ./readme/modules/builtins.md;
  files.text."/gh-pages/src/todo.md"         = builtins.readFile ./readme/todo.md;
  files.text."/gh-pages/src/issues.md"       = builtins.readFile ./readme/issues.md;
  files.text."/gh-pages/src/seeAlso.md"      = builtins.readFile ./readme/seeAlso.md;
  files.alias.publish-as-gh-pages-from-local = ''
    # same as publish-as-gh-pages but works local
    cd $PRJ_ROOT
    ORIGIN=`git remote get-url origin`
    cd gh-pages
    mdbook build
    cd book
    git init .
    git add .
    git checkout -b gh-pages
    git commit -m "docs(gh-pages): update gh-pages" .
    git remote add origin $ORIGIN
    git push -u origin gh-pages --force
  '';  
}

```


</details>


And publish this mdbook to github pages with `book-as-gh-pages` alias.


## Builtin Modules

Builtin Modules are modules defined with this same package.

They are already included when we use this package.

- `files.alias`, create bash script alias
- `files.cmds`, install packages from [nix repository](https://search.nixos.org/)
- `files.docs`, convert our modules file into markdown using [nmd](https://gitlab.com/rycee/nmd)
- `files.git`, configure git with file creation
- `files.gitignore`, copy .gitignore from [templates](https://github.com/github/gitignore/)
- `files.hcl`, create HCL files with nix syntax
- `files.json`, create JSON files with nix syntax
- `files.mdbook`, convert your markdown files to HTML using [mdbook](https://rust-lang.github.io/mdBook/)
- `files.nim`, similar to `files.alias`, but compiles [Nim](https://github.com/nim-lang/Nim/wiki#getting-started) code
- `files.nus`, similar to `files.alias`, but runs in [Nushell](https://www.nushell.sh/)
- `files.services`, process supervisor for development services using [s6](http://skarnet.org/software/s6)
- `files.rc` , WIP, process supervisor for development services using [s6-rc](http://skarnet.org/software/s6-rc)
- `files.spdx`, copy LICENSE from [templates](https://github.com/spdx/license-list-data/tree/master/text)
- `files.text`, create free text files with nix syntax
- `files.toml`, create TOML files with nix syntax
- `files.yaml`, create YAML files with nix syntax


Our [documentation](https://cruel-intentions.github.io/devshell-files/) is generated by `files.text`, `files.docs` and `files.mdbook`



## TODO

- Add modules for especific cases:
  - ini files
  - most common ci/cd configuration
- Verify if devshell could add it as default

## Issues

This project uses git as version control, if your are using other version control system it may not work.

### See also
* [Nix](https://nixos.org/) the tool
* [DevShell](https://github.com/numtide/devshell) the framework
* [Digga](https://github.com/divnix/digga) similar project
* [Makes](https://github.com/fluidattacks/makes) similar project
* [Nixago](https://github.com/jmgilman/nixago) similar project
* [Home Manager](https://github.com/nix-community/home-manager) similar project (for user home configs)
* [NixOS](https://nixos.org/) similar project (for system configs)
* [Nix Ecosystem](https://nixos.wiki/wiki/Nix_Ecosystem) more projects using same tool
* [Nix.Dev](https://nix.dev/)
* [Nixology](https://www.youtube.com/watch?v=NYyImy-lqaA&list=PLRGI9KQ3_HP_OFRG6R-p4iFgMSK1t5BHs)

### Don't look at
* `*nix`       general definition of Unix/Linux
* Nixos.com    NSFW
* Nixos.com.br furniture
