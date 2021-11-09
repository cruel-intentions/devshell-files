# examples/world.nix
let 
  name = "hello"; # a variable
in  
{
  # if you think structural style is better
  # it works too
  config = {
    files = {
      json = {
        "/generated/${name}.json" = { 
          baz = ["foo" "bar" name];
        };
      };
      toml = {
        "/generated/${name}.toml" = { 
          baz = ["foo" "bar" name];
        };
      };
      yaml = {
        "/generated/${name}.yaml" = {
          baz = ["foo" "bar" name ];
        };
      };
    };
  };
}
