{
  description = "Pule - Cross-platform Prayer List App";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
        };
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            flutter
            just
            cocoapods
          ];

          shellHook = ''
            echo "Pule dev shell ready"
            echo "Flutter: $(flutter --version 2>/dev/null | head -1)"
          '';
        };
      });
}
