{
  flake.modules.homeManager.terminal-feature-herdr = { config, lib, pkgs, ... }:
    let
      cfg = config.modules.herdr;

      # SessionEnd/PreCompact hook: a background `claude -p` run distills the
      # thread into the project's auto-memory folder.
      memoryPass = pkgs.writeShellApplication {
        name = "claude-memory-pass";
        runtimeInputs = with pkgs; [ coreutils gnused jq ];
        text = builtins.readFile ./memory-pass.sh;
      };

      # Compact at 70% of a 200k window instead of near the end of a 1M one.
      compactEnv = {
        CLAUDE_CODE_AUTO_COMPACT_WINDOW = "200000";
        CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = "70";
        MEMORY_PASS_MODEL = cfg.memoryPassModel;
      };
    in
    {
      options.modules.herdr.memoryPassModel = lib.mkOption {
        type = lib.types.str;
        default = "sonnet";
        description = "Model for the memory pass that runs when a Claude Code thread ends or compacts. Use a full model ID where aliases don't resolve.";
      };

      config = {
        home.packages = [ pkgs.herdr memoryPass ];

        # Some Claude Code versions ignore the compaction override in
        # settings.json, so export it from the shell as well.
        home.sessionVariables = compactEnv;

        # Linked to the live checkout, so edits to the skill apply without a
        # rebuild.
        home.file.".claude/skills/orchestrate".source =
          config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/nix-config/modules/terminal/features/herdr/orchestrate";

        # herdr's own agent skill (how to drive panes and agents) has to match
        # the installed version, so it is regenerated on every switch.
        home.activation.herdrSkill = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.claude/skills/herdr"
          ${pkgs.herdr}/bin/herdr --skill > "$HOME/.claude/skills/herdr/SKILL.md"
        '';

        # herdr's integrations let it tell working, blocked and done agents
        # apart. They write their own hook files and settings entries; a failure
        # (no ~/.codex yet, say) only costs status detection, so it never stops
        # the switch.
        home.activation.herdrIntegrations = lib.hm.dag.entryAfter [ "claudeAllowRules" "codexNewlineKeymap" ] ''
          for agent in claude codex; do
            ${pkgs.herdr}/bin/herdr integration install "$agent" >/dev/null \
              || echo "herdr: $agent integration not installed" >&2
          done
        '';

        # Claude Code owns settings.json, so only the memory hooks and the
        # compaction env are merged in. Entries from an older store path of the
        # hook are replaced.
        home.activation.claudeMemoryHooks = lib.hm.dag.entryAfter [ "herdrIntegrations" ] ''
          settings="$HOME/.claude/settings.json"
          mkdir -p "$HOME/.claude"
          [ -s "$settings" ] || echo '{}' > "$settings"
          tmp_file="$(mktemp)"
          ${pkgs.jq}/bin/jq \
            --arg hook "${memoryPass}/bin/claude-memory-pass" \
            --argjson env '${builtins.toJSON compactEnv}' '
              def addhook($ev; $entry):
                .hooks[$ev] = ((.hooks[$ev] // [])
                  | map(select(any(.hooks[]?; .command | endswith("/bin/claude-memory-pass")) | not))
                  + [$entry]);
              addhook("SessionEnd"; {hooks: [{type: "command", command: $hook}]})
              | addhook("PreCompact"; {matcher: "", hooks: [{type: "command", command: $hook}]})
              | .env = ((.env // {}) + $env)
            ' "$settings" > "$tmp_file"
          if cmp -s "$tmp_file" "$settings"; then
            rm "$tmp_file"
          else
            mv "$tmp_file" "$settings"
          fi
        '';
      };
    };
}
