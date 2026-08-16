{ pkgs, lib, ... }:

let
  zshFzfTab = pkgs.zsh-fzf-tab.overrideAttrs {
    postPatch = ''
      substituteInPlace lib/-ftb-fzf \
        --replace-fail \
          '_ftb_query="''${_ftb_query}$(command "$dd" bs=1G count=1 status=none iflag=nonblock < /dev/tty 2>/dev/null)" || true' \
          'if [[ -z ''${WSL_DISTRO_NAME-} && -z ''${WSL_INTEROP-} ]]; then
            _ftb_query="''${_ftb_query}$(command "$dd" bs=1G count=1 status=none iflag=nonblock < /dev/tty 2>/dev/null)" || true
          fi'
    '';
  };
in

{
  imports = [
    ./_aliases.nix
    ./_functions.nix
    ./_highlighting.nix
    ./_history.nix
    ./_atuin.nix
  ];

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # fzf-tab must load after compinit and before autosuggestions.
  programs.zsh.initContent = lib.mkOrder 650 ''
    bindkey -e

    zmodload zsh/terminfo
    if [[ -n "''${terminfo[kdch1]}" ]]; then
      bindkey "''${terminfo[kdch1]}" delete-char
    fi

    # fzf-tab's non-blocking type-ahead read blocks on WSL, making its menu
    # appear to require a second Tab. The patched package skips only that read.
    source ${zshFzfTab}/share/fzf-tab/fzf-tab.plugin.zsh

    # Zsh's completion definitions provide the candidates; fzf-tab is only the
    # universal presenter. This covers paths, options, subcommands, hosts, etc.
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
    zstyle ':fzf-tab:*' fzf-flags \
      --height=100% \
      --preview-window=right:60% \
      --header='TAB navigate  CTRL-SPACE mark/unmark  ENTER insert  ESC cancel'
    zstyle ':fzf-tab:complete:*:*' fzf-preview \
      'if [[ -n $realpath && -d $realpath ]]; then ${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons=always -- "$realpath"; elif [[ -n $realpath && -f $realpath ]]; then ${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 -- "$realpath"; elif [[ -n $desc && $desc != $word ]]; then print -r -- "$desc"; fi'

    bindkey -M emacs '^Z' undo
    bindkey -M viins '^Z' undo
  '';

  home.packages = [ pkgs.fzf ];
}
