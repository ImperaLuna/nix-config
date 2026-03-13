{ lib, config, ... }:

{
  imports = [
    ./steam/steam.nix

    # ── Albion (game-specific scripts) ──────────────────────────────────────
    ./albion/autorun.nix
  ];

  options.modules.gaming.enable = lib.mkEnableOption "gaming tools";

  config = lib.mkIf config.modules.gaming.enable {
    modules = {
      steam.enable   = true;

      # ── Albion ─────────────────────────────────────────────────────────────
      albion.autorun = true;
    };
  };
}
