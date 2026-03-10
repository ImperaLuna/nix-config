{ ... }:

{
  imports = [
    ./ghostty/ghostty.nix
    ./terminal/terminal.nix
    ./zed/zed.nix
  ];

  home.stateVersion = "25.11";

  home.file.".config/nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  xdg.desktopEntries.steam = {
    name = "Steam";
    comment = "Application for managing and playing games on Steam";
    exec = "steam %U";
    icon = "steam";
    terminal = false;
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
    settings = {
      PrefersNonDefaultGPU = "true";
      X-KDE-RunOnDiscreteGpu = "true";
    };
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "ImperaLuna";
      user.email = "rares.brezeanu.dev@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

}
