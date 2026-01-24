{
	description = "Wrapper package for Ansible Language Server from VSCode extension";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
	};

	outputs = { self, nixpkgs }:
		let
		system = "x86_64-linux";
	pkgs = import nixpkgs { inherit system; };
	in
	{
		packages.${system}.ansible-language-server =
			pkgs.writeShellApplication {
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

		default =
			self.packages.${system}.ansible-language-server;
	};
}
