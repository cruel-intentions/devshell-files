# syntax=docker/dockerfile:1

# Docker isn't required
# install nix in your machine
# nix is available to Linux, Mac and (with WSL) Windows
#
# edit project.nix and run
# >> docker run --rm -v `pwd`:/app -it `docker build -q .`
# then
# >> nix develop inside docker

FROM nixpkgs/nix-flakes

# Start your project
WORKDIR /app
VOLUME /app
ENTRYPOINT bash
