# Phase 3: Power Playback

## Purpose

Add the first power-user workflows without coupling QML directly to libmpv: playlist management, speed control, frame stepping, and A/B looping.

## Current behavior

- Playlist entries are exposed through `PlaylistModel` and persisted with `QSettings`.
- Opening a file from the picker, drop target, command line, or path field adds it to the playlist.
- The playlist drawer can select and clear entries.
- Playback speed is adjustable from 0.25x through 4.0x.
- Frame-step, A-loop, B-loop, and loop-clear commands are available.
- `[` and `]` adjust speed; `.` steps one frame.
- Resume positions are saved per file and restored after loading.
- Audio and subtitle tracks can be cycled, and chapters can be navigated.
- Seek-bar hover requests generate a cached scaled preview frame through FFmpeg.

## Acceptance criteria

- Playlist model updates emit correct Qt model notifications.
- Playlist selection routes through `PlayerController` to libmpv.
- Power commands remain behind the application/controller boundary.
- The project configures, builds, and starts with a local media file.
- No generated build output is required as source input.
- Thumbnail generation is asynchronous and does not block the primary mpv playback context.
