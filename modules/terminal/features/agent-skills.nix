{ ... }:

{
  flake.modules.homeManager.terminal-feature-agent-skills = { config, lib, pkgs, ... }:
    let
      # The repo must be cloned at ~/Skills; links point into that live checkout,
      # so skill edits apply without a rebuild.
      skillsRepo = "${config.home.homeDirectory}/Skills";
    in
    {
      # Authors whose skills get linked: every global/<author>/skills/<skill>
      # folder becomes ~/.claude/skills/<skill>. A host adds work-only authors
      # by setting this too; lists from each definition are merged.
      options.agentSkills.authors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Skills repo authors whose skills are linked.";
      };

      config = {
        agentSkills.authors = [ "imperaluna" "mattpocock" ];

        # Nix can't list ~/Skills while evaluating, so the skills are found at
        # switch time: a new skill needs a rebuild, not an edit here. Only links
        # into the Skills repo are touched; stale ones (deleted skill, dropped
        # author) are removed.
        home.activation.skillsLink = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          authors=" ${lib.concatStringsSep " " config.agentSkills.authors} "
          for root in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
            mkdir -p "$root"
            for link in "$root"/*; do
              [ -L "$link" ] || continue
              target="$(readlink "$link")"
              case "$target" in "${skillsRepo}/global/"*) ;; *) continue ;; esac
              author="''${target#${skillsRepo}/global/}"
              author="''${author%%/*}"
              if [ ! -f "$target/SKILL.md" ] || [ "''${authors#* $author }" = "$authors" ]; then
                rm "$link"
              fi
            done
            for author in $authors; do
              for skill in "${skillsRepo}/global/$author/skills"/*/; do
                [ -f "$skill/SKILL.md" ] || continue
                skill="''${skill%/}"
                link="$root/$(basename "$skill")"
                if [ -e "$link" ] && [ ! -L "$link" ]; then
                  echo "agent-skills: $link is not a link, leaving it" >&2
                  continue
                fi
                ln -sfn "$skill" "$link"
              done
            done
          done
        '';

        home.file = {
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
              "mattpocock@synced": false,
              "viasat@synced": false
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
    };
}
