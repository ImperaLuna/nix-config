{ lib, config, ... }:

{
  config = lib.mkIf config.modules.fish.enable {
    programs.fish.functions._fifc_parse_complist = ''
      command cat $_fifc_complist_path \
          | string unescape \
          | uniq \
          | awk -F '\t' '{ print $1 }'
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
