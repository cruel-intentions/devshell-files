{pkgs, ...}:{
  # compile nim files and them to shell
  files.nim.helloNim    = ''echo ARGS'';
  # keep an /tmp file with last result for n seconds
  files.nim.memoise     = builtins.readFile ./nim/memoise.nim;
  # clustersSTS is a good candidate to be used with services
  files.nim.clustersSTS = builtins.readFile ./nim/clustersSTS.nim;
  # our poor man jq alternative
  files.nim.jsonildo    = builtins.readFile ./nim/jsonildo.nim;
  files.nim.helloNimAgain.deps = [ pkgs.termbox pkgs.nimPackages.nimbox ];
  files.nim.helloNimAgain.src  = ''
    import nimbox
    proc main() =
      var nb = newNimbox()
      defer: nb.shutdown()
    
      nb.print(0, 0, "Hello, world!")
      nb.present()
      sleep(1000)
    
    when isMainModule:
      main()
  '';
}
