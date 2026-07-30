{ ... }:

{
  flake.nixosModules._systems-role-desktop = {
    imports = [
      ./features/hyprland.nix
      ./features/niri.nix
      ./features/input-remap.nix
      ./features/virtualisation.nix
      ./features/remote-access.nix
      ./features/syncthing.nix
      ./features/voxtype.nix
    ];
  };
}
