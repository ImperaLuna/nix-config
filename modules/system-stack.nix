{ inputs, ... }:

{
  flake.nixosModules.system-stack-desktop = {
    imports = [
      inputs.dms.nixosModules.dank-material-shell
      inputs.dms.nixosModules.greeter
    ];
  };
}
