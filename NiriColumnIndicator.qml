import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Common
import qs.Widgets
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    ColumnTracker {
        id: niri
    }

    // Settings (pluginData auto-reloads on pluginDataChanged)
    property int iconSize: pluginData.iconSize || 18
    property bool hideWhenSingle: pluginData.hideWhenSingleColumn !== undefined ? pluginData.hideWhenSingleColumn : true

    // --- Phần giao diện (UI) ---

    horizontalBarPill: Component {
        RowLayout {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.hideWhenSingle || niri.columns.length > 1

            Repeater {
                model: niri.columns

                delegate: RowLayout {
                    required property var modelData
                    required property int index

                    spacing: 2

                    // Separator between columns
                    Rectangle {
                        visible: index > 0
                        width: 1
                        height: 12
                        color: Theme.surfaceVariant
                        opacity: 0.4
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 4
                    }

                    // Column icon + focused highlight + window-count badge
                    Rectangle {
                        id: colIcon

                        implicitWidth: icon.implicitWidth + 6
                        implicitHeight: icon.implicitHeight + 4
                        radius: 4
                        color: modelData.isFocused ? Theme.primaryContainer : "transparent"

                        readonly property string iconPath: DesktopService.resolveIconPath(modelData.fullAppId) || ""

                        IconImage {
                            id: icon
                            anchors.centerIn: parent
                            source: colIcon.iconPath
                            implicitWidth: root.iconSize
                            implicitHeight: root.iconSize
                            visible: colIcon.iconPath !== ""
                            opacity: modelData.isFocused ? 1.0 : 0.6
                        }

                        // Fallback: first letter when no icon resolves
                        Text {
                            anchors.centerIn: parent
                            visible: colIcon.iconPath === ""
                            text: modelData.appId.charAt(0).toUpperCase()
                            color: modelData.isFocused ? Theme.primary : Theme.surfaceText
                            font.bold: modelData.isFocused
                            font.pixelSize: root.iconSize - 4
                        }

                        // Stacked-window badge
                        Rectangle {
                            visible: modelData.windowCount > 1
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.rightMargin: -2
                            anchors.topMargin: -2
                            width: 10
                            height: 10
                            radius: 5
                            color: Theme.primary

                            Text {
                                anchors.centerIn: parent
                                text: modelData.windowCount
                                color: Theme.onPrimary
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: niri.focusColumn(modelData.index)
                            onEntered: {
                                const tip = modelData.titles.length > 1
                                    ? modelData.appId + "\n" + modelData.titles.join("\n")
                                    : modelData.appId;
                                tooltip.show(tip, colIcon, 0, 0, "below");
                            }
                            onExited: tooltip.hide()
                        }
                    }
                }
            }

            DankTooltipV2 {
                id: tooltip
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
