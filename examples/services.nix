{
  # Enable httplz to your shell
  files.cmds.httplz    = true;

  # Use httplz as service
  # by default httplz will start at .data/services/httplz
  # use an alias to configure it properly
  # if you don't add `exec` it may not receive stop command
  files.alias.httpd    = "exec httplz --port 8022 $PRJ_ROOT/gh-pages/book/";
  files.services.httpd = true;
  # Make services start when you enter in shell
  # files.services.initSrvs = true;
}
