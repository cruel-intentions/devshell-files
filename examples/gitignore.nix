{
  # create my .gitignore copying ignore patterns from
  # github.com/github/gitignore
  files.gitignore.enable = true;
  files.gitignore.template."Global/Archives" = true;
  files.gitignore.template."Global/Backup"   = true;
  files.gitignore.template."Global/Diff"     = true;
  files.gitignore.pattern."**/.data"         = true;
  files.gitignore.pattern."**/.direnv"       = true;
  files.gitignore.pattern."**/.envrc"        = true;
  files.gitignore.pattern."**/.gitignore"    = true;
  files.gitignore.pattern."**/flake.lock"    = true;
}
