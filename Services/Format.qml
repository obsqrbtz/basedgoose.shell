pragma Singleton

import Quickshell

Singleton {
    function bytes(value: real): string {
        const units = ["B", "KB", "MB", "GB", "TB", "PB"];
        let i = 0;
        while (value >= 1024 && i < units.length - 1) {
            value /= 1024;
            i++;
        }
        return `${value.toFixed(i < 2 ? 0 : 1)} ${units[i]}`;
    }

    function speed(kibPerSecond: real): string {
        if (kibPerSecond >= 1024)
            return `${(kibPerSecond / 1024).toFixed(1)} MB/s`;
        return `${Math.round(kibPerSecond)} KB/s`;
    }

    function percent(value: real): string {
        return `${Math.round(value)}%`;
    }

    function gigabytes(value: real): string {
        return `${value.toFixed(1)} GB`;
    }

    function time(seconds: real): string {
        const total = Math.max(0, Math.floor(seconds));
        return `${Math.floor(total / 60)}:${String(total % 60).padStart(2, "0")}`;
    }

    function age(date: date): string {
        const minutes = Math.floor((Date.now() - date.getTime()) / 60000);
        if (minutes < 1)
            return "now";
        if (minutes < 60)
            return `${minutes}m ago`;
        if (minutes < 1440)
            return `${Math.floor(minutes / 60)}h ago`;
        return `${Math.floor(minutes / 1440)}d ago`;
    }
}
