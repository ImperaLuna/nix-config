{ ... }:

{
  flake.modules.homeManager.terminal-feature-agent-skills = { config, ... }:
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
    };
}
