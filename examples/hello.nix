# examples/hello.nix
#
# this is one nix file
{
  files.json."/generated/hello.json".hello = "world";
  files.toml."/generated/hello.toml".hello = "world";
  files.yaml."/generated/hello.yaml".hello = "world";
  files.hcl."/generated/hello.hcl".hello   = "world";
  files.text."/generated/hello.txt" = "world";
}
