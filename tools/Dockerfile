FROM nixos/nix:latest AS neovim
# install neovim
COPY --from=neovim-base /build/usr /usr
RUN apk update && apk add --no-cache \
	musl \
	libluv \
	libvterm \
	lua5.1-lpeg \
	msgpack-c \
	tree-sitter \
	tree-sitter-vimdoc \
	unibilium \
	libintl \
	luajit \
	libuv \
	utf8proc \
	git


# - - -- - - - 
FROM neovim
ARG CONFIG="https://github.com/clementdlg/nvim.git"

RUN apk add --no-cache gcc musl-dev &&\
	git clone "$CONFIG" "/root/.config/nvim" &&\
	nvim -l "/root/.config/nvim/init.lua"
