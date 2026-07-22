{ pkgs }:

let
  version = "1.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "leriart";
    repo = "NothingLess";
    rev = "4a6eea7cc78a61a6a4b1ee3bd73daa61aad87320";
    hash = "sha256-6jaVJOmCJKALKJPQQA7qcFCZPn06jhVvEzO4xnSEujE=";
  };

  supportPkgs = import ./support.nix { inherit pkgs; };


  corePkgs     = import ./core.nix      { inherit pkgs; };
  toolsPkgs    = import ./tools.nix     { inherit pkgs; };
  mediaPkgs    = import ./media.nix     { inherit pkgs; };
  appsPkgs     = import ./apps.nix      { inherit pkgs; };
  fontsPkgs    = import ./fonts.nix     { inherit pkgs; phosphorIcons = supportPkgs.phosphorIcons; };
  tesseractPkgs = import ./tesseract.nix { inherit pkgs; };

  launcherHelper = pkgs.writeShellScriptBin "nothingless-launch-app" ''
    set -u

    target="''${1:-}"
    state_dir="''${XDG_STATE_HOME:-''${HOME}/.local/state}/nothingless"
    log_file="''${state_dir}/launcher.log"

    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

    {
      ${pkgs.coreutils}/bin/date '+%Y-%m-%dT%H:%M:%S%z'
      printf 'target=%s\n' "$target"
      if [ -e "$target" ]; then
        echo "target_exists=1"
      else
        echo "target_exists=0"
      fi
      printf 'wayland_display=%s\n' "''${WAYLAND_DISPLAY:-}"
      printf 'xdg_current_desktop=%s\n' "''${XDG_CURRENT_DESKTOP:-}"
    } >> "$log_file"

    if [ -z "$target" ]; then
      echo "method=none reason=missing-target" >> "$log_file"
      exit 64
    fi

    desktop_target=""
    if [ -f "$target" ]; then
      desktop_target="$target"
    elif [[ "$target" != */* ]]; then
      search_dirs=("''${XDG_DATA_HOME:-$HOME/.local/share}")
      IFS=: read -r -a xdg_data_dirs <<< "''${XDG_DATA_DIRS:-}"
      for data_dir in "''${xdg_data_dirs[@]}"; do
        if [ -n "$data_dir" ]; then
          search_dirs+=("$data_dir")
        fi
      done

      for data_dir in "''${search_dirs[@]}"; do
        for candidate in "$data_dir/applications/$target" "$data_dir/applications/$target.desktop"; do
          if [ -f "$candidate" ]; then
            desktop_target="$candidate"
            break 2
          fi
        done
      done
    fi

    if [ -n "$desktop_target" ]; then
      echo "method=gio-launch" >> "$log_file"
      printf 'resolved_target=%s\n' "$desktop_target" >> "$log_file"
      (
        ${pkgs.util-linux}/bin/setpriv --ambient-caps=-all --inh-caps=-all ${pkgs.glib}/bin/gio launch "$desktop_target" >> "$log_file" 2>&1
        exit_code="$?"
        echo "exit_code=$exit_code" >> "$log_file"
      ) &
      echo "launcher_pid=$!" >> "$log_file"
      exit 0
    fi

    if ${pkgs.uwsm}/bin/uwsm check is-active >/dev/null 2>&1; then
      echo "method=uwsm-app" >> "$log_file"
      (
        ${pkgs.util-linux}/bin/setpriv --ambient-caps=-all --inh-caps=-all ${pkgs.uwsm}/bin/uwsm app -- "$target" >> "$log_file" 2>&1
        exit_code="$?"
        echo "exit_code=$exit_code" >> "$log_file"
      ) &
      echo "launcher_pid=$!" >> "$log_file"
      exit 0
    fi

    echo "method=none reason=unresolved-target" >> "$log_file"
    exit 66
  '';

  baseEnv = corePkgs ++ supportPkgs.packages ++ [ launcherHelper ] ++ toolsPkgs ++ mediaPkgs ++ appsPkgs ++ fontsPkgs ++ tesseractPkgs;

  envNothingLess = pkgs.buildEnv {
    name = "NothingLess-env";
    paths = baseEnv;
  };

  fontconfigConf = pkgs.writeTextDir "etc/fonts/conf.d/99-nothingless-fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <dir>${envNothingLess}/share/fonts</dir>
    </fontconfig>
  '';

  shellSrc = pkgs.stdenv.mkDerivation {
    pname = "nothingless-shell";
    inherit version src;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
      substituteInPlace $out/modules/widgets/dashboard/tmux/TmuxTab.qml \
        --replace-fail 'kitty -e tmux' 'ghostty -e tmux'
      substituteInPlace $out/config/Config.qml \
        --replace-fail '["kitty"]' '["ghostty"]'

      substituteInPlace $out/modules/widgets/launcher/LauncherView.qml \
        --replace-fail 'AppSearch.launchApp(app);' 'AppSearch.launchApp(app);' \
        --replace-fail 'appsById[newApps[i].id] = newApps[i];' 'let launchKey = i + ":" + (newApps[i].id || newApps[i].name || "app"); appsById[launchKey] = newApps[i]; newApps[i].launchKey = launchKey;' \
        --replace-fail 'appId: app.id,' 'appId: app.launchKey || app.id,'
      substituteInPlace $out/modules/services/AppSearch.qml \
        --replace-fail 'const path = app.fileName || app.path || app.filePath;' 'const path = app.desktopFile || app.fileName || app.path || app.filePath;' \
        --replace-fail 'runInActiveWorkspace("gio launch '"'"'" + escapedPath + "'"'"'");' 'runInActiveWorkspace("${launcherHelper}/bin/nothingless-launch-app '"'"'" + escapedPath + "'"'"'");' \
        --replace-fail '? "xdg-terminal-exec " + cmdString' '? "${pkgs.xdg-terminal-exec}/bin/xdg-terminal-exec " + cmdString' \
        --replace-fail 'p.command = ["bash", "-c", "cd ~ && setsid " + wrapped + " > /dev/null 2>&1 &"];' 'p.command = ["${pkgs.bash}/bin/bash", "-c", "cd ~ && ${pkgs.util-linux}/bin/setsid " + wrapped + " > /dev/null 2>&1 &"];' \
        --replace-fail 'p.command = ["bash", "-c", "cd ~ && env -u HL_INITIAL_WORKSPACE_TOKEN setsid " + command + " < /dev/null > /dev/null 2>&1 &"];' 'p.command = ["${pkgs.bash}/bin/bash", "-c", "cd ~ && ${pkgs.coreutils}/bin/env -u HL_INITIAL_WORKSPACE_TOKEN ${pkgs.util-linux}/bin/setsid " + command + " < /dev/null > /dev/null 2>&1 &"];'
      ${pkgs.perl}/bin/perl -0pi -e 's/(\n\s+id: app\.id,\n\s+)execString: app\.execString,/$1desktopFile: app.fileName || app.path || app.filePath || "",\n                execString: app.execString,/g' $out/modules/services/AppSearch.qml
      APPSEARCH_QML="$out/modules/services/AppSearch.qml" \
      LAUNCHER_HELPER="${launcherHelper}/bin/nothingless-launch-app" \
      ${pkgs.python3}/bin/python3 -c 'import os; from pathlib import Path; path = Path(os.environ["APPSEARCH_QML"]); helper = os.environ["LAUNCHER_HELPER"]; text = path.read_text(); start = text.index("    function launchApp(app) {"); needle = "\n        if (app.command && app.command.length > 0) {"; pos = text.index(needle, start); insert = "\n        if (app.id && app.id.length > 0) {\n            const desktopId = app.id.toString().replace(/[^A-Za-z0-9_.:-]/g, \"\");\n            if (desktopId.length > 0) {\n                runInActiveWorkspace(\"" + helper + " \" + desktopId);\n                return;\n            }\n        }\n"; path.write_text(text[:pos] + insert + text[pos:])'
      if ! grep -q 'desktopFile: app.fileName' $out/modules/services/AppSearch.qml; then
        echo "failed to add desktopFile to AppSearch results" >&2
        exit 1
      fi
      if ! grep -q 'const desktopId = app.id.toString' $out/modules/services/AppSearch.qml; then
        echo "failed to add AppSearch ID launch fallback" >&2
        exit 1
      fi
      substituteInPlace $out/modules/services/DesktopService.qml \
        --replace-fail 'runInActiveWorkspace("gio launch '"'"'" + escapedPath + "'"'"'");' 'runInActiveWorkspace("${launcherHelper}/bin/nothingless-launch-app '"'"'" + escapedPath + "'"'"'");' \
        --replace-fail 'processComponent.command = ["bash", "-c", "cd ~ && env -u HL_INITIAL_WORKSPACE_TOKEN setsid " + command + " < /dev/null > /dev/null 2>&1 &"];' 'processComponent.command = ["${pkgs.bash}/bin/bash", "-c", "cd ~ && ${pkgs.coreutils}/bin/env -u HL_INITIAL_WORKSPACE_TOKEN ${pkgs.util-linux}/bin/setsid " + command + " < /dev/null > /dev/null 2>&1 &"];'
      ${pkgs.perl}/bin/perl -0pi -e 's/\n\s*CompositorKeybinds \{\n\s*id: compositorKeybinds\n\s*\}/\n    \/\/ Hyprland keybinds are managed by the Nix config so core shortcuts\n    \/\/ keep working even if the shell crashes.\n    Loader {\n        active: false\n        sourceComponent: CompositorKeybinds {}\n    }/' $out/shell.qml
      if grep -q 'id: compositorKeybinds' $out/shell.qml; then
        echo "failed to disable NothingLess CompositorKeybinds" >&2
        exit 1
      fi
    '';
  };

  launcher = pkgs.writeShellScriptBin "nothingless" ''
    export NOTHINGLESS_QS="${pkgs.quickshell}/bin/qs"
    export PATH="${envNothingLess}/bin:$PATH"
    export QML2_IMPORT_PATH="${envNothingLess}/lib/qt-6/qml:$QML2_IMPORT_PATH"
    export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
    export FONTCONFIG_PATH="${fontconfigConf}/etc/fonts:''${FONTCONFIG_PATH:-}"
    exec ${pkgs.util-linux}/bin/setpriv --ambient-caps=-all --inh-caps=-all ${shellSrc}/cli.sh "$@"
  '';

in
launcher
