FROM alpine:3.23
ARG REPO="https://github.com/clementdlg/dotfiles.git"
ARG USER="krem"
ARG HOME="/home/$USER"
ARG XDG_CONFIG_HOME="${HOME}/.config"

RUN apk add --no-cache just curl bash
RUN	curl -fsSL https://install.determinate.systems/nix \
	| sh -s -- install linux --no-confirm --init none

RUN adduser -h "$HOME" -D "$USER"
ADD $REPO "$HOME/.config"
RUN chown -R "$USER": "$HOME"
RUN chown -R "$USER": /nix 
USER $USER
WORKDIR "$XDG_CONFIG_HOME"
RUN source /etc/profile.d/nix.sh &&\
	nix run "nixpkgs#home-manager" -- switch &&\
	nix store gc &&\
	nvim -l "$XDG_CONFIG_HOME/nvim/init.lua"

RUN ln -s ~/.config/bash/bashrc ~/.bashrc

ENV USER="$USER"
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ENTRYPOINT ["/home/krem/.nix-profile/bin/tmux"]
