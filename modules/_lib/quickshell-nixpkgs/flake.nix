{
  # Exposes nixpkgs' quickshell in the shape nova-shell expects from its
  # quickshell input, so nova gets the cached Hydra build instead of
  # compiling quickshell from source.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    {
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
        default = nixpkgs.legacyPackages.${system}.quickshell;
      });
    };
}
