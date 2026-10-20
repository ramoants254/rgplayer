# Phase 1: Playback Core

## Purpose

Add a small application-owned playback boundary around libmpv. The core owns the libmpv handle and render context; QML communicates only through application-layer properties, commands, and queued signals.

## Initial behavior

- Create and initialize one libmpv instance.
- Expose open, play, pause, seek, and volume commands through a controller.
- Forward relevant mpv events to the Qt thread using queued delivery.
- Report initialization and playback errors without crashing the application.
- Keep rendering behind a Qt Quick item; do not expose libmpv types to QML.

## Acceptance criteria

- A local media file can be opened and played through the application.
- Play/pause and volume changes reach libmpv through the controller boundary.
- mpv events do not mutate QML-facing state directly from the mpv callback thread.
- The wrapper releases all mpv resources on shutdown.
- A focused unit test covers controller command forwarding without requiring a live video window.

## Local prerequisites

Ubuntu development environments need the libmpv headers and library:

```sh
sudo apt install libmpv-dev mpv
```

The implementation should verify the installed libmpv API at configure time rather than silently compiling without playback support.
