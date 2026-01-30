{
  description = "Ansible dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      packages.${system}.ansible-language-server = pkgs.writeShellApplication {
        name = "ansible-language-server";

        runtimeInputs = [
          pkgs.bun
            pkgs.vscode-extensions.redhat.ansible
        ];

        text = ''
          exec ${pkgs.bun}/bin/bun \
          ${pkgs.vscode-extensions.redhat.ansible}/share/vscode/extensions/redhat.ansible/out/server/src/server.js "$@"
          '';
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.ansible_2_18
          pkgs.ansible-lint
          pkgs.ansible-language-server
          self.packages.${system}.ansible-language-server
		  pkgs.glibcLocales
        ];

        LANG="C.UTF-8";
        LC_ALL="C.UTF-8";

        shellHook = ''
          export PS1="(Ansible)$PS1"
        '';
      };
    };
}
