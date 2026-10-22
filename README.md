# rgplayer

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Qt 6](https://img.shields.io/badge/Qt-6.8+-41CD52.svg?logo=qt&logoColor=white)](https://www.qt.io/)
[![C++20](https://img.shields.io/badge/C%2B%2B-20-00599C.svg?logo=c%2B%2B)](https://en.cppreference.com/w/cpp/20)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Tony%20Ndezwa-FFDD00.svg?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/ndezwat)

A fast, modern, and lightweight Linux media player with a sleek dark aesthetic, built clean-room using **Qt 6 (QML)** and **libmpv**.

---

## Highlights

- **Hardware-Accelerated Playback**: Powered by `libmpv` and FFmpeg with OpenGL rendering and hardware decoding support (VA-API, NVDEC, etc.).
- **Modern Dark UI**: Fluid, responsive interface built with Qt Quick and QML, featuring semi-transparent dark glass overlays and auto-hiding controls.
- **Dedicated Audio & Music Mode**: Sleek album player card with rotating vinyl record and dynamic sound visualizer bars during music playback.
- **Power-User Controls**:
  - Precise seeking with hover thumbnail previews.
  - Variable speed playback (0.25x to 4.0x).
  - A-B loop repetition.
  - Frame-by-frame stepping.
  - Multi-track audio and subtitle selection.
- **Playlist & Folder Drag-and-Drop**:
  - Drag and drop single files, multiple files, or whole music/video folders to queue and play.
  - Persistent playlist remembering your tracks across sessions.
- **Desktop Integration**:
  - **MPRIS2** D-Bus interface for OS-level media keys, lock screen integration, and desktop control applets.
  - Automatic screensaver and sleep inhibition during active playback.
- **Lightweight & Keyboard-First**: Designed for instant response and smooth workflow with keyboard shortcuts.

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Space` | Play / Pause |
| `Left` / `Right` | Seek backward / forward (5 seconds) |
| `Shift + Left` / `Shift + Right` | Precise seek backward / forward (1 second) |
| `Up` / `Down` | Volume up / down (5%) |
| `M` | Toggle mute |
| `F` / `Double Click` | Toggle fullscreen |
| `[` / `]` | Decrease / increase playback speed (0.25x steps) |
| `Backspace` | Reset playback speed to 1.0x |
| `.` *(period)* | Next frame (frame step) |
| `,` *(comma)* | Previous frame (frame step) |
| `N` / `B` | Next / Previous track in playlist |
| `L` | Set / Clear A-B repeat loop (`A` &rarr; `B` &rarr; `Clear`) |
| `O` / `Ctrl+O` | Open file dialog |
| `P` | Toggle playlist drawer |
| `S` / `Ctrl+,` | Toggle settings & adjustments drawer |
| `F1` | Help & Keyboard shortcuts reference |
| `Esc` | Close open drawer / Exit fullscreen |

---

## Installation via Flatpak

`rgplayer` is fully packaged as a standalone Flatpak adhering to FreeDesktop and AppStream standards.

### Build & Install Locally:
```bash
flatpak-builder --user --install --force-clean build-flatpak packaging/org.rgplayer.rgplayer.yml
```

### Run Flatpak:
```bash
# Launch empty player:
flatpak run org.rgplayer.rgplayer

# Launch directly with a video or audio file / folder:
flatpak run org.rgplayer.rgplayer /path/to/media.mp4
```

---

## Native Build Prerequisites & Dependencies

If you prefer building natively outside Flatpak:

### Ubuntu / Debian (24.04+)
```bash
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    libmpv-dev \
    qt6-base-dev \
    qt6-declarative-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-dialogs \
    libgl1-mesa-dev
```

### Fedora
```bash
sudo dnf install -y \
    gcc-c++ \
    cmake \
    ninja-build \
    pkgconf-pkg-config \
    mpv-libs-devel \
    qt6-qtbase-devel \
    qt6-qtdeclarative-devel
```

### Arch Linux
```bash
sudo pacman -S --needed \
    base-devel \
    cmake \
    ninja \
    mpv \
    qt6-base \
    qt6-declarative
```

---

## Native Building & Running

### 1. Configure the build
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
```

### 2. Compile
```bash
cmake --build build --parallel
```

### 3. Run
```bash
./build/rgplayer path/to/media.mp4
```

---

## Author & Support

Created by **Tony Ndezwa**.

If you enjoy using `rgplayer` or find it helpful, consider supporting the project:

[![Buy Me A Coffee](https://img.shields.io/badge/Support%20on-Buy%20Me%20A%20Coffee-orange?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/ndezwat)

---

## License

This project is licensed under the **GNU General Public License v3.0 or later** (GPL-3.0-or-later). See [LICENSE](LICENSE) for details.
