{ ... }:

{
  flake.modules.homeManager.apps-feature-ferdium = { pkgs, lib, ... }:
    let
      # Icons come from ferdium-recipes; the recipes bundled with Ferdium have none.
      recipesRev = "d606edecc575a08a22f05d8f6113e8906e3d1012";

      # The services Ferdium starts with. Each id is also the name of the
      # service's login partition (Partitions/service-<id>), so changing it
      # starts that service signed out. Services added in Ferdium itself stay,
      # they just get no launcher entry.
      services = [
        {
          id = "19cf95bd-2c78-4f51-91e8-482dec32f876";
          name = "WhatsApp";
          recipe = "whatsapp";
          iconHash = "sha256-w59W9+D/a4zwBsXDHQPMYZmZ4KevOKxZtIFR/AAvyzk=";
          keywords = [ "chat" "messages" ];
        }
        {
          id = "f1c7bb70-07e4-4f44-ac27-fe0fd4742659";
          name = "Proton Mail";
          recipe = "proton-mail";
          iconHash = "sha256-ZwBjHYZCTAIF70FwlkCtFSOBLngV3Rrb6Wgc4f3/pr8=";
          keywords = [ "email" "mail" "inbox" ];
        }
        {
          id = "8346abac-e7a4-4f96-bb95-ce6c005310ff";
          name = "Proton Calendar";
          recipe = "proton-calendar";
          iconHash = "sha256-2wMOtVqCjj6njweE6pYMtujLbRY3DOWKJ/GW3mPeTi4=";
          keywords = [ "calendar" "events" ];
        }
        {
          id = "89d24d62-4dd5-4bfe-affb-bea2d30b733e";
          name = "Linear";
          recipe = "linear";
          iconHash = "sha256-TdBtyqLmbaXAr0PgJeH6pP60Wc543DU3RMJNK8+7vEY=";
          keywords = [ "issues" "tasks" ];
        }
      ];

      # Ferdium only reads ferdium://service/<id> links on Windows; on Linux a
      # second launch just focuses the window. Turn both isWindows checks into
      # !isMac, as ferdium-app#2597 does. The replacement is the same length,
      # so app.asar's file offsets stay valid. The build fails if the checks
      # aren't both found: either the minified code changed, or #2597 shipped
      # and this patch can go.
      ferdium = pkgs.ferdium.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.asar pkgs.perl ];

        postFixup = old.postFixup + ''
          asar_file="$out/opt/Ferdium/resources/app.asar"
          size_before="$(stat -c %s "$asar_file")"
          perl -0777 -i -pe '
            $n = s/if\(([\w\$]+)\.isWindows\)\{(?=[\w\$]+\([\w\$]+=>\{const [\w\$]+=\(0,[\w\$]+\.getDeepLinkFromArgs\))/if(!$1.isMac   ){/g;
            END { if ($n != 2) { print STDERR "ferdium deep-link patch: expected 2 matches, found $n\n"; exit 1 } }
          ' "$asar_file"
          [ "$(stat -c %s "$asar_file")" = "$size_before" ]

          # The empty database Ferdium copies on first start, for seeding below.
          asar extract-file "$asar_file" internal-server/database/template.sqlite
          install -Dm644 template.sqlite "$out/share/ferdium/template.sqlite"
        '';
      });

      exec = "env ELECTRON_OZONE_PLATFORM_HINT=x11 ${lib.getExe' ferdium "ferdium"}";

      # A running Ferdium switches to the service right away. A cold one starts
      # minimized and drops a link that arrives before its services load, so
      # start it through its autostart unit and repeat the link for a while.
      # Once one lands, the rest change nothing.
      openService = pkgs.writeShellApplication {
        name = "ferdium-open-service";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          link="ferdium://service/$1"
          lock="$HOME/.config/Ferdium/SingletonLock"

          # The lock is a symlink to <host>-<pid> while Ferdium runs.
          running() {
            local target
            target="$(readlink "$lock")" || return 1
            kill -0 "''${target##*-}" 2>/dev/null
          }

          if running; then
            exec ${exec} "$link"
          fi

          systemctl --user start app-ferdium@autostart.service
          for _ in $(seq 50); do
            running && break
            sleep 0.1
          done

          for _ in $(seq 8); do
            sleep 1
            ${exec} "$link"
          done
        '';
      };

      sqlString = s: "'${lib.replaceStrings [ "'" ] [ "''" ] s}'";

      serviceSettings = index: service: builtins.toJSON {
        recipeId = service.recipe;
        inherit (service) name;
        isEnabled = true;
        isHibernationEnabled = false;
        isWakeUpEnabled = true;
        isNotificationEnabled = true;
        isBadgeEnabled = true;
        isMediaBadgeEnabled = false;
        trapLinkClicks = false;
        useFavicon = false;
        isMuted = false;
        isDarkModeEnabled = false;
        order = index;
      };

      seedSql = lib.concatImapStrings (index: service: ''
        INSERT INTO services (serviceId, name, recipeId, settings, created_at, updated_at)
        SELECT ${sqlString service.id}, ${sqlString service.name}, ${sqlString service.recipe},
          ${sqlString (serviceSettings (index - 1) service)}, datetime('now'), datetime('now')
        WHERE NOT EXISTS (SELECT 1 FROM services WHERE serviceId = ${sqlString service.id});
      '') services;
    in
    {
      home.packages = [ ferdium ];

      # Starts at login from ~/.config/autostart, so systemd runs it after
      # nova.service is ready and Ferdium finds Nova's tray. It starts
      # minimized through its own settings (startMinimized below).
      xdg.autostart = {
        enable = true;
        entries = [
          "${pkgs.makeDesktopItem {
            name = "ferdium";
            desktopName = "Ferdium";
            inherit exec;
            icon = "ferdium";
          }}/share/applications/ferdium.desktop"
        ];
      };

      # One launcher entry per service. Ferdium shows its window and switches
      # to that service.
      xdg.desktopEntries = lib.listToAttrs (map (service: {
        name = "ferdium-${service.recipe}";
        value = {
          inherit (service) name;
          comment = "${service.name} in Ferdium";
          exec = "${lib.getExe openService} ${service.id}";
          icon = "${pkgs.fetchurl {
            name = "ferdium-${service.recipe}-icon.svg";
            url = "https://raw.githubusercontent.com/ferdium/ferdium-recipes/${recipesRev}/recipes/${service.recipe}/icon.svg";
            hash = service.iconHash;
          }}";
          categories = [ "Network" ];
          settings = {
            Keywords = lib.concatMapStrings (keyword: "${keyword};") ([ "ferdium" ] ++ service.keywords);
            StartupWMClass = "ferdium";
          };
        };
      }) services);

      # Adds the services above that the database doesn't have yet, so a new
      # machine starts with them. Existing rows, and their settings changed in
      # Ferdium, are left alone. A running Ferdium picks new ones up on restart.
      home.activation.ferdiumServices = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        db_file="$HOME/.config/Ferdium/server.sqlite"
        if [ ! -f "$db_file" ]; then
          install -Dm600 ${ferdium}/share/ferdium/template.sqlite "$db_file"
        fi
        ${lib.getExe pkgs.sqlite} -cmd '.timeout 5000' "$db_file" <<'EOF'
        ${seedSql}
        EOF
      '';

      home.activation.ferdiumTraySettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings_file="$HOME/.config/Ferdium/config/settings.json"
        mkdir -p "$HOME/.config/Ferdium/config"

        if [ -f "$settings_file" ]; then
          tmp_file="$(mktemp)"
          ${lib.getExe pkgs.jq} '
            .autoLaunchOnStart = false |
            .autoLaunchInBackground = false |
            .startMinimized = true |
            .minimizeToSystemTray = true |
            .closeToSystemTray = true |
            .enableSystemTray = true |
            .runInBackground = true |
            .hibernationStrategy = 2592000 |
            .wakeUpHibernationStrategy = 2592000 |
            .webRTCIPHandlingPolicy = "default_public_interface_only"
          ' "$settings_file" > "$tmp_file"
          mv "$tmp_file" "$settings_file"
        else
          cat > "$settings_file" <<'EOF'
{
  "autoLaunchOnStart": false,
  "autoLaunchInBackground": false,
  "startMinimized": true,
  "minimizeToSystemTray": true,
  "closeToSystemTray": true,
  "enableSystemTray": true,
  "runInBackground": true,
  "hibernationStrategy": 2592000,
  "wakeUpHibernationStrategy": 2592000,
  "webRTCIPHandlingPolicy": "default_public_interface_only"
}
EOF
        fi
      '';

      # WhatsApp Web calling needs cross-origin isolation, which disablewebsecurity
      # breaks. Upstream dropped the flag in recipe 3.5.8 (ferdium-recipes#739).
      home.activation.ferdiumWhatsappCalls = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        recipe_file="$HOME/.config/Ferdium/recipes/whatsapp/package.json"

        if [ -f "$recipe_file" ]; then
          tmp_file="$(mktemp)"
          ${lib.getExe pkgs.jq} 'del(.config.disablewebsecurity)' "$recipe_file" > "$tmp_file"
          mv "$tmp_file" "$recipe_file"
        fi
      '';
    };
}
