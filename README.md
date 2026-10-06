# Niri Column Indicator

A DankMaterialShell (DMS) widget plugin that shows the columns on the current niri workspace as app icons on the bar.

## Features

- One icon per column, ordered by column position
- Click an icon to jump to that column (`niri msg action focus-column`)
- Focused column highlighted; unfocused icons dimmed
- Tooltip on hover: app name, or app name + window titles for stacked columns
- `×N` badge on columns with more than one window
- Falls back to the app's first letter when no icon resolves
- Settings: icon size (12–32px), hide widget when only one column remains
- Data comes from DMS's built-in `NiriService` (live event stream over the niri socket) — no polling, no extra processes

## Install

```sh
cd ~/.config/DankMaterialShell/plugins/

gh repo clone ntxinh/niri-column-indicator
# or
git clone https://github.com/ntxinh/niri-column-indicator.git
```

## Enable

1. Open **DMS Settings → Plugins** and click **Scan for Plugins**.
2. Add the `Niri Column Indicator` widget to a bar section (Left, Center, or Right) under **Settings → Bar → Widgets**.
3. Restart DMS if it does not appear:

   ```sh
   dms ipc call plugins reload niri-column-indicator
   ```

   or log out and back in.

## Settings

Open the plugin's settings page in DMS:

- **Icon size** — pixel size of each column icon (default 18).
- **Hide when only one column** — collapses the widget on workspaces with a single column (default on).

## Tips & Troubleshooting

- Inspect the raw window data niri returns:

  ```sh
  niri msg --json windows | jq
  ```

  Useful fields: `app_id`, `title`, `is_focused`, `workspace_id`, `layout.pos_in_scrolling_layout`.

- Other handy commands:

  ```sh
  dms run
  dms restart
  ```

## Files

- `NiriColumnIndicator.qml` — icon-based bar widget (active component)
- `ColumnTracker.qml` — shared column derivation on top of `NiriService`
- `NiriColumnSettings.qml` — plugin settings page
