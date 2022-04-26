# this is a example of how to use service and nim
# to create a pomodoro

{ config, lib, pkgs, ... }:
let cfg = config.pomodoro;
in
{
  options.pomodoro.enable   = lib.mkEnableOption "Enable pomodoro timer";
  options.pomodoro.work-for = lib.mkOption {
    example     = 30; # minutes
    type        = lib.types.int;
    description = "For how long should we work, in minutes, before take some rest";
    default     = 25;
  };
  options.pomodoro.work-msg = lib.mkOption {
    example     = "Well I guess you just have to go wake up the gimp now, won't you?";
    type        = lib.types.lines;
    description = "What message should we present to our user";
    default     = "WORK TIME!!!";
  };
  options.pomodoro.rest-for = lib.mkOption {
    example     = 20; # minutes
    type        = lib.types.int;
    description = "For how long should we rest, in minutes, before came back to work";
    default     = 10;
  };
  options.pomodoro.rest-msg = lib.mkOption {
    example     = "Think the gimp sleepin'";
    type        = lib.types.lines;
    description = "What message should we present to our user";
    default     = "COFFE TIME!!!";
  };
  options.pomodoro.msg-icon = lib.mkOption {
    example     = "network-server";
    type        = lib.types.lines;
    description = "gtk icon name";
    default     = "mail-read";
  };
  config.files.cmds.notify-desktop = cfg.enable;
  config.files.services.pomodoro   = cfg.enable;
  # instead of nim a simple bash could do the job
  # but there is no fun on that
  config.files.nim.pomodoro        = lib.mkIf cfg.enable
  ''
  # use 'notify-desktop' as pomodoro
  proc notify(msg: string) =
    discard execCmd fmt"""notify-desktop -i ${cfg.msg-icon} "{msg}" """

  while true:
    notify """${cfg.work-msg}"""
    sleep ${toString cfg.work-for} * 1000 * 60

    # zZZZzzzz
    notify """${cfg.rest-msg}"""
    sleep ${toString cfg.rest-for} * 1000 * 60
  '';
}
