# examples/world.nix
# almost same as previous example
# but show some language feature
let 
  name = "hello"; # a variable
in
{
  config = {
    files = {
      json."/generated/${name}.json".baz = ["foo" "bar" name];
      toml."/generated/${name}.toml".baz = ["foo" "bar" name];
      yaml = {
        "/generated/${name}.yaml" = {
          baz = [
            "foo"
            "bar"
            name
          ];
        };
      };
    };
  };
}
