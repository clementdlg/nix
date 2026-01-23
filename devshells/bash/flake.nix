{
  description = "Bash dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.bash
          pkgs.curl
          pkgs.git
          pkgs.jq
          pkgs.gnutar
		  pkgs.bash-language-server
		  pkgs.shellcheck
        ];

        shellHook = ''
          export PS1="$PS1"
        '';
      };
    };
}
