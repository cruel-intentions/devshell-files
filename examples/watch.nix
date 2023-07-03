{
  # required
  # we could call watch-this-project in the shell
  # or start it and all other services with initSvcs
  files.watch.watch-this-project.cmd = "echo $file $dir $time $events";
  # optional
  # files.watch.wathc-this-project.enable    = true;
  # files.watch.wathc-this-project.exclude   = "(.*/\\.|.+~$)";
  # files.watch.wathc-this-project.excludei  = "";
  # files.watch.wathc-this-project.files     = "$PRJ_ROOT";
  # files.watch.wathc-this-project.follow    = false;
  # files.watch.wathc-this-project.include   = "";
  # files.watch.wathc-this-project.includei  = "";
  # files.watch.wathc-this-project.recursive = true;
  # files.watch.wathc-this-project.timefmt   = "%FT%T.000%zZ";
  # files.watch.wathc-this-project.event     = {};
  # files.watch.wathc-this-project.event.access  = false;
  # files.watch.wathc-this-project.event.attrib  = false;
  # files.watch.wathc-this-project.event.close   = false;
  # files.watch.wathc-this-project.event.create  = false;
  # files.watch.wathc-this-project.event.delete  = false;
  # files.watch.wathc-this-project.event.modify  = true;
  # files.watch.wathc-this-project.event.move    = false;
  # files.watch.wathc-this-project.event.open    = false;
  # files.watch.wathc-this-project.event.unmount = false;
  # files.watch.wathc-this-project.event.move_from      = false;
  # files.watch.wathc-this-project.event.move_to        = false;
  # files.watch.wathc-this-project.event.close_nonwrite = false;
  # files.watch.wathc-this-project.event.close_write    = false;
}
