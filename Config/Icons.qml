pragma Singleton

import Quickshell

Singleton {
    readonly property string menu: "󰣇"
    readonly property string search: "󰍉"
    readonly property string close: "󰅖"
    readonly property string check: "󰄬"
    readonly property string chevronDown: "󰅀"
    readonly property string chevronRight: "󰅂"
    readonly property string plus: "󰐕"
    readonly property string trash: "󰩹"
    readonly property string refresh: "󰑐"
    readonly property string settings: "󰒓"
    readonly property string folder: "󰉋"
    readonly property string download: "󰇚"

    readonly property string power: "󰐥"
    readonly property string reboot: "󰜉"
    readonly property string logout: "󰍃"
    readonly property string suspend: "󰒲"
    readonly property string lock: "󰌾"

    readonly property string volumeHigh: "󰕾"
    readonly property string volumeMedium: "󰖀"
    readonly property string volumeLow: "󰕿"
    readonly property string volumeMuted: "󰝟"
    readonly property string micOn: "󰍬"
    readonly property string micOff: "󰍭"

    readonly property string wifi: "󰤨"
    readonly property string wifiOff: "󰤮"
    readonly property string ethernet: "󰈀"
    readonly property string bluetooth: "󰂯"
    readonly property string bluetoothOff: "󰂲"
    readonly property string bluetoothConnected: "󰂱"

    readonly property string cpu: "󰻠"
    readonly property string memory: "󰍛"
    readonly property string disk: "󰋊"
    readonly property string download_: "󰇚"
    readonly property string upload: "󰕒"
    readonly property string server: "󰒋"

    readonly property string bell: "󰂚"
    readonly property string bellOff: "󰂛"
    readonly property string dnd: "󰍶"
    readonly property string calendar: "󰃭"
    readonly property string image: "󰋩"
    readonly property string display: "󰍹"
    readonly property string keyboard: "󰌌"

    readonly property string play: "󰐊"
    readonly property string pause: "󰏤"
    readonly property string next: "󰒭"
    readonly property string previous: "󰒮"
    readonly property string music: "󰝚"

    function wifiLevel(strength: int): string {
        const ramp = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"];
        return ramp[Math.min(4, Math.floor(strength / 25))];
    }

    function volumeLevel(percent: int, muted: bool): string {
        if (muted || percent === 0)
            return volumeMuted;
        return percent < 34 ? volumeLow : percent < 67 ? volumeMedium : volumeHigh;
    }
}
