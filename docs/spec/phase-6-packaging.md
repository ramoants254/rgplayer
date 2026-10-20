# Phase 6: Packaging

## Purpose

Make rgplayer reproducibly installable through the project’s primary Linux distribution formats.

## Current behavior

- CPack generates a Debian package from the install rules.
- The Flatpak manifest targets the KDE runtime and required media/graphics permissions.
- `packaging/build-appimage.sh` creates an install tree and delegates bundling to linuxdeploy.
- CI builds the application with libmpv development dependencies.
- Tagged releases build and upload the Debian package as a workflow artifact.

## Acceptance criteria

- Debug and release presets configure with the same source tree.
- `cmake --build --preset release --target package` produces a `.deb` when dependencies are installed.
- Desktop, MIME, and AppStream metadata are installed with the package.
- AppImage packaging fails clearly when linuxdeploy is unavailable.
