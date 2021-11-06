# examples/world.nix
{
  # if you think structural style is better
  # it works too
  config = {
    files = {
      json = {
        "/generated/hello.json" = { 
          baz = ["foo" "bar"];
        };
      };
      toml = {
        "/generated/hello.toml" = { 
          baz = ["foo" "bar"];
        };
      };
      yaml = {
        "/generated/hello.yaml" = {
          baz = ["foo" "bar"];
        };
      };
    };
  };
}
