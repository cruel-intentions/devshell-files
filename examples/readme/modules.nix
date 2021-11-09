lib:
''
  ## Writing new modules

  ${builtins.readFile ./modules/nix-lang.md}
  ${builtins.import ./modules/json-vs-nix.nix lib}
  ${builtins.readFile ./modules/modules.md}
''
