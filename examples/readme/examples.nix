''
  ## Examples

  Creating JSON, TEXT, TOML or YAML files

  ```nix
  ${builtins.readFile ../hello.nix}
  ```

  Your file can be complemented with another file

  ```nix
  ${builtins.readFile ../world.nix}
  ```

  Content generated by those examples are in [./generated/](./generated/)

  ```YAML
  # ie ./generated/hello.yaml
  ${builtins.readFile ../../generated/hello.yaml}
  ```

  [/generated/hello.yaml](./generated/hello.yaml)

  This README.md is also a module
  ```nix
  ${builtins.readFile ../readme.nix}
  ```

  ### Configuration Examples

  To integrate it with existing project

  Copy files of [template](./template/) to your project

  ```nix
  ${builtins.readFile ../../template/flake.nix}
  ```

  ```nix
  ${builtins.readFile ../../template/my-project-module.nix}
  ```
''
