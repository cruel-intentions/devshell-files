{
  description = "Dev Environment";

  inputs.dsf.url = "github:cruel-intentions/devshell-files";

  outputs = deps: deps.dsf.lib.mkShell [ ./project.nix ];
}
