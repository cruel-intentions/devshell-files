{
  description = "Dev Environment";

  inputs.dsf.url = "github:cruel-intentions/devshell-files";

  outputs = in: in.dsf.lib.mkShell [ ./project.nix ];
}
