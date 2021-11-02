{pkgs, ...}: 
let yaml = pkgs.formats.yaml {};
in {
  config.file."/generated/hello.yaml".source = yaml.generate "hello.yaml" {
    hello = "World";
  };
}
