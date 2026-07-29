{ pkgs }:

{
  commandPattern = "bat|cat|cp|diff|du|eza|file|head|less|ln|ls|mkdir|more|mpv|mv|nano|nvim|readlink|realpath|rm|rmdir|stat|tail|touch|vi|view|vim|xdg-open|yazi";

  package = pkgs.writeShellApplication {
    name = "fzf-path-browser";
    runtimeInputs = with pkgs; [
      bat
      coreutils
      eza
      findutils
      fzf
    ];
    text = builtins.readFile ./_fzf-path-browser.sh;
  };
}
