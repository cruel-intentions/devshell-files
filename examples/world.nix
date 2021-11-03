# examples/world.nix
{
  config.files.json."/generated/hello.json".world = "hello";
  config.files.toml."/generated/hello.toml".world = "hello";
  config.files.yaml."/generated/hello.yaml".world = "hello";
}
