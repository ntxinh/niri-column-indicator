import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modules.Plugins

PluginComponent {
    id: root

    ColumnTracker {
        id: niri
    }

    // --- Phần giao diện (UI) ---

    horizontalBarPill: Component {
        RowLayout {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: niri.columns

                delegate: Text {
                    required property var modelData
                    required property int index

                    // Chỉ hiển thị cột hiện tại và các cột liền kề (trái/phải)
                    visible: Math.abs(modelData.index - niri.currentColumn) <= 1

                    text: {
                        let appName = modelData.appId;
                        appName = appName.charAt(0).toUpperCase() + appName.slice(1);
                        if (appName.length > 10)
                            appName = appName.substring(0, 10) + "…";
                        if (modelData.windowCount > 1)
                            appName += "×" + modelData.windowCount;
                        if (modelData.isFocused)
                            return appName + " (c)"; // Đánh dấu cột hiện tại
                        return appName;
                    }

                    color: modelData.isFocused ? Theme.primary : Theme.surfaceText
                    font.bold: modelData.isFocused
                    font.pixelSize: Theme.fontSizeMedium

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: niri.focusColumn(modelData.index)
                    }
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
