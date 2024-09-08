{
    description = "PandocRulebookBase flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system:
        let
            nixpkgsImport = import nixpkgs {
                system = "x86_64-linux";
            };
            pkgs = nixpkgsImport;
        in rec {
            devShells.default = pkgs.mkShell {
                buildInputs = with pkgs; [
                    nix git git-lfs wget cacert zip
                    pandoc minify dart-sass highlight imagemagick lychee
                    texliveFull qpdf
                    python311 python311Packages.beautifulsoup4 python311Packages.tomli-w
                ];
            };
        }
    );
}