{ lib, config, ... }:

{
  config = lib.mkIf config.modules.fish.enable {
    programs.fish.functions._fifc_parse_complist = ''
      command cat $_fifc_complist_path \
          | string unescape \
          | uniq \
          | awk -F '\t' '{ print $1 }'
    '';

    programs.fish.functions._fifc_source_cd_directories = ''
      set -l token (string unescape -- $fifc_token)
      set -l path (_fifc_expand_tilde "$token")
      set -l base_dir .
      set -l prefix

      if string match --quiet -- '*/' "$token"; or test -d "$path"
          set base_dir "$path"
      else if test -n "$path"
          set base_dir (path dirname -- "$path")
          set prefix (path basename -- "$path")
      end

      test -d "$base_dir"; or return

      if type -q fd
          fd --max-depth 1 --type d "^$prefix" "$base_dir" 2>/dev/null \
              | string replace --regex '^\\./' ''
      else
          find "$base_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
              | string replace --regex '^\\./' '' \
              | string match --regex ".*/$prefix[^/]*/*$"
      end
    '';

    # Override fifc's default command preview — loaded as a function file so it's
    # autoloaded in ALL fish processes, including the non-interactive fzf preview subprocess.
    programs.fish.functions._fifc_preview_cmd = ''
      if type -q tldr
          tldr $fifc_candidate 2>/dev/null | bat --paging=never --language=markdown; or man $fifc_candidate 2>/dev/null | bat --paging=never --language=markdown $fifc_bat_opts
      else if type -q bat
          man $fifc_candidate 2>/dev/null | bat --paging=never --language=markdown $fifc_bat_opts
      else
          man $fifc_candidate 2>/dev/null
      end
    '';
  };
}
