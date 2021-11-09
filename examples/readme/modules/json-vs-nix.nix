lib:
let
  nix-examples = import ./nix-examples.nix;
  like-json = map (k: ''| ${k} | `${builtins.toJSON nix-examples.json.${k}}` | `${nix-examples.nix.${k}}` |'') nix-examples.order.like-json;
  unlike-json = map (k: ''| ${k} | | `${nix-examples.unlike-json.${k}}` |'') nix-examples.order.unlike-json;
  examples-header = [ "| name | JSON | NIX |" "| -- | ---- | ---- |"];
  examples = lib.concatStringsSep "\n" (examples-header ++ like-json ++ unlike-json);
in ''
  ### JSON as NIX

  ${examples}
''
