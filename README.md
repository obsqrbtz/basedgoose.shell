# basedgoose.shell

A [Quickshell](https://quickshell.org/) desktop shell for wlroots-based Wayland
compositors. Tested on **Sway**, and built against the portable protocols
**Hyprland** and **Niri** also implement.

## Preview

![screenshot](assets/screenshot.png?raw=true)

## Features

- Bar with configurable position (top/bottom/left/right) and per-screen instances
- Workspaces, clock/calendar, system tray, media controls, volume, network,
  bluetooth, notifications, power menu
- Application launcher
- Notification centre and toasts
- Wallpaper browser with Wallhaven search
- Display manager: arrange, scale and rotate outputs, then save them to your
  compositor's config
- System monitor for the local machine and for remote hosts via Prometheus
- Colour schemes, editable and saveable from the settings window

## Compositor support

Workspaces come from the `ext-workspace-v1` Wayland protocol and output
configuration goes through `wlr-randr`, so neither is tied to a compositor.
Only two things are compositor-specific, and both are handled in
`Services/Compositor.qml`:

| | Hyprland | Sway | Niri |
|---|---|---|---|
| Log out | `hyprctl dispatch exit` | `swaymsg exit` | `niri msg action quit` |
| Output config syntax | `monitor = …` | `output … ` | KDL `output "…" { … }` |

Anything else falls back to `loginctl`. If your compositor does not implement
`ext-workspace-v1`, the workspaces module simply shows nothing.

## Installation

1. Install the dependencies:

   **Required** — `quickshell`, `wl-clipboard`, a JetBrainsMono Nerd Font.

   **Optional** — `wlr-randr` (display manager), `swww`/`awww`/`swaybg`
   (wallpapers, first one found wins), `zenity` or `yad` (directory pickers),
   `curl` (Wallhaven downloads), `lsblk`/`df` (storage readouts).

2. Clone into your Quickshell config directory:

   ```bash
   git clone https://github.com/obsqrbtz/basedgoose.shell.git ~/.config/quickshell/basedgoose.shell
   ```

3. Start it:

   ```bash
   qs -c basedgoose.shell
   ```

   To run from a checkout elsewhere, use `qs -p /path/to/basedgoose.shell`.

## Configuration

Settings live in `~/.config/basedgoose.shell/config.json` and are written back
whenever you change something in the settings window. The file is watched, so
editing it by hand applies immediately.

```json
{
  "barPosition": "top",
  "barModules": {
    "left":   ["menu", "workspaces", "media"],
    "center": ["stats"],
    "right":  ["network", "clock", "tray", "volume", "bluetooth", "notifications", "power"]
  },
  "colorScheme": "based-goose",
  "wallpaperDir": "~/Pictures/walls",
  "monitorServers": [{ "name": "nas", "host": "192.168.1.10", "port": "9090" }]
}
```

Available bar modules are the files in `Modules/Bar/Items/`, named without the
`Item.qml` suffix and with a lowercase first letter. Adding one means dropping
a file in that directory and naming it in `barModules` — there is no registry
to update.

Colour schemes are read from `colorschemes/` in this repository and from
`~/.config/basedgoose.shell/colorschemes/`; the latter wins on a name clash.

## IPC

```bash
qs -c basedgoose.shell ipc call <target> <toggle|open|close>
```

Windows: `launcher`, `wallpapers`, `displays`, `settings`, `cheatsheet`.

Bar popups: `volume`, `network`, `bluetooth`, `calendar`, `media`, `stats`,
`notifications`, `power`, `menu`. These act on the bar of the focused screen.

The shell menu's *IPC commands* entry lists all of these with copyable commands.

## Layout

```
shell.qml          windows and IPC handlers, nothing else
Config/            Settings, Theme, Schemes, Icons — all singletons
Services/          system state; no UI, no imports from Modules or Widgets
Widgets/           reusable primitives, including the three window types
Modules/Bar/       the bar, its sections, and one file per bar module
Modules/Popups/    popups anchored to bar modules
Modules/Overlays/  full-screen windows
Modules/Layers/    toasts and the volume OSD
```

## Acknowledgments

- [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell)
- [tripathiji1312/quickshell](https://github.com/tripathiji1312/quickshell)
