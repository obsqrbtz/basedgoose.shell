# basedgoose.shell

A [Quickshell](https://quickshell.org/) desktop shell for wlroots-based Wayland
compositors.

## Preview

![screenshot](assets/screenshot.png?raw=true)

## Features

- Bar with configurable position
- Workspaces, clock/calendar, system tray, media controls, volume, network,
  bluetooth, notifications, power menu
- Application launcher
- Notification center
- Wallpaper browser with Wallhaven integration
- Display manager
- System monitor for the local machine and for remote hosts via Prometheus
- Colour schemes

## Installation

1. Install the dependencies:

   **Required** - `quickshell`, `wl-clipboard`, some Nerd Font.

   **Optional** - `wlr-randr`, `swww`/`awww`/`swaybg`, `zenity` or `yad`,
   `curl`, `lsblk`/`df`.

2. Clone into your Quickshell config directory:

   ```bash
   git clone https://github.com/obsqrbtz/basedgoose.shell.git ~/.config/quickshell/basedgoose.shell
   ```

3. Start it:

   ```bash
   qs -c basedgoose.shell
   ```

## Configuration

Use settings window or edit `~/.config/basedgoose.shell/config.json` by hand

## IPC

```bash
qs -c basedgoose.shell ipc call <target> <toggle|open|close>
```

Available commands can be found in cheatsheet window.

## Acknowledgments

- [noctalia](https://github.com/noctalia-dev/noctalia-shell)
- [tripathiji1312/quickshell](https://github.com/tripathiji1312/quickshell)
- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
