# Phase 9 — Media Information Dialog

## Overview

A dedicated, accessible dialog that displays detailed technical metadata about the currently playing media file.

## User Access

- Shortcut: Pressing `I` or `Ctrl+I` toggles the Media Information dialog.
- Context menu: "ℹ️  Media Information" menu item.
- Accessible name: "Media information dialog". Focus trap with `Escape` to close.

## Displayed Information

| Field | Source / mpv property | Example |
|---|---|---|
| File Name | `QFileInfo(currentFile).fileName()` | `sample.mkv` |
| File Path | `currentFile` | `/path/to/sample.mkv` |
| File Size | `file-size` formatted | `1.4 GB` |
| Container Format | `file-format` | `matroska` |
| Duration | `duration` formatted | `01:42:15` |
| Video Codec | `video-codec` | `hevc` |
| Resolution | `video-params/w` x `video-params/h` | `3840 x 2160` |
| Frame Rate | `container-fps` | `23.976 fps` |
| Video Bitrate | `video-bitrate` | `14.2 Mbps` |
| Hardware Decoding | `hwdec-current` | `vaapi` |
| Audio Codec | `audio-codec` | `flac` |
| Audio Channels | `audio-params/channel-count` | `6 channels (5.1)` |
| Sample Rate | `audio-params/samplerate` | `48000 Hz` |
| Audio Bitrate | `audio-bitrate` | `640 kbps` |

## Architecture

- `MpvWrapper::mediaInfo()` queries the current libmpv properties.
- `PlayerController::mediaInfo()` exposes the dictionary as a `Q_INVOKABLE QVariantMap` to QML.
- `MediaInfoDialog.qml` presents the data in clean categories (General, Video, Audio) styled with the dark theme and orange accents.
