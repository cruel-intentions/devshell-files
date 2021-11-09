{
  json = {
    null = null;
    bool = true;
    int = 123;
    float = 12.3;
    string = ''string'';
    array = ["some" "array"];
    object = { some = "value"; };
  };
  nix = {
    null = ''null'';
    bool = ''true'';
    int = ''123'';
    float = ''12.3'';
    string = ''"string"'';
    array = ''["some" "array"]'';
    object = ''{ some = "value"; };'';
  };
  unlike-json = {
    multiline-string = "''... multiline string ... ''";
    variables = ''let my-var = 1; other-var = 2; in my-var + other-var'';
    function = ''my-arg: "Hello ''${my-arg}!"'';
    variable-function = ''let my-function = my-arg: "Hello ''${my-arg}!"; in ...'';
    calling-a-function = ''... in my-function "World"'';
  };
}
