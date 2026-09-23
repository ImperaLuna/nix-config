{ inputs, pkgs, ... }:
{
  imports = [ inputs.voxtype.nixosModules.default ];

  programs.voxtype = {
    enable = true;
    package = pkgs.voxtype-vulkan;
  };

  users.users.imperaluna.extraGroups = [ "input" ];
}
