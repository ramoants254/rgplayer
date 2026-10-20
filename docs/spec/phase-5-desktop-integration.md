# Phase 5: Desktop Integration

## Purpose

Make rgplayer discoverable and controllable as a Linux desktop media application while keeping desktop services optional in headless environments.

## Current behavior

- MPRIS playback controls register on the session bus as `org.mpris.MediaPlayer2.rgplayer`.
- Desktop entry metadata supports command-line and MIME launching.
- MIME package metadata declares the rgplayer playlist type.
- AppStream metadata is installed with the application.
- A Flatpak manifest targets the KDE runtime with Wayland, X11, PulseAudio, and GPU access.

## Acceptance criteria

- QtDBus integration compiles and does not make headless startup fatal.
- MPRIS service registration is visible on a live user session bus.
- Desktop metadata is valid XML and installed by CMake.
- The application still builds and starts with local media.
