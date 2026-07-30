{ ... }:

{
  flake.nixosModules._systems-role-server = {
    imports = [
      ./features/homelab.nix
      ./features/remote-access.nix
    ];
  };
}
