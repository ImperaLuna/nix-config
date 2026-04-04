{ inputs, config, ... }:

{
  imports = [
    (inputs.import-tree ./features)
  ];

  flake.modules.homeManager.workstation-role-default = {
    imports = [
      config.flake.modules.homeManager.workstation-feature-ghostty
      config.flake.modules.homeManager.workstation-feature-zed
    ];
  };
}
