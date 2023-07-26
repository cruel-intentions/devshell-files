#!/usr/bin/env fish
#
set -l PRJ_SVCS (ls $PRJ_SVCS_DIR)

complete -c svcCtl     -f
complete -c svcCtl     -n "not __fish_seen_subcommand_from $PRJ_SVCS" \
  -a "$PRJ_SVCS"

set -l WAIT_OPTS wd wD wu wU wr wR T
set -l CMDS_OPTS a b q h k t i 1 2 p c y r o d u D U x O
set -l ALLS_OPTS $WAIT_OPTS $WAIT_OPTS
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS  and not __fish_seen_subcommand_from $ALLS_OPTS" \
    -o wd  -d "Wait it is down"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS  and not __fish_seen_subcommand_from $ALLS_OPTS" \
    -o wD  -d "Wait it is down and ready to be brought up"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS  and not __fish_seen_subcommand_from $ALLS_OPTS" \
    -o wu  -d "Wait it is up"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS  and not __fish_seen_subcommand_from $ALLS_OPTS" \
    -o wU  -d "Wait it is up and ready as notified"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS  and not __fish_seen_subcommand_from $ALLS_OPTS" \
    -o wr  -d "Wait it has been started or restarted"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS  and not __fish_seen_subcommand_from $ALLS_OPTS" \
    -o wR  -d "Wait it has been started or restarted and has notified"
complete -c svcCtl     -n "__fish_seen_subcommand_from $WAIT_OPTS and not __fish_seen_subcommand_from $ALLS_OPTS" \
    -s T   -d "if -w option has been given, -T specifies a timeout (in milliseconds)"

complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s z     -d "destroy zombies"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s a     -d "Alarm"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s b     -d "abort"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s h     -d "Reload configuration"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s i     -d "equivalent to -t below"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s t     -d "Terminate"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s q     -d "Quit"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s n     -d "nuke"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
  -s N     -d "Really nuke"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s a   -d "SIGALRM"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s b   -d "SIGABRT"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s q   -d "SIGQUIT"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s h   -d "SIGHUP"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s k   -d "SIGKILL"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s t   -d "SIGTERM"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s i   -d "SIGINT"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s 1   -d "SIGUSR1"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s 2   -d "SIGUSR2"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s p   -d "SIGSTOP"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s c   -d "SIGCONT"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s y   -d "SIGWINCH"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s o   -d "once. Equivalent to -uO".
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s d   -d "down. If is up, send SIGTERM then SIGCONT"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s D   -d "down, and create a ./down so the service does not restart"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s u   -d "up. If is down, start it. Automatically restart"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s U   -d "up, and remove any ./down"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s x   -d "When it is asked to be down and it dies, s6-supervise will exit too."
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s O   -d "mark it to run once at most, do not even start it"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s Q   -d "once at most, and create a ./down file"
complete -c svcCtl     -n "__fish_seen_subcommand_from $PRJ_SVCS and not __fish_seen_subcommand_from $CMDS_OPTS" \
    -s r   -d "If the service is up, restart it"

