import QtQuick
import Quickshell.Io
import qs.Services

// Column data derived from the NiriService singleton — no extra processes.
QtObject {
    id: root

    readonly property var focusedWindow: NiriService.windows.find(w => w.is_focused)

    // Column index of the focused window (1-based, per niri).
    readonly property int currentColumn: focusedWindow && focusedWindow.layout && focusedWindow.layout.pos_in_scrolling_layout
        ? focusedWindow.layout.pos_in_scrolling_layout[0]
        : -1
    readonly property int currentWorkspaceId: focusedWindow
        ? focusedWindow.workspace_id
        : parseInt(NiriService.focusedWorkspaceId) // string id; NaN when unknown → no columns

    readonly property var sortedWindows: NiriService.windows
        .filter(w => w.layout
                && w.layout.pos_in_scrolling_layout
                && w.workspace_id === currentWorkspaceId)
        .sort((a, b) => a.layout.pos_in_scrolling_layout[0] - b.layout.pos_in_scrolling_layout[0])

    // One entry per column: index, app id, focus state, stacked-window count, titles.
    readonly property var columns: {
        let cols = [];
        for (let i = 0; i < sortedWindows.length; i++) {
            const win = sortedWindows[i];
            const colIndex = win.layout.pos_in_scrolling_layout[0];
            let col = cols.find(c => c.index === colIndex);
            if (!col) {
                const fullId = win.app_id || "Unknown";
                col = {
                    index: colIndex,
                    appId: fullId.substring(fullId.lastIndexOf(".") + 1),
                    fullAppId: fullId,
                    isFocused: false,
                    windowCount: 0,
                    titles: []
                };
                cols.push(col);
            }
            col.windowCount++;
            if (win.is_focused)
                col.isFocused = true;
            if (win.title)
                col.titles.push(win.title);
        }
        return cols;
    }

    function focusColumn(index) {
        focusProcess.command = ["niri", "msg", "action", "focus-column", String(index)];
        focusProcess.running = true;
    }

    readonly property Process focusProcess: Process {
        running: false
    }
}
