{ ... }:

{
  flake.modules.homeManager.terminal-feature-agent-skills = { config, ... }:
    let
      # Links point into the live checkout so skill edits and ./update.sh pulls
      # apply without a rebuild; the repo must be cloned at ~/Skills.
      skillsRepo = "${config.home.homeDirectory}/Skills";
      skills = [ "unslop" ];

      linksFor = root:
        builtins.listToAttrs (
          map (name: {
            name = "${root}/${name}";
            value.source = config.lib.file.mkOutOfStoreSymlink "${skillsRepo}/global/${name}";
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
