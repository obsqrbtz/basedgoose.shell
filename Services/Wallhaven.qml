pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config

Singleton {
    id: root

    readonly property var sortings: ["date_added", "toplist", "hot", "random", "views", "favorites"]
    readonly property var topRanges: ["1d", "3d", "1w", "1M", "3M", "6M", "1y"]

    property string sorting: "date_added"
    property string topRange: "1M"
    property string query: ""
    property int page: 1
    property int lastPage: 1

    property var results: []
    property bool loading: false
    property bool downloading: false
    property string error: ""

    property string _seed: ""

    function search(): void {
        if (loading)
            return;
        loading = true;
        error = "";

        const params = [`purity=100`, `page=${page}`, `sorting=${sorting}`];
        if (sorting === "toplist")
            params.push(`topRange=${topRange}`, "order=desc");
        else if (sorting === "hot" || sorting === "date_added")
            params.push("order=desc");
        if (sorting === "random" && page > 1 && _seed)
            params.push(`seed=${_seed}`);
        if (query)
            params.push(`q=${encodeURIComponent(query)}`);

        const request = new XMLHttpRequest();
        request.onreadystatechange = () => {
            if (request.readyState !== XMLHttpRequest.DONE)
                return;
            loading = false;
            if (request.status !== 200) {
                error = `Wallhaven request failed (${request.status || "no connection"})`;
                results = [];
                return;
            }
            try {
                const json = JSON.parse(request.responseText);
                results = (json.data ?? []).map(w => ({
                    id: w.id,
                    thumbUrl: w.thumbs?.large ?? "",
                    fullUrl: w.path ?? "",
                    resolution: w.resolution ?? ""
                }));
                lastPage = Math.max(1, json.meta?.last_page ?? 1);
                _seed = json.meta?.seed ?? _seed;
            } catch (e) {
                error = "Could not parse the Wallhaven response";
                results = [];
            }
        };
        request.open("GET", `https://wallhaven.cc/api/v1/search?${params.join("&")}`);
        request.send();
    }

    function setPage(value: int): void {
        page = Math.max(1, Math.min(lastPage, value));
        search();
    }

    function download(id: string, fullUrl: string, andApply: bool): void {
        if (downloading || !fullUrl)
            return;
        downloading = true;

        const url = fullUrl.replace(/w\.wallhaven\.cc\/(?!full)/, "w.wallhaven.cc/full/");
        const extension = (fullUrl.split(".").pop() ?? "jpg").split("?")[0].toLowerCase();
        const directory = Settings.expand(andApply ? Settings.wallpaperDownloadDir : Settings.wallpaperDir);
        const target = `${directory}/wallhaven-${id}.${extension}`;

        downloader.target = target;
        downloader.andApply = andApply;
        downloader.exec(["sh", "-c", 'mkdir -p "$1" && exec curl -sfL -o "$2" "$3"', "_", directory, target, url]);
    }

    Process {
        id: downloader

        property string target: ""
        property bool andApply: false

        onExited: code => {
            root.downloading = false;
            if (code !== 0)
                root.error = "Download failed";
            else if (andApply)
                Wallpapers.apply(target);
        }
    }
}
