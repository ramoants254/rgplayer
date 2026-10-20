# PROJECT.md: Linux Media Player (working title: "rgplayer")

> A fast, feature-rich, keyboard-driven media player for Ubuntu and other Linux desktops, inspired by the *workflow and feature depth* of PotPlayer, built clean-room on open-source foundations.
>
> **Working title only.** Run a name and trademark check before any public release. Do not use "PotPlayer", its logo, icons or skins.

---

## 1. Objective

### 1.1 Vision
Give Linux users the power-user media experience people miss from PotPlayer on Windows: instant startup, wide format support, fine-grained playback control, and a polished dark UI.

### 1.2 Goals
1. Play virtually any local video/audio file and network stream smoothly with hardware decoding.
2. Offer PotPlayer-class control: variable speed, A-B repeat, frame stepping, subtitle and audio sync, on-screen display, deep hotkeys.
3. Ship a distinctive, accessible, modern UI that follows the Relego brand (dark, orange accent).
4. Run well on Ubuntu LTS (X11 and Wayland) and be easy to install (Flatpak first).
5. Be a sustainable open-source project with tests, CI and clear contribution rules.

### 1.3 Non-goals (v1.0)
- Not a Windows or macOS port.
- Not a media library/server (Plex/Jellyfin territory), only a lightweight recent-files and playlist layer.
- No DRM-protected streaming services.
- No copying of PotPlayer code, assets, skins, name or branding.

### 1.4 Success metrics
| Metric | Target |
|---|---|
| Cold start to first frame (local 1080p file) | < 1.0 s on mid-range hardware |
| Idle UI CPU while playing 1080p with hwdec | < 5% of one core |
| Seek latency (local file) | < 150 ms perceived |
| Crash-free sessions | > 99% |
| Hotkey coverage of core actions | 100% rebindable |
| Contrast of all text/controls | WCAG AA (4.5:1 text, 3:1 UI) |

---

## 2. Clean-room and ethics policy

This project reproduces **ideas and features**, never code or assets.

- Feature ideas come from public documentation, user-visible behavior and our own design. We write a plain-language feature spec (`docs/spec/`) *before* implementing.
- **No decompiling, disassembling or extracting resources from PotPlayer.** Its license terms likely forbid it, and a derivative of its code would taint the project.
- Reverse-engineering tools (for example REA with Ghidra) may only be used on software we **own or are explicitly authorized to analyze**, such as our own builds, or for open interoperability formats where the law and license allow it. When unsure, don't.
- All third-party code, fonts and media samples must have a compatible license recorded in `THIRD_PARTY_NOTICES.md`.
- Test media must be freely licensed (for example Blender open movies, Creative Commons clips).
- Not legal advice. If the project becomes public or commercial, have a lawyer review licensing and naming.

---

## 3. Tech stack

### 3.1 Summary
| Layer | Choice | Why |
|---|---|---|
| Playback engine | **libmpv** (render API) | Best-in-class decoding, filters, subtitles (libass), hwdec, scripting; battle-tested |
| Decoding backend | **FFmpeg** (via mpv) + **VAAPI / NVDEC / V4L2** hwdec | Broad codec support; GPU decode on Intel/AMD/NVIDIA |
| Language | **C++20** | Native performance, first-class Qt and mpv integration |
| UI framework | **Qt 6 + QML (Qt Quick)**, target **Qt 6.8 LTS or newer** | GPU-accelerated, themeable, great for custom dark UIs; good Wayland/X11 support |
| UI components | Qt Quick Controls 2, custom-styled to our design system | Full brand control without fighting native styles |
| Rendering bridge | `QQuickFramebufferObject` + `mpv_render_context` (OpenGL) | Proven path for embedding mpv in Qt Quick |
| Build | **CMake + Ninja**, `CMakePresets.json` | Standard, IDE-friendly, reproducible |
| Desktop integration | **QtDBus** (MPRIS2, screensaver inhibit, notifications), `.desktop` + MIME associations | Media keys, inhibit sleep, "Open with..." |
| Settings | TOML (via `toml++`) or `QSettings`; optional raw `mpv.conf` passthrough | Human-editable, power-user friendly |
| Thumbnails/preview | Hidden secondary mpv instance or FFmpeg (`libavformat`) | Seek-bar hover previews |
| Testing | **Qt Test** + **GoogleTest** (core logic), **QML TestCase** (UI), sample-media integration tests | Fast feedback at each layer |
| Quality | `clang-format`, `clang-tidy`, `cppcheck`, ASan/UBSan builds | Catch bugs early, matters when AI generates code |
| CI/CD | **GitHub Actions** (Ubuntu LTS runners), release workflow | Automated build, test, package |
| Packaging | **Flatpak** (primary), **.deb**, **AppImage** | Flatpak ships a current Qt and mpv regardless of distro version |
| Docs | Markdown in `docs/`, screenshots from CI | Keep spec, ADRs and user docs in the repo |
| License | **GPL-3.0-or-later** (recommended) | Distro builds of mpv are commonly GPL, so a combined work should be GPL-compatible. Verify the license of the exact libmpv build you link. |

