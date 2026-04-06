FROM alpine:3.23
# ARG USER="krem"
# ARG HOME="/home/$USER"

# install dependencies
RUN apk add --no-cache curl bash
# RUN adduser -h "$HOME" -D "$USER"

# install nix
RUN curl -fsSL https://install.determinate.systems/nix \
		| sh -s -- install linux --no-confirm --init none && \
	rm /nix/nix-installer
	# chown -R "$USER": "$HOME" && \
	# chown -R "$USER": /nix

# setup user environement and install packages
# USER $USER
# WORKDIR "$HOME"
WORKDIR /app
COPY flake.nix flake.lock .
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"
RUN nix profile add . && nix store gc

ENV LANG=en_US.UTF-8
# ENTRYPOINT ["/home/krem/.nix-profile/bin/tmux"]
