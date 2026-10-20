# Phase 2: UI Shell

## Purpose

Provide the first reusable rgplayer visual system around the playback surface, while keeping the video content dominant and the controls keyboard accessible.

## Current behavior

- Shared dark palette and orange signal tokens are defined in `qml/Theme.qml`.
- The player shows a centered empty state until media duration is available.
- The playback bar exposes open, play/pause, seek, and volume controls.
- The playback bar fades toward the background after inactivity and reveals on hover.
- File picker and drag-and-drop remain available from the shell.
- Button focus uses an accent outline, and volume/reduced-motion preferences persist.
- A settings page is available from the playback bar or `Ctrl+,`.
- `Space` toggles playback, `Ctrl+O` opens the file picker, and `F11` toggles fullscreen.

## Acceptance criteria

- All visual colors in the shell come from `Theme.qml`.
- Every interactive control has an accessible name and keyboard focus behavior.
- The shell remains usable at the minimum window size.
- QML module compilation and headless startup pass.
- Reduced motion disables the playback-bar fade animation.
- `Escape` closes the settings page when it has focus.
