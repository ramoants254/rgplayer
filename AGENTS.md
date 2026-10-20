# rgplayer development rules

## Scope

rgplayer is a clean-room Linux media player. Implement one feature at a time, keep the change testable, and preserve the architecture described in `PROJECT.md`.

## Technical rules

- Use C++20, Qt 6.8 or newer, Qt Quick, and CMake.
- Keep libmpv ownership in the core layer. QML talks to application-layer controllers, never directly to libmpv.
- Forward mpv events to the Qt UI thread with queued signals.
- Prefer small interfaces and dependency injection in application code so controllers can be tested without a live player.
- Add or update a focused test with each behavior change.
- Run the narrowest relevant test, then the full test suite before accepting a feature.
- Format C++ with `clang-format`; keep QML readable and use the shared theme tokens.

## Product and design constraints

- The default palette is dark with orange used as a signal for progress, focus, and primary actions.
- Every interactive control must have keyboard access, a visible focus state, and an accessible name.
- Do not copy PotPlayer code, assets, skins, icons, or branding. Record third-party licenses in `THIRD_PARTY_NOTICES.md` before shipping dependencies or bundled assets.

## Working agreement

- Keep public behavior documented in `docs/spec/` before implementation.
- Avoid unrelated refactors and generated artifacts in source changes.
- Do not claim a build or test passed unless it was run in the current environment.
