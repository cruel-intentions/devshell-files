{lib, ...}: lib.types.fluent {
  options.files =  {
    options.watch.mdDoc = ''
      Alias that run commands when files changes using inotify
      
      Note: 
      It uses files.services so you should to start services with `initSvcs`.

      Or you could auto start/stop by adding

      ```nix
      files.services.initSvcs  = true;
      files.services.stopSvcsd = true;
      ```
    '';
    options.watch.default = {};
    options.watch.example.FOO.cmd       = "echo $file $dir $time $events";
    options.watch.example.FOO.exclude   = ".+\\.png$";
    options.watch.example.FOO.files     = ''$PRJ_ROOT/src'';
    options.watch.example.FOO.include   = ".+\\.js$";
    options.watch.example.FOO.recursive = true;
    options.watch.example.FOO.event.modify = true;
    options.watch.attrsOf.options = {
      cmd.mdDoc         = "Command that will run with args $file $dir $time $events";
      cmd.type          = lib.types.str;
      enable.default    = true;
      enable.mdDoc      = "Run it when all other services start";
      exclude.default   = "(.*/\\.|.+~$)";
      exclude.mdDoc     = "Regexp to exclude matching files";
      excludei.default  = "";
      excludei.mdDoc    = "Case insesitive regexp to exclude matching files";
      files.default     = "$PRJ_ROOT";
      files.mdDoc       = "Files to be watched";
      files.type        = lib.types.lines;
      follow.default    = false;
      follow.mdDoc      = "Follow symbolic links";
      include.default   = "";
      include.mdDoc     = "Regexp to include only matching files";
      includei.default  = "";
      includei.mdDoc    = "Case insesitive regexp to include only matching files";
      recursive.default = true;
      recursive.mdDoc   = "Recursivelly watch directories";
      timefmt.default   = "%FT%T.000%zZ";
      event.mdDoc       = "What kinds of events must be watched";
      event.default     = {};
      event.options.access.default  = false;
      event.options.attrib.default  = false;
      event.options.close.default   = false;
      event.options.create.default  = false;
      event.options.delete.default  = false;
      event.options.modify.default  = true;
      event.options.move.default    = false;
      event.options.open.default    = false;
      event.options.unmount.default = false;
      event.options.move_from.default      = false;
      event.options.move_to.default        = false;
      event.options.close_nonwrite.default = false;
      event.options.close_write.default    = false;
    };
  };
}
