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
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.ansible_2_18
          pkgs.ansible-lint
          pkgs.ansible-language-server
        ];

        shellHook = ''
          export PS1="(Ansible)$PS1"
        '';
      };
    };
}