> **Qt version note:** Ubuntu 24.04's apt Qt is older than 6.8. Develop against the **Flatpak KDE SDK** or install Qt 6.8 LTS+ via the Qt online installer/`aqtinstall`, so dev, CI and release all match.

### 3.2 Alternatives considered
| Option | Verdict |
|---|---|
| **Rust + GTK4/libadwaita + libmpv** | Strong, modern, great Wayland feel; smaller QML-like theming flexibility and fewer ready examples for custom player chrome. Good fallback. |
| **Python + PySide6 + python-mpv** | Fastest prototype, ideal for the Phase 1 spike. Heavier to package; slower for UI-heavy rendering. Use for throwaway experiments only. |
| **Electron/Tauri + web UI** | Easy styling, but video embedding with libmpv is awkward and memory/latency cost is higher. Rejected. |
| **GStreamer** | Capable, but weaker subtitle/filter ecosystem for this use case than mpv. Rejected. |
| **Fork an existing player** (Haruna, Celluloid, mpv-based) | Valid and much faster. Consider contributing upstream before building new. |

### 3.3 AI-assisted ("vibe coding") workflow
- One feature per prompt. Name the stack and the files involved.
- Require tests with every feature; run `ctest` and `clang-tidy` before accepting code.
- Commit after every working step (`git`), with small, reviewable diffs.
- Keep `AGENTS.md`/`CLAUDE.md` in the repo describing architecture, coding rules and the clean-room policy so every session starts with the same context.
- Review AI-written code for threading mistakes (mpv events vs the Qt UI thread) and memory ownership.

---

## 4. Architecture

```
┌──────────────────────────── QML UI ────────────────────────────┐
│  Shell · Controls · Playlist · Settings · OSD · Theme tokens   │
└───────────────▲───────────────────────────────┬────────────────┘
                │ properties / signals          │ commands
┌───────────────┴───────────────────────────────▼────────────────┐
│ App layer (C++): PlayerController · PlaylistModel ·            │
│ SettingsService · HotkeyMap · HistoryService · MprisService    │
└───────────────▲───────────────────────────────┬────────────────┘
                │ events (queued to UI thread)  │ mpv commands/props
┌───────────────┴───────────────────────────────▼────────────────┐
│ Core: MpvWrapper (RAII over libmpv) · RenderItem (FBO)         │
└────────────────────────────────┬───────────────────────────────┘
                                 ▼
                     libmpv → FFmpeg / libass / hwdec
```

Key rules:
- `MpvWrapper` owns the `mpv_handle`; mpv events arrive on mpv's thread and are forwarded to the UI thread with queued signals.
- UI never talks to libmpv directly, only through `PlayerController` (testable behind an interface).
- All visual values come from a single **Theme** singleton (see section 5).

### 4.1 Proposed repo layout
```
/
├─ CMakeLists.txt · CMakePresets.json
├─ PROJECT.md · AGENTS.md · LICENSE · THIRD_PARTY_NOTICES.md
├─ src/
│  ├─ core/        # MpvWrapper, render item
│  ├─ app/         # controllers, models, services
│  └─ main.cpp
├─ qml/
│  ├─ Theme.qml (singleton) · components/ · pages/
├─ resources/      # icons (SVG), fonts, .desktop, appstream metainfo
├─ tests/          # unit + integration
├─ packaging/      # flatpak manifest, deb, appimage
├─ docs/           # spec/, adr/, user guide
└─ .github/workflows/
```

