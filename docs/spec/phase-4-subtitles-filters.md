# Phase 4: Subtitles, Audio, and Filters

## Purpose

Expose common subtitle, audio-sync, and picture-adjustment controls through the application layer while keeping libmpv ownership in the core.

## Current behavior

- External subtitle files can be loaded through the settings file picker.
- Subtitle delay and scale are adjustable.
- Audio delay and audio/subtitle track cycling are available.
- Brightness, contrast, and saturation are adjustable.
- Screenshots can be requested from mpv.
- ASS styling override, font sizing, and subtitle codepage presets are available.
- Flat, voice, and bass audio presets plus loudness normalization are available.
- Deband and sharpen video filter presets are available.

## Acceptance criteria

- All controls route through `PlayerController` and `MpvWrapper`.
- Phase 4 settings load without QML errors.
- The application builds and starts with a local media file.
- Unsupported or failed mpv commands report through the existing error channel.
- Presets are routed through the application/controller boundary rather than raw QML mpv calls.
