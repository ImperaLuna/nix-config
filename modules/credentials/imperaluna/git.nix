{ ... }:

{
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
