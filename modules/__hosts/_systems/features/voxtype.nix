{ inputs, ... }:
{
  imports = [ inputs.voxtype.nixosModules.default ];

  programs.voxtype = {
    enable = true;
    package = inputs.voxtype.packages.x86_64-linux.vulkan;
  };

  users.users.imperaluna.extraGroups = [ "input" ];
}
