{
  # Enable httplz to your shell
  files.cmds.httplz    = true;

  # Use httplz as service
  # by default httplz will start at .data/services/httplz
  # use an alias to configure it properly
  # if you don't add `exec` it may not receive stop command
  files.alias.httpd    = "exec httplz --port 8022 $PRJ_ROOT";
  files.services.httpd = true;
  # Make S6 start when you enter in shell
  # files.services.s6    = true;
}
