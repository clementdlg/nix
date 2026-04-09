{
  description = "Dev Env flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # custom ansible-language-server
      ansibleLs = pkgs.writeShellApplication {
        name = "ansible-language-server";

        runtimeInputs = [
          pkgs.nodejs
            pkgs.vscode-extensions.redhat.ansible
        ];

        text = ''
          exec ${pkgs.nodejs}/bin/node \
          ${pkgs.vscode-extensions.redhat.ansible}/share/vscode/extensions/redhat.ansible/out/server/src/server.js "$@"
        '';
      };

      # neovim setup with treesitter parsers
      neovimTreesitter = pkgs.neovim.override {
        configure = {
          # use the user's config
          customLuaRC = ''
                local nvimrc = vim.fn.expand('~/.config/nvim/init.lua')
                if vim.fn.filereadable(nvimrc) == 1 then
                  dofile(nvimrc)
                end
                '';
          packages.myPlugins = with pkgs.vimPlugins; {
            start = [
              (nvim-treesitter.withPlugins (p: [
                p.nix
                p.html
                p.json
                p.yaml
                p.hcl
                p.just
                p.bash
                p.python
                p.go
                p.rust
                p.javascript
              ]))
            ];
          };
        };
      };
    in
  {
    packages.${system}.default = pkgs.buildEnv {
      name = "devenv-profile";
      paths = with pkgs; [
        # custom packages
        ansibleLs
        neovimTreesitter
        
        # core utils
        curl
        gnutar
        jq
        netcat
        lsof
        tree
        fzf
        git
        tmux

        # fancy rust utils
        delta
        btop
        bat
        ripgrep
        tokei
        tealdeer

        # bash
        bash-language-server

        # python dev
        uv
        ruff
        pyright

        # lua
        lua-language-server
        stylua


        # container tools
        # docker-language-server
        kubectl
        k9s

        # infra
        opentofu
        terraform-ls
        gitlab-ci-local

        # go
        go
        gopls
      ];
    };
  };
}
