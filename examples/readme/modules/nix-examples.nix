{
  json.null = null;
  json. bool = true;
  json.int = 123;
  json.float = 12.3;
  json.string = ''string'';
  json.array = ["some" "array"];
  json.object = { some = "value"; };
  nix.null = ''null'';
  nix.bool = ''true'';
  nix.int = ''123'';
  nix.float = ''12.3'';
  nix.string = ''"string"'';
  nix.array = ''["some" "array"]'';
  nix.object = ''{ some = "value"; }'';
  order.like-json = ["null" "bool" "int" "float" "string" "array" "object"];
  unlike-json.multiline-string = "''... multiline string ... ''";
  unlike-json.variables = ''let my-var = 1; other-var = 2; in my-var + other-var'';
  unlike-json.function = ''my-arg: "Hello ''${my-arg}!"'';
  unlike-json.variable-function = ''let my-function = my-arg: "Hello ''${my-arg}!"; in ...'';
  unlike-json.calling-a-function = ''... in my-function "World"'';
  order.unlike-json = ["multiline-string" "variables" "function" "variable-function" "calling-a-function"];
}
