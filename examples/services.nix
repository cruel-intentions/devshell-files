{
  # Enable httplz to your shell
  files.cmds.httplz    = true;

  # Use httplz as service
  # by default httplz will start at .data/services/httplz
  # use an alias to configure it properly
  # if you don't add `exec` it may not receive stop command
  files.alias.httpd    = ''
    cd $PRJ_ROOT/gh-pages
    mdbook build
    httplz --port 8022 $PRJ_ROOT/gh-pages/book/
  '';
  files.services.httpd = true;
  # Make services start when you enter in shell
  # files.services.initSrvs = true;

  # RC is another interface it uses s6-rc
  # files.rc.hello.enable  = true;
  # files.rc.hello.oneshot.start    = ''wait 1000000 "hello world"'';
  # files.rc.hello.oneshot.stop     = ''echo "bye bye world"'';
  # files.rc.hello.oneshot.timeout  = 1200;
  # files.rc.olla.enable   = true;
  # files.rc.olla.longrun.start     = ''echo "hello world"'';
  # files.rc.olla.longrun.stop      = ''echo "bye bye world"'';
  # files.rc.olla.longrun.deps      = ["hello"];
  # files.rc.hellos.enable = true;
  # files.rc.hellos.bundle.deps     = ["hello" "olla"];
}
