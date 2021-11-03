# this is one nix file
# see world.nix also as another nix style
{
  config = {
    files = {
      json = {
        "/generated/hello.json" = { hello = "world"; };
      };
      toml = {
        "/generated/hello.toml" = { hello = "world"; };
      };
      yaml = {
        "/generated/hello.yaml" = { hello = "world"; };
      };
      text = {
        "/generated/hello.txt" = ''
          hello world
        '';
      };
    };
  };
}
