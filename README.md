# rgplayer

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Qt 6](https://img.shields.io/badge/Qt-6.8+-41CD52.svg?logo=qt&logoColor=white)](https://www.qt.io/)
[![C++20](https://img.shields.io/badge/C%2B%2B-20-00599C.svg?logo=c%2B%2B)](https://en.cppreference.com/w/cpp/20)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Tony%20Ndezwa-FFDD00.svg?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/tndezwa)

A fast, modern, and lightweight Linux media player with a sleek dark aesthetic, built clean-room using **Qt 6 (QML)** and **libmpv**.

---

## Highlights

- **Hardware-Accelerated Playback**: Powered by `libmpv` and FFmpeg with OpenGL rendering and hardware decoding support (VA-API, NVDEC, etc.).
- **Modern Dark UI**: Fluid, responsive interface built with Qt Quick and QML, featuring semi-transparent gradient overlays and auto-hiding controls.
- **Power-User Controls**:
  - Precise seeking with hover thumbnail previews.
  - Variable speed playback (0.25x to 4.0x).
  - A-B loop repetition.
  - Frame-by-frame stepping.
  - Multi-track audio and subtitle selection.
- **Desktop Integration**:
  - **MPRIS2** D-Bus interface for OS-level media keys, lock screen integration, and desktop control applets.
  - Automatic screensaver and sleep inhibition during active playback.
- **Lightweight & Keyboard-First**: Designed for instant response and smooth workflow with keyboard shortcuts.

---

## Screenshots

> *Dark minimalist player with floating controls and hover seek preview.*

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Space` | Play / Pause |
| `Left` / `Right` | Seek backward / forward (5 seconds) |
| `Shift + Left` / `Shift + Right` | Seek backward / forward (1 second) |
| `Up` / `Down` | Volume up / down (5%) |
| `M` | Toggle mute |
| `F` / `Double Click` | Toggle fullscreen |
| `[` / `]` | Decrease / increase playback speed |
| `Backspace` | Reset speed to 1.0x |
| `.` *(period)* | Next frame (frame step) |
| `,` *(comma)* | Previous frame (frame step) |
| `L` | Set / Clear A-B repeat loop |
| `O` | Open file dialog |
| `P` | Toggle playlist drawer |
| `S` | Open settings |
| `Esc` | Exit fullscreen |

---

## Prerequisites & Dependencies

To build `rgplayer`, ensure you have the following installed:

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

## Building & Running

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
# Launch player empty or open directly with a file:
./build/rgplayer path/to/video.mp4
```

---

## Author & Support

Created by **Tony Ndezwa**.

If you enjoy using `rgplayer` or find it helpful, consider supporting the project:

[![Buy Me A Coffee](https://img.shields.io/badge/Support%20on-Buy%20Me%20A%20Coffee-orange?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/tndezwa)

---

## License

This project is licensed under the **GNU General Public License v3.0 or later** (GPL-3.0-or-later). See [LICENSE](LICENSE) for details.
