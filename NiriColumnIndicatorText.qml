import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // --- Phần logic lấy và xử lý dữ liệu từ Niri ---

    // Đối tượng Process để chạy lệnh lấy danh sách cửa sổ từ Niri
    Process {
        id: niriWindowsProcess
        command: ["niri", "msg", "--json", "windows"]
        running: true

        property var windowList: []

        stdout: SplitParser {
            onRead: {
                try {
                    // Gán đúng vào thuộc tính của Process thông qua id
                    niriWindowsProcess.windowList = JSON.parse(data);
                    console.log("Niri windows data:", JSON.stringify(niriWindowsProcess.windowList, null, 2));
                } catch (e) {
                    console.error("Lỗi phân tích JSON từ Niri:", e);
                }
            }
        }
    }

    // Tự động làm mới dữ liệu mỗi khi có sự kiện thay đổi cửa sổ từ Niri
    // Đây là cách đơn giản để đảm bảo widget luôn được cập nhật.
    // Trong môi trường production, bạn có thể muốn lắng nghe event-stream của Niri để hiệu quả hơn.
    Timer {
        interval: 500 // Kiểm tra mỗi nửa giây
        running: true
        repeat: true
        onTriggered: niriWindowsProcess.running = true
    }

    // Lấy cửa sổ đang được focus để xác định cột hiện tại
    readonly property var focusedWindow: niriWindowsProcess.windowList.find(w => w.is_focused)

    // Lấy chỉ số cột hiện tại (1-based)
    readonly property int currentColumn: focusedWindow && focusedWindow.layout && focusedWindow.layout.pos_in_scrolling_layout
        ? focusedWindow.layout.pos_in_scrolling_layout[0]
        : -1

    // Sắp xếp tất cả các cửa sổ dạng tile theo chỉ số cột
    readonly property var sortedWindows: niriWindowsProcess.windowList
        .filter(w => w.layout && w.layout.pos_in_scrolling_layout) // Chỉ lấy cửa sổ dạng tile
        .sort((a, b) => a.layout.pos_in_scrolling_layout[0] - b.layout.pos_in_scrolling_layout[0])

    // Tạo một mảng chỉ chứa các cột duy nhất và thông tin của chúng
    readonly property var columns: {
        let cols = [];
        let lastColIndex = -1;
        for (let i = 0; i < sortedWindows.length; i++) {
            let win = sortedWindows[i];
            let colIndex = win.layout.pos_in_scrolling_layout[0];
            if (colIndex !== lastColIndex) {
                let fullId = win.app_id || "Unknown";
                // Lấy phần sau dấu chấm cuối cùng: "org.mozilla.firefox" -> "firefox"
                let shortName = fullId.substring(fullId.lastIndexOf(".") + 1);
                shortName = shortName.charAt(0).toUpperCase() + shortName.slice(1);
                if (shortName.length > 10) {
                    shortName = shortName.substring(0, 10) + "…";
                }
                cols.push({
                    index: colIndex,
                    appId: shortName,
                    isFocused: win.is_focused
                });
                lastColIndex = colIndex;
            }
        }
        return cols;
    }


    // --- Phần giao diện (UI) ---

    horizontalBarPill: Component {
        RowLayout {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: root.columns

                delegate: Text {
                    required property var modelData
                    required property int index

                    // Chỉ hiển thị cột hiện tại và các cột liền kề (trái/phải)
                    visible: Math.abs(modelData.index - root.currentColumn) <= 1

                    text: {
                        let appName = modelData.appId;
                        if (modelData.isFocused) {
                            return appName + " (c)"; // Đánh dấu cột hiện tại
                        }
                        return appName;
                    }

                    color: modelData.isFocused ? Theme.primary : Theme.surfaceText
                    font.bold: modelData.isFocused
                    font.pixelSize: Theme.fontSizeMedium
                }
            }
        }
    }

    // Phần này cần thiết để widget hoạt động trên thanh bar dọc (nếu bạn có)
    verticalBarPill: Component {
        ColumnLayout {
            spacing: 8
            // Bạn có thể điều chỉnh giao diện cho thanh dọc ở đây
        }
    }
}
