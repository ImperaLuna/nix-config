# Carbonfox warm — Carbonfox accents on the html-artifact skill's warm base
rec {
  # ── Backgrounds ───────────────────────────────────────────────────────────
  bg        = "#121110";  # main background (warm near-black)
  bgAlt     = "#2A2724";  # secondary background, borders, selection

  # ── Foregrounds ───────────────────────────────────────────────────────────
  fg        = "#F5E7C6";  # primary text (warm cream)
  fgAlt     = "#4A4743";  # dimmed text, inactive elements
  fgDim     = "#A8A296";  # visible-but-muted: comments, autosuggestions

  # ── Accents ───────────────────────────────────────────────────────────────
  primary   = "#FD7014";  # orange — main accent, keywords, highlights
  secondary = "#be95ff";  # purple — secondary accent, vim visual mode

  # ── Functional ────────────────────────────────────────────────────────────
  info      = "#00ADB5";  # teal — commands, info, escape sequences
  error     = "#EE5396";  # pink — errors, deletions, replace cursor
  warning   = "#FAEB92";  # yellow — warnings
  success   = "#25BE6A";  # green — success, strings, insertions

  # ── Terminal ──────────────────────────────────────────────────────────────
  # Ghostty uses its built-in Carbonfox colors unless the theme sets these.
  terminal = { background = bg; foreground = fg; };
}
