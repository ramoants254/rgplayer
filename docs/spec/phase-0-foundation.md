# Phase 0: Foundation

## Purpose

Provide a reproducible Qt Quick application shell that can be built on the supported development environment before playback code is introduced.

## Acceptance criteria

- CMake configures with Qt 6.8 or newer and Ninja.
- A Debug build produces the `rgplayer` executable.
- Launching the executable opens a 1280x720 dark application window.
- The application exits cleanly when the window closes.
- The source tree contains no libmpv or playback behavior yet.

## Out of scope

- Media playback and file selection.
- Persistent settings, playlists, and desktop integration.
- Bundled fonts, icons, or test media.

## Local prerequisites

Install CMake 3.28+, Ninja, a C++20 compiler, and Qt 6.8+ with the Qt Quick development components. The supported project stack is described in `PROJECT.md`; the exact install method depends on the host distribution.
