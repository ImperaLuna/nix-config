{ lib, config, pkgs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.evdev ]);
  script = pkgs.writeText "mouse-forward-to-kp9.py" ''
    import evdev, subprocess, json, os, glob
    from evdev import ecodes, UInput, InputDevice

    TARGET_CLASS = "Albion-Online"
    HYPRCTL = "${pkgs.hyprland}/bin/hyprctl"

    def get_hyprland_env():
        sockets = glob.glob("/run/user/*/hypr/*/.socket.sock")
        if sockets:
            sig = sockets[0].split("/hypr/")[1].split("/")[0]
            uid = sockets[0].split("/run/user/")[1].split("/")[0]
            return {"HYPRLAND_INSTANCE_SIGNATURE": sig, "XDG_RUNTIME_DIR": f"/run/user/{uid}"}
        return {}

    def is_albion_focused():
        try:
            env = {**os.environ, **get_hyprland_env()}
            out = subprocess.check_output([HYPRCTL, "activewindow", "-j"], env=env)
            win = json.loads(out)
            return win.get("class", "").lower() == TARGET_CLASS.lower()
        except Exception:
            return False

    def find_mouse():
        for path in evdev.list_devices():
            dev = InputDevice(path)
            caps = dev.capabilities()
            if ecodes.EV_KEY in caps and ecodes.BTN_EXTRA in caps[ecodes.EV_KEY]:
                return dev
        return None

    mouse = find_mouse()
    if not mouse:
        print("No mouse with forward button found")
        exit(1)

    print(f"Listening on: {mouse.name} ({mouse.path})")
    ui = UInput({ecodes.EV_KEY: [ecodes.KEY_KP9]}, name="btn-forward-to-kp9")

    try:
        for event in mouse.read_loop():
            if event.type == ecodes.EV_KEY and event.code == ecodes.BTN_EXTRA:
                if is_albion_focused():
                    ui.write(ecodes.EV_KEY, ecodes.KEY_KP9, event.value)
                    ui.syn()
    except KeyboardInterrupt:
        pass
    finally:
        ui.close()
  '';
in

{
  options.modules.albion.autorun = lib.mkEnableOption "albion autorun";

  config = lib.mkIf config.modules.albion.autorun {
    systemd.user.services.mouse-forward-to-kp9 = {
      Unit = {
        Description = "Map mouse forward button to KP9 (Albion only)";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pythonEnv}/bin/python3 ${script}";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
