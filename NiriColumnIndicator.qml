import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Widgets
import qs.Services
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

    // Lấy workspace_id của cửa sổ đang focus
readonly property int currentWorkspaceId: focusedWindow ? focusedWindow.workspace_id : -1

    // Chỉ lấy các cửa sổ trong workspace hiện tại, sắp xếp theo cột
    readonly property var sortedWindows: niriWindowsProcess.windowList
        .filter(w => w.layout
                && w.layout.pos_in_scrolling_layout
                && w.workspace_id === currentWorkspaceId)
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
                let shortName = fullId.substring(fullId.lastIndexOf(".") + 1);
                cols.push({
                    index: colIndex,
                    appId: shortName,          // Tên ngắn (dùng cho text nếu cần)
                    fullAppId: fullId,         // ID đầy đủ (dùng cho icon)
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
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: root.columns

                delegate: IconImage {
                    required property var modelData
                    required property int index

                    visible: true

                    // Lấy đường dẫn icon từ app_id gốc
                    // source: Icons.iconForAppId(modelData.fullAppId, "application-x-executable-symbolic")
                    source: DesktopService.resolveIconPath(modelData.fullAppId)

                    implicitWidth: 18
                    implicitHeight: 18
                    // Làm mờ các icon không phải cột hiện tại
                    opacity: modelData.isFocused ? 1.0 : 0.6
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
