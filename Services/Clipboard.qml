pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    function copy(text: string): void {
        proc.running = false;
        proc.exec(["wl-copy", "--", text]);
    }

    Process {
        id: proc
    }
}
