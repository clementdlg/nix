FROM alpine:3.23
ARG REPO="github.com:clementdlg/dotfiles.git"
ARG USER="krem"
ARG HOME="/home/$USER"
ARG XDG_CONFIG_HOME="${HOME}/.config"

RUN apk add --no-cache just curl
RUN	curl -fsSL https://install.determinate.systems/nix \
	| sh -s -- install linux --no-confirm --init none

RUN adduser -h "$HOME" -D "$USER"
ADD https://github.com/clementdlg/dotfiles.git "$HOME/.config"
RUN chown -R "$USER": "$HOME"
RUN chown -R "$USER": /nix 
USER $USER
WORKDIR "$XDG_CONFIG_HOME"
RUN source /etc/profile.d/nix.sh &&\
	nix run "nixpkgs#home-manager" -- switch &&\
	nvim -l "$XDG_CONFIG_HOME/nvim/init.lua"

ENV USER="$USER"
ENTRYPOINT [ "/bin/ash", "-l" ]
# RUN just all