---

## 5. Design system

### 5.1 Principles
1. **Content first.** Chrome fades away during playback; the video is the hero.
2. **Orange is a signal, not a surface.** Use the accent for progress, focus, primary actions and active states, never for large fills.
3. **Keyboard and mouse equal.** Every control reachable by hotkey and visible focus ring.
4. **Calm, high-contrast dark theme** by default; light theme is a later option.

### 5.2 Color tokens (derived from the Relego brand)
| Token | Hex | Use |
|---|---|---|
| `bg` | `#0A0A0C` | Window background |
| `surface` | `#141417` | Panels, playlist, control bar |
| `surfaceRaised` | `#1C1C21` | Menus, popovers, hover rows |
| `border` | `#2A2A31` | Dividers, outlines |
| `text` | `#F5F5F7` | Primary text |
| `textMuted` | `#8B93A7` | Secondary text, timestamps |
| `accent` | `#FF6A00` | Primary actions, seek progress, focus ring |
| `accentHover` | `#FF8533` | Hover |
| `accentPressed` | `#E55F00` | Pressed |
| `onAccent` | `#111111` | Text/icons on orange (as on the website's button) |
| `success` / `warning` / `danger` | `#3DD68C` / `#FFB020` / `#FF5C5C` | Status |

Check every pair for WCAG AA with a contrast tool before locking the tokens. These are starting values taken from the website screenshot and should be adjusted to your exact brand hex codes.

**Suggested improvement:** keep orange as the single accent and add a cool slate-blue neutral (`textMuted`) as the website already does. The warm/cool contrast keeps the UI readable over any video content.

### 5.3 Typography
- **Inter** for UI (matches the website's clean sans look), **JetBrains Mono** or Inter with tabular numerals for timecodes. Both are OFL-licensed, so bundle them.
- Scale: 12 / 14 / 16 / 20 / 28 px. Headings semibold, body regular.

### 5.4 Layout and components
- Floating **control bar** (auto-hides after ~2.5 s of no mouse movement): play/pause, seek bar with hover thumbnail, time, volume, speed chip, subtitle/audio menu, playlist toggle, fullscreen.
- Seek bar: thin at rest, thickens on hover, orange progress, buffered range in `border`.
- **OSD** for volume, speed, seek, subtitle delay (large, top-left, fades out).
- Collapsible **playlist drawer** (right), **settings** as a full page with search.
- Motion: 120-180 ms ease-out; respect a "reduce motion" setting.
- Icons: a single SVG set (for example Lucide, ISC license) tinted by tokens.
- Corner radius 10 px for panels, 8 px for buttons; subtle 1 px borders instead of heavy shadows.

### 5.5 Accessibility
Visible focus rings (2 px accent), full keyboard navigation, screen-reader names on all controls (Qt Accessibility), scalable UI (100-200%), no information conveyed by color alone.

---

## 6. Feature backlog

**P0 (MVP)**: open file / drag-drop / URL, play/pause/seek, volume/mute, fullscreen, playlist, hardware decoding, subtitle loading, remember last position, basic hotkeys.

**P1 (PotPlayer-class power)**: playback speed (fine steps + hotkeys), A-B loop, frame-by-frame step, subtitle delay/size/position/style, audio delay and track switching, chapter navigation, screenshot, seek-bar thumbnails, on-screen display, aspect ratio / zoom / rotate / flip, rebindable hotkeys, audio equalizer and normalization, video filters (brightness, contrast, saturation, deband, sharpen).

**P2 (polish)**: clip capture (GIF/MP4 range), bookmarks, playlist save/load (`.m3u`), recent files and resume, MPRIS media keys, sleep inhibit, theme variants and light mode, mpv Lua script support, network streams (HTTP/HLS, yt-dlp optional), multi-language UI.

---

## 7. Development phases

Estimates assume one developer working with an AI coding tool at roughly 10-15 hrs/week. Adjust to your pace.

### Phase 0: Foundations (week 1)
- Repo, license, `AGENTS.md`, this document, CI skeleton, clang-format/tidy configs.
- Dev environment on Ubuntu: Flatpak KDE SDK or Qt 6.8+, `libmpv-dev`, CMake, Ninja.
- Write `docs/spec/` feature list from public docs and hands-on use (clean-room).
- **Exit:** empty Qt window builds locally and in CI.

### Phase 1: Playback core spike (weeks 2-3)
- `MpvWrapper` + `RenderItem`: render a video file in a QML window.
- Open file via dialog and drag-drop; play/pause/seek; volume.
- Confirm hwdec works on your GPU (`hwdec=auto-safe`); test X11 and Wayland.
- **Exit:** plays a 1080p file with hardware decoding and correct A/V sync.

### Phase 2: UI shell and design system (weeks 4-6)
- `Theme.qml` tokens, fonts, icons, base components (button, slider, menu, toast).
- Control bar with auto-hide, seek bar, fullscreen, OSD, window chrome.
- Settings service (persisted), hotkey map (rebindable).
- **Exit:** UI matches design tokens; keyboard-only operation works; screenshot-based UI checks in CI.

### Phase 3: Power features (weeks 7-10)
- Speed control, A-B loop, frame step, audio/subtitle track menus and delay, aspect/zoom/rotate.
- Playlist model and drawer, recent files, resume position.
- Seek-bar hover thumbnails, screenshots.
- **Exit:** all P0 and most P1 features work with tests.

### Phase 4: Subtitles, audio and filters (weeks 11-12)
- Subtitle styling, encoding detection, external subtitle search path, drag-drop subtitles.
- Equalizer, normalization, video filter presets.
- **Exit:** subtitle and audio parity checklist passes on a set of tricky sample files (ASS styling, multiple audio tracks, odd encodings).

### Phase 5: Desktop integration and robustness (weeks 13-14)
- MPRIS (media keys, GNOME/KDE widgets), sleep inhibit, `.desktop`/MIME associations, command-line opening.
- Error handling (corrupt files, missing codecs), crash reporting opt-in, logging.
- Performance profiling; ASan/UBSan and long-run soak tests.
- **Exit:** meets the success metrics in section 1.4.

### Phase 6: Packaging and alpha release (weeks 15-16)
- Flatpak manifest (primary), `.deb`, AppImage; AppStream metadata and screenshots.
- Docs: user guide, hotkey cheat sheet, contribution guide.
- Alpha to a small group; triage feedback.
- **Exit:** installable on a clean Ubuntu LTS VM with one command.

### Phase 7: Beta, 1.0 and beyond
- Fix feedback, accessibility audit, translations, light theme.
- 1.0 release; publish to Flathub.
- Later: clip capture, bookmarks, scripting UI, streaming niceties, plugin ideas.

---

## 8. Risks and mitigations
| Risk | Mitigation |
|---|---|
| Qt Quick and libmpv GL integration quirks (Wayland, NVIDIA) | Do the Phase 1 spike early; test X11 + Wayland + Intel/AMD/NVIDIA; keep a software-render fallback |
| mpv threading mistakes from generated code | Single `MpvWrapper` owner, queued signals only, code review checklist |
| License conflict (GPL vs LGPL builds) | Pick GPL-3.0-or-later; record every dependency in `THIRD_PARTY_NOTICES.md` |
| Scope creep toward "everything PotPlayer does" | Strict P0/P1/P2 backlog; ship an MVP first |
| Naming/trademark trouble | Placeholder name, search before release; no PotPlayer assets |
| Reinventing existing players | Evaluate Haruna/Celluloid/mpv front-ends first; contribute upstream if they fit |
| Old Qt on distro repos | Develop and ship via Flatpak runtime |

---

## 9. Definition of done (per feature)
1. Behavior described in `docs/spec/`.
2. Unit/integration tests added and passing in CI.
3. `clang-tidy` clean; no new sanitizer findings.
4. Keyboard accessible, themed from tokens, screenshot attached to the PR.
5. User docs and hotkey table updated.

---

## 10. Immediate next steps
1. Create the repo and commit this file plus `AGENTS.md` and `LICENSE`.
2. Set up the dev environment (Flatpak KDE SDK or Qt 6.8+, `libmpv-dev`, CMake, Ninja).
3. Run the Phase 1 spike: a QML window rendering one video through libmpv.
4. Confirm your exact brand hex codes and update section 5.2.
