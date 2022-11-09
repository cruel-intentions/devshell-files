{
  # command accept name arg
  files.nus.hello-nu = ["name: string # someone's name" ''{ Hello: $name }''];
  # command call previous command
  files.nus.nu-world = ''hello-nu World|to json'';
  # command call previous command too
  files.nus.nus-wrld = [''nu-world|from json|to yaml''];
  # nushell command to convert string formats
  files.nus.nuons    = import ./nushell/nuon.nix;
  # nushell command to create pseudo files
  files.nus.psub     = import ./nushell/psub.nix;
  files.nus.test_psub= ["msg" ''
    let pseudoFile = (psub 'echo limpinho')
    echo $"file name is ($pseudoFile)"
    echo 'and content is:'
    # open $pseudoFile|collect { |x| echo $x }
  ''];
}
