{pkgs, lib, ...}: 
let 
  cfg = config.services.hello;
  yaml = pkgs.formats.yaml {};
in {
  options.services.hello.enable = lib.mkEnableOption "Create some hello.yaml";
  options.services.hello.settings = mkOption {
    type = yaml.type;
    description = "Hello Would content";
    default.hello = "World";
  };
  config = mkIf cfg.enable {
    file."/hello.yaml".source = yaml.generate "hello.yaml" {
      hello = "World";
    };
  };
}
