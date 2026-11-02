# Root on NixOS

Checked 2026-11-02 against Root 0.9.159.

## Short answer

There is no Root package in nixpkgs and no flake worth trusting, so `root.nix` packages the upstream AppImage directly. That means you trust Root the company and nothing else. No third-party repackager sits in between.

## Where the binary comes from

- The download page (rootapp.com/download) offers Linux only as an AppImage, x64 and arm64. No deb, rpm, Flatpak or Snap.
- That link, `installer.rootapp.com/installer/Linux/X64/Root.AppImage`, has no version in it and gets replaced on every release. The page shows no version, checksum or signature.
- The app updates itself with Velopack. Velopack publishes a release feed next to the AppImage: `installer/Linux/X64/releases.linux.json`. It lists every version with a SHA256, and each version has a fixed URL like `Root-0.9.159-linux-full.nupkg`.
- The nupkg is a zip holding one file, `lib/app/Root.AppImage`. I downloaded both. The nupkg matches the feed's SHA256 (`43cfcccc…25136b1`) and the AppImage inside is byte-identical to the download page's one (`8779b7a6…899b995`).

`root.nix` pins the versioned nupkg by the feed's hash. A hash pin only proves you get the same bytes every time. It doesn't prove Root built them. Root publishes no GPG or code signature for Linux.

## What is inside

The AppImage unpacks to 1.4 GB.

| Part | What it is |
|---|---|
| `Root` (316 MB) | .NET single-file app, Avalonia UI drawn with SkiaSharp |
| `chromium/` (483 MB binary) | Chromium bundled through DotNetBrowser, a commercial TeamDev library. Renders embedded "Root apps" and billing pages |
| `liblivekit_ffi.so` | LiveKit WebRTC client 0.13.1, voice and video |
| `libAudioEffectsSDK.so` | Effects SDK 1.7.2 noise suppression, proprietary |
| `libuiohook.so` | Global keyboard and mouse hook, used for push-to-talk. Talks to X11 only |
| `UpdateNix` | Velopack updater 1.2.161 (Rust) |
| `Root.dbg` | 368 MB of debug symbols shipped alongside the release binary |

Nothing is open source. All of it runs as your user with your home directory.

## Things to know

- Telemetry. The binary includes the Sentry SDK (crash reports) and PostHog (product analytics, `us.i.posthog.com`). The app does not mention an opt-out on the download page.
- Global input hook. libuiohook reads all keyboard and mouse input under X11 for push-to-talk. Under Wayland it only sees XWayland windows, so push-to-talk while another native Wayland window has focus will probably not work. The flip side is it can't snoop native Wayland apps either.
- Self-update is off. On launch the app logs "App is not installed via Velopack, skipping update checks". Updates happen when you bump `version` and `hash` in `root.nix`.
- The bundled Chromium is whatever DotNetBrowser shipped and won't get nixpkgs security patches. It only renders Root's own content, but it is a browser engine.
- The Linux build carries no signature of any kind.

## Updating

1. Read `https://installer.rootapp.com/installer/Linux/X64/releases.linux.json` and take the newest `Full` entry.
2. Set `version` in `root.nix` to its `Version`.
3. Convert its `SHA256` with `nix hash convert --hash-algo sha256 --to sri <hex>` and set `hash`.
4. Build and switch.

## Stronger sandbox, if you want one

The wrapper is the standard `appimageTools` bubblewrap FHS env. It fakes a normal Linux file layout but does not isolate anything: home, network and the session bus are all open. For real isolation, wrap it with `nixpak` and pick what it can see, or run it as a separate user. Given it's a chat app that needs your mic, camera and screen, most of that access would have to be granted back anyway.
