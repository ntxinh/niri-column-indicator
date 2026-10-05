import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "niri-column-indicator"

    SliderSetting {
        settingKey: "iconSize"
        label: "Kích thước icon"
        description: "Kích thước icon ứng dụng trong mỗi cột (px)"
        defaultValue: 18
        minimum: 12
        maximum: 32
        unit: "px"
    }

    ToggleSetting {
        settingKey: "hideWhenSingleColumn"
        label: "Ẩn khi chỉ có 1 cột"
        description: "Ẩn widget khi workspace chỉ còn một cột"
        defaultValue: true
    }
}
