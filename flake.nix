{
  description = "Warp development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
    ] (system:
      let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        runtimeLibraries = with pkgs; [
          alsa-lib
          expat
          fontconfig
          freetype
          libgit2
          libglvnd
          libxkbcommon
          mesa
          openssl
          vulkan-loader
          wayland
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libxcb
          zlib
        ];
        devTools = with pkgs; [
          brotli
          cargo-binstall
          cargo-nextest
          cmake
          curl
          diesel-cli
          fish
          gcc
          gnumake
          gh
          git
          glibcLocales
          google-cloud-sdk
          jq
          pkg-config
          protobuf
          python3
          rustToolchain
          unzip
          vim
          wgsl-analyzer
          zsh
        ];
        libraryPath = pkgs.lib.makeLibraryPath runtimeLibraries;
      in {
        devShells.default = pkgs.mkShell {
          packages = devTools ++ runtimeLibraries;

          shellHook = ''
            export WARP_IN_NIX_SHELL=1
            export PROTOC="${pkgs.lib.getExe pkgs.protobuf}"
            if [[ -n "''${LD_LIBRARY_PATH:-}" ]]; then
              export LD_LIBRARY_PATH="${libraryPath}:''${LD_LIBRARY_PATH}"
            else
              export LD_LIBRARY_PATH="${libraryPath}"
            fi
          '';
        };
      });
}
