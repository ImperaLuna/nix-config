{ ... }:

{
  flake.nixosModules._systems-role-desktop = {
    imports = [
      ./features/hyprland.nix
      ./features/input-remap.nix
      ./features/virtualisation.nix
      ./features/dms.nix
      ./features/remote-access.nix
      ./features/syncthing.nix
    ];
  };

  flake.nixosModules._systems-role-server = {
    imports = [
      ./features/homelab.nix
      ./features/remote-access.nix
    ];
  };
}
