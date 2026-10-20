#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
build_dir="${root_dir}/build/appimage"
app_dir="${build_dir}/AppDir"

cmake -S "${root_dir}" -B "${build_dir}" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build "${build_dir}"
DESTDIR="${app_dir}" cmake --install "${build_dir}"

if ! command -v linuxdeploy >/dev/null 2>&1; then
    printf '%s\n' "linuxdeploy is required to finish the AppImage bundle." >&2
    exit 1
fi

linuxdeploy --appdir "${app_dir}" --output appimage
