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
					packages.myPlugins = with pkgs.vimPlugins; {
						start = [
							(nvim-treesitter.withPlugins (p: [
								p.nix
								p.html
								p.json
								p.yaml
								p.bash
								p.python
								p.javascript
								p.go
								p.rust
								p.hcl
								p.just
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

				curl
				gnutar
				jq
				netcat
				lsof
				tree
				fzf
				git
				tmux
				# neovim

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

				# ansible dev
				# ansible-lint

				# lua
				lua-language-server
				stylua

				# DevOps
				# docker-language-server
				yaml-language-server
				terraform-ls
				gitlab-ci-local
				crane
				kubectl
			];
		};
	};
}
