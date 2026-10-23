# Phase 8 — Playlist Drag & Reorder

## Behavior

Users can reorganize the playlist in two ways:
1. **Keyboard shortcuts**: When a playlist item is focused/selected in `PlaylistDrawer`:
   - `Alt+Up`: Move item up one position.
   - `Alt+Down`: Move item down one position.
2. **Move controls / Drag Handle**:
   - Each playlist item displays reordering buttons (Up / Down) or a drag handle when hovered or selected.
   - Calling `move(from, to)` properly shifts the items and adjusts the `currentIndex` if the playing track moves.

## Model API

`PlaylistModel`:
- `Q_INVOKABLE void move(int from, int to);`
- Emits Qt model move signals (`beginMoveRows` / `endMoveRows`) for smooth UI animation and updates.
- Maintains `currentIndex_` properly:
  - If `currentIndex_ == from`, `currentIndex_` becomes `to`.
  - If `currentIndex_` was between `from` and `to`, it shifts accordingly.
  - Emits `currentIndexChanged()` if the index changed.
- Saves the updated playlist state via `save()`.
