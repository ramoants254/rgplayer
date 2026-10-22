# Phase 7 — Context Menu, Resume, Recent Files

## Context Menu

Right-clicking anywhere on the video area opens a themed context menu with:

| Section | Items |
|---|---|
| Play / Pause | Toggle play state |
| Aspect Ratio ▸ | Auto, 16:9, 4:3, 2.35:1, 1:1 |
| Speed ▸ | 0.25x – 4.0x with current speed highlighted |
| Audio / Subtitles | Cycle audio track, cycle subtitle track |
| Screenshot | Capture current frame |

Implementation notes:
- `VideoContextMenu.qml` — standalone `Menu` component
- Uses existing `PlayerController` API; new method: `setAspectRatio(QString)`
- Backend sets mpv `video-aspect-override` property

## Resume Playback

Implemented in `PlayerController`:
- Saves position to `QSettings("resume/<url-encoded-path>")` periodically during playback
- Clears resume key if video reaches within 5 seconds of the end
- On `fileLoaded`, seeks to saved position if > 1 second

## Recent Files

- `PlayerController::recentFiles()` maintains a MRU list in `QSettings("recent/history")` (up to 15 items), emitting `recentFilesChanged`
- Filters against `QFile::exists` so deleted files aren't shown
- Welcome screen shows a "Recent Files" section below the open file controls
- Each item shows the filename (basename) with full path tooltip
- Clicking opens the file immediately
