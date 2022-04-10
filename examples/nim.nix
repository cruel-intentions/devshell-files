{
  # compile nim files and them to shell
  files.nim.helloNim    = ''echo "Hello Nim World!"'';
  files.nim.memoise     = builtins.readFile ./nim/memoise.nim;
  # clustersSTS is a good candidate to be used as service
  files.nim.clustersSTS = builtins.readFile ./nim/clustersSTS.nim;
}
