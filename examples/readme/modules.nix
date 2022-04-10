lib:
''
  ## Writing new modules

  ${builtins.readFile ./modules/nix-lang.md}
  ${builtins.import   ./modules/json-vs-nix.nix lib}
  ${builtins.readFile ./modules/modules.md}
  ${builtins.readFile ./modules/share.md}
  ${builtins.import   ./modules/document.nix}
  ${builtins.readFile ./modules/builtins.md}
''
