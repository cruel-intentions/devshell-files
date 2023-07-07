{
  # # Make services start when you enter in shell
  # files.services.initSvcs = true;

  # static http service
  files.cmds.httplz    = true; # Install httplz
  files.services.httpd = true; # Use cmd 'httpd' as service
  files.alias.httpd    = ''
    # This is an alias of httplz
    cd $PRJ_ROOT/gh-pages
    mdbook build

    # IMPORTANT NOTE:
    # if we don't use `exec` it may not stop with stopSvcs
    exec httplz --port 8022 $PRJ_ROOT/gh-pages/book/
  '';

  # greeting service
  files.cmds.notify-desktop = true; # Install notify-desktop
  files.services.greet      = true; # Use cmd 'greet' as service
  files.alias.greet         = ''
    # Greet people
    set +e # ignore errors bacause this service isn't critical
    notify-desktop -i network-server "Welcome"

    # our stdout goes to .data/log/greet
    echo Dornröschen

    # if service ends, it will restarted
    # we sleep emulating some actual service
    exec sleep infinity 
  '';
  files.alias.greet-finish  = ''
    notify-desktop -i network-server "See you later"
  '';

  # This is a service to speedup direnv
  files.direnv.auto-build.enable = true;

  # special service to auto start
  files.services.initSvcs  = true;

  # special service to auto stopSvcs
  files.services.stopSvcsd = true;

  # files.services-opts.tini.enable = true;
  # files.services-opts.namespace.enable = true;

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
