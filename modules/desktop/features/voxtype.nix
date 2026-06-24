{ inputs, ... }:
{
  flake.modules.homeManager.desktop-feature-voxtype =
    { ... }:
    {
      imports = [ inputs.voxtype.homeManagerModules.default ];

      programs.voxtype = {
        enable = true;
        package = inputs.voxtype.packages.x86_64-linux.vulkan;
        engine = "whisper";
        model.name = "large-v3-turbo";
        service.enable = true;
        settings = {
          hotkey = {
            enabled = true;
            key = "RIGHTALT";
            modifiers = [ ];
            mode = "toggle";
          };
          whisper.language = "en";
          # Disable voxtype's built-in on-screen waveform; Nova provides its own indicator.
          osd.enabled = false;
          output = {
            mode = "type";
            fallback_to_clipboard = true;
          };
          text.spoken_punctuation = true;
        };
      };
    };
}
