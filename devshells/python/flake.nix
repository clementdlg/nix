{
  description = "Python dev shell";

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
          pkgs.python314
          pkgs.pyright
          pkgs.uv
          pkgs.ruff
        ];

        shellHook = ''
          export PS1="(python) $PS1"
        '';
      };
    };
}
