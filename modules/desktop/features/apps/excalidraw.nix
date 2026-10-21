{ ... }:

{
  flake.modules.homeManager.apps-feature-excalidraw = { pkgs, ... }:
    let
      icon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/excalidraw/excalidraw/e9c856d262a14c12bd0bdc3f4ac55c7a86a71577/public/maskable_icon_x512.png";
        hash = "sha256-QPlV2+tBJZgnU8+WvkNreaGXQez+LndL7y1hPE440Gg=";
      };

      # Helium comes from desktop-feature-helium, so use it from PATH.
      excalidraw = pkgs.writeShellApplication {
        name = "excalidraw";
        text = ''
          exec helium --class=Excalidraw --app=https://excalidraw.com/ "$@"
        '';
      };
    in
    {
      home.packages = [ excalidraw ];

      xdg.desktopEntries.excalidraw = {
        name = "Excalidraw";
        comment = "Virtual whiteboard for sketching hand-drawn diagrams";
        exec = "excalidraw";
        icon = "${icon}";
        categories = [ "Graphics" ];
        startupNotify = true;
        settings.StartupWMClass = "Excalidraw";
      };
    };
}
