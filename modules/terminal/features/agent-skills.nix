{ ... }:

{
  flake.modules.homeManager.terminal-feature-agent-skills = { config, lib, pkgs, ... }:
    let
      # Links point into the live checkout so skill edits and ./update.sh pulls
      # apply without a rebuild; the repo must be cloned at ~/Skills.
      # Entries are "<author>/<skill>"; the link is named after the skill alone.
      skillsRepo = "${config.home.homeDirectory}/Skills";
      skills = [
        "imperaluna/synced-repos"
        "mattpocock/teach"
        "poteto/bro"
        "poteto/unslop"
      ];

      linksFor = root:
        builtins.listToAttrs (
          map (skill: {
            name = "${root}/${baseNameOf skill}";
            value.source = config.lib.file.mkOutOfStoreSymlink "${skillsRepo}/global/${skill}";
          }) skills
        );
    in
    {
      home.file =
        linksFor ".claude/skills"
        // linksFor ".agents/skills"
        // linksFor ".pi/agent/skills";

      # Read-only staleness check at switch time; silent when current or offline
      # and never fails the activation. Pulling stays manual via ./update.sh.
      home.activation.skillsUpdateStatus = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -x "${skillsRepo}/update.sh" ]; then
          PATH="${lib.makeBinPath (with pkgs; [ bash coreutils gawk git gnugrep jq curl gh ])}:$PATH" \
            ${pkgs.coreutils}/bin/timeout 15 "${skillsRepo}/update.sh" status || true
        fi
      '';
    };
}
