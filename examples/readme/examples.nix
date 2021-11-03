''
  ## Install Examples
  
  <!-- this is also a example o string interpolation -->
  ```nix
  ${builtins.readFile ../../flake.nix}
  ```

  ## Module Examples

  Creating JSON, TEXT, TOML or YAML files

  ```nix
  ${builtins.readFile ../hello.nix}
  ```

  Your file can be complemented with another file

  ```nix
  ${builtins.readFile ../world.nix}
  ```

  Some example of madness

  ```nix
  ${builtins.readFile ./examples.nix}
  ```
''
