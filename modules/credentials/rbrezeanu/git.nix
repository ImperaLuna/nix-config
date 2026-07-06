{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Rares Brezeanu";
      user.email = "c_Rares.Brezeanu@viasat.com";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
