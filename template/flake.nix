{
  description = "Dev Environment";

  inputs.dsf.url      = "github:cruel-intentions/devshell-files";

  outputs = inputs: inputs.dsf.lib.shell inputs [
    "hello"        # import nix package
    ./project.nix  # import nix module
  ];
}
