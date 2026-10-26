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

    # The personal repos push and commit as ImperaLuna with the personal key.
    # IdentitiesOnly stops ssh from offering the work key first, which GitHub
    # would accept as the work account.
    includes = map (dir: {
      condition = "gitdir:~/${dir}/";
      contents = {
        core.sshCommand = "ssh -i ~/.ssh/personal -o IdentitiesOnly=yes";
        user.name = "ImperaLuna";
        user.email = "rares.brezeanu.dev@gmail.com";
      };
    }) [ "nix-config" "Skills" ];
  };
}
