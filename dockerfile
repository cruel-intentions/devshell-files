# syntax=docker/dockerfile:1

# Docker isn't required
# install nix in your machine
# nix is available to Linux, Mac and (with WSL) Windows

FROM nixpkgs/nix-flakes

# Start your project
WORKDIR /app
COPY . .
ENTRYPOINT nix develop -c $SHELL
