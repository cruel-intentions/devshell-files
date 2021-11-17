{lib, ...}:
let
  mkOptions = n: attrs: {
    options = builtins.mapAttrs (name: value: lib.mkOption value) attrs;
  };
  ifDef = fn: value: if value == null then "" else fn value;
  dashToDot = builtins.replaceString ["-"] ["."];
  dockerDocsUrl = "https://docs.docker.com/engine/reference/builder/";
  listOrNonEmptyStr = lib.types.oneOf [(lib.types.listOf lib.types.nonEmptyStr) lib.types.nonEmptyStr];
  attrsOfNonEmptyStr = lib.types.attrsOf lib.types.nonEmptyStr;
  nullOrNonEmptyStr = lib.types.nullOr lib.types.nonEmptyStr;
  stopSignals = ["SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGTRAP" "SIGABRT" "SIGBUS" "SIGFPE" "SIGKILL" "SIGUSR1" "SIGEGV" "SIGUSR2" "SIGPIPE" "SIGALRM" "SIGTERM" "SIGSTKFLT" "SIGCHLD " "SIGCONT" "SIGSTOP" "SIGTSTP" "SIGTTIN" "SIGTTOU" "SIGURG" "SIGXCPU" "SIGXFSZ" "SIGVTALRM" "SIGPROF" "SIGWINCH" "SIGIO" "SIGPOLL" "SIGPWR" "SIGSYS"];
  toDockerfile.from = opt: [
    (ifDef (v: "# syntax=${v}\n") opt.syntax or null)
    (ifDef (v: "# escape=${v}\n") opt.syntax or null)
    "FROM "
    (ifDef (v: "--plataform=${v} ") opt.plataform or null)
    (ifDef (v: v) opt.from or null)
    (ifDef (v: ":${v}") opt.tag or null)
    (ifDef (v: "@${v}") opt.digest or null)
    (ifDef (v: " as ${v}") opt.name or null)
    "\n"
  ];
  toDockerfile.run = opt:
    if builtins.isList opt.run 
    then ["RUN " (builtins.toJSON opt.run) "\n"]
    else ["RUN " opt.run "\n"];
  toDockerfile.cmd = opt:
    if builtins.isList opt.cmd 
    then ["CMD " (builtins.toJSON opt.cmd) "\n"]
    else ["CMD " opt.cmd "\n"];
  toDockerfile.label = opt:
    (builtins.mapAttrsToList (n: v: ["LABEL " ''"${n}"="${v}"'' "\n"]) opt.label) ++
    (builtins.mapAttrsToList (n: v: ["LABEL " ''"org.opencontainers.image.${dashToDot n}"="${v}"'' "\n"]) opt.opencontainers);
  toDockerfile.expose = opt: [
    "EXPOSE "
    (ifDef (v: "${v}") opt.expose or null)
    (ifDef (v: ":${v}") opt.internal or null)
    (ifDef (v: "/${v}") opt.protocol or null)
    "\n"
  ];
  toDockerfile.env = opt: (builtins.mapAttrsToList (n: v: ["ENV " n "=" v "\n"]) opt.env);
  toDockerfile.add = opt: [
    "ADD"
    (if (builtins.isString opt.user) || (builtins.isString opt.group) then " --chown=" else "")
    (ifDef (v: v) opt.user or null)
    (ifDef (v: ":${v}") opt.group or null)
    " "
    (ifDef (v: "${v}") opt.add or null)
    " "
    (ifDef (v: "${v}") opt.dest or null)
    "\n"
  ];
  toDockerfile.copy = opt: [
    "COPY"
    (if (builtins.isString opt.user) || (builtins.isString opt.group) then " --chown=" else "")
    (ifDef (v: v) opt.user or null)
    (ifDef (v: ":${v}") opt.group or null)
    (ifDef (v: "${v}") opt.add or null)
    " "
    (ifDef (v: "${v}") opt.dest or null)
    "\n"
  ];
  toDockerfile.entrypoint = opt: 
    if builtins.isList opt.entrypoint 
    then ["ENTRYPOINT " (builtins.toJSON opt.entrypoint) "\n"]
    else ["ENTRYPOINT " opt.entrypoint "\n"];
  toDockerfile.volume = opt:
    if builtins.isList opt.volume 
    then ["VOLUME " (builtins.toJSON opt.volume) "\n"]
    else ["VOLUME " opt.volume "\n"];
  toDockerfile.user = opt: [
    "USER "
    (ifDef (v: v) opt.user or null)
    (ifDef (v: ":${v}") opt.group or null)
    "\n"
  ];
  toDockerfile.workdir = opt: ["WORKIDIR " opt.workdir "\n"];
  toDockerfile.arg = opt: 
    if (builtins.isString opt.arg)
    then ["ARG " opt.arg "\n"]
    else builtins.concatLists (builtins.mapAttrsToList (n: v: ["ARG " n "=" v "\n"]) opt.arg);
  toDockerfile.stopsignal = opt: ["STOPSIGNAL " opt.stopsignal "\n"];
  toDockerfile.healthcheck = opt: 
    if (builtins.isBool opt.enable) && opt.enable
    then
      [
        "HEALTHCHECK"
        (ifDef (v: " --interval=${v}") opt.interval or null)
        (ifDef (v: " --timeout=${v}") opt.timeout or null)
        (ifDef (v: " --start=${v}") opt.start or null)
        (ifDef (v: " --retries=${v}") opt.retries or null)
        " CMD "
        (ifDef (v: v) opt.healthcheck or null)
        "\n"
      ]
    else ["HEALTHCHECK " "NONE" "\n"];
  toDockerfile.shell = opt: ["SHELL " (builtins.toJSON opt.shell) "\n"];
  toDockerfile.onbuild = opt: ["ONBUILD " opt.onbuild "\n"];
  typeOfDirective = cfg: lib.findFirst (n: cfg.${n} or null != null) null (builtins.attrNames toDockerfile);
  toStrArr = cfg:
    let cfgType = typeOfDirective cfg;
    in toDockerfile.${cfgType} cfg;
  directiveType.from.from.type = lib.types.nonEmptyStr;
  directiveType.from.from.description = "sets the Base Image for subsequent instructions ${dockerDocsUrl}#from";
  directiveType.from.from.example = "nixpkgs/flakes";
  directiveType.from.syntax.type = nullOrNonEmptyStr;
  directiveType.from.syntax.description = "sets file espec from ${dockerDocsUrl}#syntax";
  directiveType.from.syntax.example = "docker/dockerfile:1";
  directiveType.from.syntax.default = null;
  directiveType.from.escape.type = nullOrNonEmptyStr;
  directiveType.from.escape.description = "sets file espace ${dockerDocsUrl}#escape";
  directiveType.from.escape.example = "`";
  directiveType.from.escape.default = null;
  directiveType.from.name.type = nullOrNonEmptyStr;
  directiveType.from.name.description = "from image as name";
  directiveType.from.tag.type = nullOrNonEmptyStr;
  directiveType.from.tag.description = "from image tag";
  directiveType.from.tag.default = null;
  directiveType.from.digest.type = nullOrNonEmptyStr;
  directiveType.from.digest.description = "from image digest";
  directiveType.from.digest.default = null;
  directiveType.from.plataform.type = nullOrNonEmptyStr;
  directiveType.from.plataform.description = "specify the platform of the image ${dockerDocsUrl}#from";
  directiveType.from.plataform.example = "linux/amd64";
  directiveType.from.plataform.default = null;
  directiveType.run.run.type = listOrNonEmptyStr;
  directiveType.run.run.example = "echo Hello";
  directiveType.run.run.description = "command is run in a shell ${dockerDocsUrl}#run";
  directiveType.cmd.cmd.type = listOrNonEmptyStr;
  directiveType.cmd.cmd.example = ["echo" "Hello"];
  directiveType.cmd.cmd.description = "command is run in a shell ${dockerDocsUrl}#cmd";
  directiveType.label.label.type = attrsOfNonEmptyStr;
  directiveType.label.label.example = { version = "v1.1.2"; };
  directiveType.label.label.description = "adds metadata to image ${dockerDocsUrl}#label";
  directiveType.label.opencontainers.created.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.created.example = "2021-11-13T17:06Z";
  directiveType.label.opencontainers.created.description = "date and time on which the image was built using RFC 3339.";
  directiveType.label.opencontainers.created.default = null;
  directiveType.label.opencontainers.authors.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.authors.default = null;
  directiveType.label.opencontainers.authors.example = "Cruel Intentions";
  directiveType.label.opencontainers.authors.description = "contact details of the people or organization responsible for the image";
  directiveType.label.opencontainers.url.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.url.default = null;
  directiveType.label.opencontainers.url.example = "https://github.com/numtide/devshell";
  directiveType.label.opencontainers.url.description = "URL to find more information on the image ";
  directiveType.label.opencontainers.documentation.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.documentation.default = null;
  directiveType.label.opencontainers.documentation.example = "https://github.com/numtide/devshell";
  directiveType.label.opencontainers.documentation.description = "URL to get documentation on the image ";
  directiveType.label.opencontainers.source.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.source.default = null;
  directiveType.label.opencontainers.source.example = "https://github.com/numtide/devshell";
  directiveType.label.opencontainers.source.description = "URL to get source code for building the image ";
  directiveType.label.opencontainers.version.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.version.default = null;
  directiveType.label.opencontainers.version.example = "1.1.1";
  directiveType.label.opencontainers.version.description = "version of the packaged software";
  directiveType.label.opencontainers.revision.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.revision.default = null;
  directiveType.label.opencontainers.revision.example = "sha256+b64u:LCa0a2j_xo_5m0U8HTBBNBNCLXBkg7-g-YpeiGJm564";
  directiveType.label.opencontainers.revision.description = "Source control revision identifier for the packaged software.";
  directiveType.label.opencontainers.vendor.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.vendor.default = null;
  directiveType.label.opencontainers.vendor.example = "Cruel Intentions";
  directiveType.label.opencontainers.vendor.description = "Name of the distributing entity, organization or individual.";
  directiveType.label.opencontainers.licenses.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.licenses.default = null;
  directiveType.label.opencontainers.licenses.example = "MIT";
  directiveType.label.opencontainers.ref-name.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.ref-name.default = null;
  directiveType.label.opencontainers.ref-name.example = "devshell-files/devshell-files";
  directiveType.label.opencontainers.ref-name.description = "Name of the reference for a target .";
  directiveType.label.opencontainers.title.type  = nullOrNonEmptyStr;
  directiveType.label.opencontainers.title.default = null;
  directiveType.label.opencontainers.title.example  = "Devshell Files Creator";
  directiveType.label.opencontainers.title.description  = "Human-readable title of the image ";
  directiveType.label.opencontainers.description.type  = nullOrNonEmptyStr;
  directiveType.label.opencontainers.description.default = null;
  directiveType.label.opencontainers.description.example  = "docker image for those afraid of nix installation";
  directiveType.label.opencontainers.description.description  = "Human-readable description of the software packaged in the image ";
  directiveType.label.opencontainers.base-digest.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.base-digest.default = null;
  directiveType.label.opencontainers.base-digest.example = "sha256:ff1530fdc3b761a80710ba1fa297d8e49a08d8ba741233b961ec7203e398aed9";
  directiveType.label.opencontainers.base-Digest.description = "Digest of the image this image is based on";
  directiveType.label.opencontainers.base-name.type = nullOrNonEmptyStr;
  directiveType.label.opencontainers.base-name.default = null;
  directiveType.label.opencontainers.base-name.example = "nixpkgs/nix-flakes";
  directiveType.label.opencontainers.base-name.description = "Image reference of the image this image is based on";
  directiveType.expose.expose.type = lib.types.port;
  directiveType.expose.expose.example = 80;
  directiveType.expose.expose.description = "external port of ${dockerDocsUrl}#expose";
  directiveType.expose.internal.type = lib.types.nullOr lib.types.port;
  directiveType.expose.internal.default = null;
  directiveType.expose.internal.example = 8080;
  directiveType.expose.internal.description = "external port of ${dockerDocsUrl}#expose";
  directiveType.expose.protocol.type = lib.types.nullOr (lib.types.enum ["tcp" "udp"]);
  directiveType.expose.protocol.default = null;
  directiveType.expose.protocol.example = "tcp";
  directiveType.expose.protocol.description = "expose protocol ${dockerDocsUrl}#expose";
  directiveType.env.env.type = attrsOfNonEmptyStr;
  directiveType.env.env.example = { TAG_VERSION = "v1.1.1"; };
  directiveType.env.env.description = "Set envs variables ${dockerDocsUrl}#env";
  directiveType.add.add.type = lib.types.path;
  directiveType.add.add.example = ./src;
  directiveType.add.add.description = "Add files source ${dockerDocsUrl}#add";
  directiveType.add.dest.type = lib.types.path;
  directiveType.add.dest.example = "/app";
  directiveType.add.dest.description = "Add files destination ${dockerDocsUrl}#add";
  directiveType.add.user.type = nullOrNonEmptyStr;
  directiveType.add.user.default = null;
  directiveType.add.user.example = "appUser";
  directiveType.add.user.description = "Add files with user ${dockerDocsUrl}#add";
  directiveType.add.group.type = nullOrNonEmptyStr;
  directiveType.add.group.default = null;
  directiveType.add.group.example = "appGroup";
  directiveType.add.group.description = "Add files with group ${dockerDocsUrl}#add";
  directiveType.copy.copy.type = lib.types.path;
  directiveType.copy.copy.example = ./src;
  directiveType.copy.copy.description = "Copies source ${dockerDocsUrl}#copy";
  directiveType.copy.dest.type = lib.types.path;
  directiveType.copy.dest.example = "/app";
  directiveType.copy.dest.description = "Copies destination ${dockerDocsUrl}#copy";
  directiveType.copy.user.type = nullOrNonEmptyStr;
  directiveType.copy.user.default = null;
  directiveType.copy.user.example = "appUser";
  directiveType.copy.user.description = "Copies files as user ${dockerDocsUrl}#copy";
  directiveType.copy.group.type = nullOrNonEmptyStr;
  directiveType.copy.group.default = null;
  directiveType.copy.group.example = "appGroup";
  directiveType.copy.group.description = "Copies files as group ${dockerDocsUrl}#copy";
  directiveType.entrypoint.entrypoint.type = listOrNonEmptyStr;
  directiveType.entrypoint.entrypoint.example = "echo HELLo";
  directiveType.entrypoint.entrypoint.description = "Default command when containers run ${dockerDocsUrl}#entrypoint";
  directiveType.volume.volume.type = listOrNonEmptyStr;
  directiveType.volume.volume.example = ["/app"];
  directiveType.volume.volume.description = "Creates a mount point ${dockerDocsUrl}#volume";
  directiveType.user.user.type = lib.types.nonEmptyStr;
  directiveType.user.user.example = "appUser";
  directiveType.user.user.description = "Sets the user name (or UID) ${dockerDocsUrl}#user";
  directiveType.user.group.type = nullOrNonEmptyStr;
  directiveType.user.group.default = null;
  directiveType.user.group.example = "appGroup";
  directiveType.user.group.description = "Sets the user group (or GID) ${dockerDocsUrl}#user";
  directiveType.workdir.workdir.type = lib.types.nonEmptyStr;
  directiveType.workdir.workdir.example = "/app";
  directiveType.workdir.workdir.description = "Sets the working directory ${dockerDocsUrl}#workdir";
  directiveType.arg.arg.type = lib.types.oneOf [lib.types.nonEmptyStr attrsOfNonEmptyStr];
  directiveType.arg.arg.example = "user";
  directiveType.arg.arg.description = "defines a variable we can pass at build-time ${dockerDocsUrl}#arg";
  directiveType.stopsignal.stopsignal.type = lib.types.oneOf [lib.types.ints.u8 (lib.types.enum stopSignals)];
  directiveType.stopsignal.stopsignal.example = "SIGKILL";
  directiveType.stopsignal.stopsignal.description = "system call signal sent to the container to exit ${dockerDocsUrl}#stopsignal";
  directiveType.healthcheck.enable.type = lib.types.nullOr lib.types.bool;
  directiveType.healthcheck.enable.example = false;
  directiveType.healthcheck.enable.description = "Set to false to disable healthcheck ${dockerDocsUrl}#healthcheck";
  directiveType.healthcheck.healthcheck.type = lib.types.nonEmptyStr;
  directiveType.healthcheck.healthcheck.example = "curl -f http://localhost/ || exit 1";
  directiveType.healthcheck.healthcheck.description = "HEALTHCHECK command ${dockerDocsUrl}#healthcheck";
  directiveType.healthcheck.interval.type = nullOrNonEmptyStr;
  directiveType.healthcheck.interval.default = null;
  directiveType.healthcheck.interval.example = "30s";
  directiveType.healthcheck.interval.description = "HEALTHCHECK interval ${dockerDocsUrl}#healthcheck";
  directiveType.healthcheck.timeout.type = nullOrNonEmptyStr;
  directiveType.healthcheck.timeout.default = null;
  directiveType.healthcheck.timeout.example = "30s";
  directiveType.healthcheck.timeout.description = "HEALTHCHECK command timeout ${dockerDocsUrl}#healthcheck";
  directiveType.healthcheck.start.type =  nullOrNonEmptyStr;
  directiveType.healthcheck.start.default =  null;
  directiveType.healthcheck.start.example = "30s";
  directiveType.healthcheck.start.description = "HEALTHCHECK time to start ${dockerDocsUrl}#healthcheck";
  directiveType.healthcheck.retries.type = lib.types.nullOr lib.types.ints.u32;
  directiveType.healthcheck.retries.default = null;
  directiveType.healthcheck.retries.example = 3;
  directiveType.healthcheck.retries.description = "HEALTHCHECK retries ${dockerDocsUrl}#healthcheck";
  directiveType.shell.shell.type = lib.types.listOf lib.types.nonEmptyStr;
  directiveType.shell.shell.example = ["/bin/sh" "-c" "'echo hello'"];
  directiveType.shell.shell.description = "overridden default shell ${dockerDocsUrl}#shell";
  directiveType.onbuild.onbuild.type = lib.types.nonEmptyStr;
  directiveType.onbuild.onbuild.example = "ADD . /app/src";
  directiveType.onbuild.onbuild.description = "System call sent container to exit ${dockerDocsUrl}#onbuild";
  directive = builtins.mapAttrs mkOptions directiveType;
  validDirectives = lib.types.oneOf (lib.mapAttrsToList (n: v: lib.types.submodule v) directive);
  directives = lib.types.listOf validDirectives;
in
{
  inherit directiveType typeOfDirective toStrArr directive directives validDirectives;
}
