{ ... }:

{
  flake.modules.homeManager.terminal-feature-agent-skills = { config, lib, pkgs, ... }:
    let
      # Links point into the live checkout so skill edits and ./update.sh pulls
      # apply without a rebuild; the repo must be cloned at ~/Skills.
      # Entries are "<author>/<skill>" and resolve to global/<author>/skills/<skill>,
      # the plugin layout the repo's marketplace uses; the link is named after
      # the skill alone.
      skillsRepo = "${config.home.homeDirectory}/Skills";
      skills = [
        "imperaluna/github"
        "imperaluna/html-artifact"
        "imperaluna/synced-repos"
        "mattpocock/domain-modeling"
        "mattpocock/grilling"
        "mattpocock/prototype"
        "mattpocock/research"
        "mattpocock/setup-matt-pocock-skills"
        "mattpocock/teach"
        "mattpocock/wayfinder"
        "poteto/bro"
      ];

      linksFor = root:
        builtins.listToAttrs (
          map (skill: {
            name = "${root}/${baseNameOf skill}";
            value.source = config.lib.file.mkOutOfStoreSymlink
              "${skillsRepo}/global/${dirOf skill}/skills/${baseNameOf skill}";
          }) skills
        );
    in
    {
      home.file =
        linksFor ".claude/skills"
        // linksFor ".agents/skills"
        // {
          # Global agent instructions live in the Skills repo so they sync like
          # everything else. Claude and Codex read the same file, so it must
          # stay plain markdown (no Claude-only @includes). force replaces a
          # hand-made file or link.
          ".claude/CLAUDE.md" = {
            source = config.lib.file.mkOutOfStoreSymlink "${skillsRepo}/global/AGENTS.md";
            force = true;
          };
          ".codex/AGENTS.md" = {
            source = config.lib.file.mkOutOfStoreSymlink "${skillsRepo}/global/AGENTS.md";
            force = true;
          };
        };

      # `skills check` is the quick read-only status; `skills update` is the
      # interactive pull. A real script so it also works outside zsh.
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

      # The Skills repo is also a plugin marketplace, so an account that installed
      # it on claude.ai gets the same skills synced into Claude Code. The links
      # above already provide them here, so keep the synced copies off.
      # Claude Code owns settings.json, so only these keys are touched.
      home.activation.skillsSyncedPluginsOff = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings="$HOME/.claude/settings.json"
        mkdir -p "$HOME/.claude"
        [ -s "$settings" ] || echo '{}' > "$settings"
        tmp_file="$(mktemp)"
        ${pkgs.jq}/bin/jq '
          .enabledPlugins = ((.enabledPlugins // {}) + {
            "imperaluna@synced": false,
            "imperaluna-work@synced": false,
            "mattpocock@synced": false,
            "poteto@synced": false
          })
        ' "$settings" > "$tmp_file"
        if cmp -s "$tmp_file" "$settings"; then
          rm "$tmp_file"
        else
          mv "$tmp_file" "$settings"
        fi
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
