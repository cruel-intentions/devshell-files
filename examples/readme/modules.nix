lib:
let
  nix-examples = import ./modules/nix-examples.nix;
  like-json = lib.mapAttrsToList (k: v: ''| ${k} | `${builtins.toJSON v}` | `${nix-examples.nix.${k}}` |'') nix-examples.json;
  unlike-json = lib.mapAttrsToList (k: v: ''| ${k} | | `${toString v}` |'') nix-examples.unlike-json;
  examples-header = [ "| name | JSON | NIX |" "| ---- | ---- | ---- |"];
  examples = lib.concatStringsSep "\n" (examples-header ++ like-json ++ unlike-json);
in
''
  ## Writing new modules

  #### Nix lang

  There is an small concise content of [Nix Lang](https://github.com/tazjin/nix-1p).

  If one page is too much to you, let just say, think about JSON except:

  * `:` defines a new function, `name: "Hello ''${name}"`
  * that's why we use `=` instaed of `:`, `{ attr-key = "value"; }`
  * `;` instead of `,` and they aren't optional
  * Array aren't separated by `,` as `[ "some" "value" ]`

  #### JSON as NIX

  ${examples}


  #### Modules

  Modules could be defined in two formats: Functions that return an Object or just Object without any function resulting it.

  These functions has at least these nameds params: 

  * `config` with all evaluated configs values, 
  * `pkgs` with all [nixpkgs](https://search.nixos.org/) available.
  * `lib` [library](https://teu5us.github.io/nix-lib.html#nixpkgs-library-functions) of useful functions.

  And may receive other named params (use `...` to ignore them)

  Nix function with named params:

  ```nix
  { config, pkgs, ...}: 
  { imports = []; config = {}; options = {}; }
  ```
''
