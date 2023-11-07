{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        gitignoreSrc = pkgs.callPackage inputs.gitignore { };
        rust = pkgs.rust-bin.stable.latest.default.override
          {
            extensions = [ "rust-src" "rust-analyzer" ];
          };
      in
      rec {
        devShell = pkgs.mkShell {
          CARGO_INSTALL_ROOT = "./.cargo";
          MONGODB = "mongodb://localhost:27017";
          PORT = "8080";
          REDIS = "127.0.0.1";
          RUST_LOG = "debug";

          buildInputs = with pkgs; [
            git
          ] ++ [ rust ];

          nativeBuildInputs = with pkgs; [ pkg-config ];
        };
      });
}
