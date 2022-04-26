{
  # # Make services start when you enter in shell
  # files.services.initSrvs = true;

  # static http service
  files.cmds.httplz    = true; # Install httplz
  files.services.httpd = true; # Use cmd 'httpd' as service
  files.alias.httpd    = ''
    # This is an alias of httplz
    cd $PRJ_ROOT/gh-pages
    mdbook build
    httplz --port 8022 $PRJ_ROOT/gh-pages/book/
  '';

  # greeting service
  files.cmds.notify-desktop = true; # Install notify-desktop
  files.services.greet      = true; # Use cmd 'greet' as service
  files.alias.greet         = ''
    # Greet people
    notify-desktop -i network-server "Starting services";

    echo Dornröschen  # our service stdout goes to .data/log/greet
    sleep infinity    # any service should run infinitely
  '';
  files.alias.greet-finish  = ''
    notify-desktop -i network-server "Stoping services"
  '';


  # # RC (unstable) is another interface it uses s6-rc
  # # http://skarnet.org/software/s6-rc/why.html
  #
  # files.rc.hello.enable  = true;
  # files.rc.hello.oneshot.start    = ''wait 1000000 "hello world"'';
  # files.rc.hello.oneshot.stop     = ''echo "bye bye world"'';
  # files.rc.hello.oneshot.timeout  = 1200;
  #
  # files.rc.olla.enable   = true;
  # files.rc.olla.longrun.start     = ''echo "hello world"'';
  # files.rc.olla.longrun.stop      = ''echo "bye bye world"'';
  # files.rc.olla.longrun.deps      = ["hello"];
  #
  # files.rc.hellos.enable = true;
  # files.rc.hellos.bundle.deps     = ["hello" "olla"];
}
