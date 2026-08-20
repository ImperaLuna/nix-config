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
        // linksFor ".pi/agent/skills"
        // {
          # Global Claude Code instructions live in the Skills repo so they sync
          # like everything else. force replaces a hand-made file or link.
          ".claude/CLAUDE.md" = {
            source = config.lib.file.mkOutOfStoreSymlink "${skillsRepo}/global/imperaluna/CLAUDE.md";
            force = true;
          };
        };

      # `skills check` is the quick read-only status; `skills update` is the
      # interactive pull. A real script so it works from zsh and fish alike.
      home.packages = [
        (pkgs.writeShellScriptBin "skills" ''
          case "''${1:-}" in
            install) exec "${skillsRepo}/install.sh" ;;
            check) exec "${skillsRepo}/update.sh" status ;;
            update) exec "${skillsRepo}/update.sh" check ;;
            *) echo "usage: skills install | check | update" >&2; exit 2 ;;
          esac
        '')
      ];

      # `skills` wraps the repo's scripts: check is the quick read-only status,
      # update is the interactive pull.
      programs.zsh.initContent = ''
        skills() {
          case "''${1:-}" in
            install) "${skillsRepo}/install.sh" ;;
            check) "${skillsRepo}/update.sh" status ;;
            update) "${skillsRepo}/update.sh" check ;;
            add) shift; "${skillsRepo}/update.sh" add "$@" ;;
            *) echo "usage: skills install | check | update | add <repo> <path> [name] [author]" >&2; return 2 ;;
          esac
        }
      '';

      # Read-only staleness check at switch time; --quiet keeps it silent when
      # current or offline, and it never fails the activation. Pulling stays
      # manual via ./update.sh.
      home.activation.skillsUpdateStatus = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -x "${skillsRepo}/update.sh" ]; then
          PATH="${lib.makeBinPath (with pkgs; [ bash coreutils gawk git gnugrep jq curl gh ])}:$PATH" \
            ${pkgs.coreutils}/bin/timeout 15 "${skillsRepo}/update.sh" status --quiet || true
        fi
      '';
    };
}
