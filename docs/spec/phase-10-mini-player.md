# Phase 10 — Mini Player (Picture-in-Picture) Mode

## Overview

Mini Player mode transforms `rgplayer` into a compact, floating, always-on-top window suitable for background watching or working alongside other desktop applications.

## User Access

- Shortcut: Pressing `M` toggles Mini Player mode.
- Context menu: "🗖  Mini Player (M)".
- Exit: Pressing `M`, `Escape`, or clicking the Restore button in the top-right overlay.

## Window Behavior

- Entering Mini Player:
  - Stores current window geometry (`x`, `y`, `width`, `height`).
  - Sets window size to compact dimensions (e.g. 360 x 202).
  - Enables `Qt.WindowStaysOnTopHint` flag.
  - Closes any open drawers or popups (playlist, settings, media info).
- Exiting Mini Player:
  - Restores previous window geometry.
  - Removes `Qt.WindowStaysOnTopHint` flag.

## Overlay Controls

When hovered in Mini Player mode, a lightweight translucent control layer appears:
- Top bar: Current media title and Restore button.
- Center / Bottom bar: Compact play/pause toggle, previous/next track buttons, and a slim progress seekbar.
- Auto-hides when mouse is inactive.
