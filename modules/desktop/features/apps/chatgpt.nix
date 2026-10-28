{ inputs, ... }:

{
  flake.modules.homeManager.apps-feature-chatgpt = { pkgs, ... }:
  let
    agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    # The native overlay allocates a canvas almost twice the display height.
    # Wayland cannot place that canvas around the orb as the app expects.
    voicePatch = pkgs.writeText "chatgpt-compact-voice.py" ''
      """Use the compact voice overlay layout on Linux, preserving ASAR offsets."""
      import re
      import sys
      from pathlib import Path

      path = Path(sys.argv[1])
      data = path.read_bytes()
      pattern = rb"let (?P<mode>[\w$]+)=(?P<tray>[\w$]+)==null\?`native`:`legacy`,"
      matches = list(re.finditer(pattern, data))
      if len(matches) != 1:
          raise SystemExit(f"expected one voice layout selector, found {len(matches)}")
      match = matches[0]
      replacement = b"let " + match["mode"] + b"=`legacy`,"
      replacement = replacement.ljust(len(match[0]), b" ")
      path.write_bytes(data[:match.start()] + replacement + data[match.end():])
    '';
    compactVoice = agents.chatgpt.unwrapped.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        python3 ${voicePatch} "$out/lib/chatgpt/resources/app.asar"
      '';
    });
  in
  {
    home.packages = [
      # niri needs an explicit secret backend so Electron can save sign-in.
      (agents.chatgpt.override {
        chatgpt-unwrapped = compactVoice;
        commandLineArgs = "--password-store=gnome-libsecret";
      })
    ];
  };
}
