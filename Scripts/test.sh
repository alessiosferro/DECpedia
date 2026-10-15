#!/bin/bash
set -euo pipefail
taskRoot="$(cd "$(dirname "$0")/.." && pwd)"
taskBuild="${DECPEDIA_BUILD_DIR:-$taskRoot/Build}"
if [[ -z "${DEVELOPER_DIR:-}" && "$(/usr/bin/xcode-select -p)" == *CommandLineTools* && -d /Applications/Xcode.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
mkdir -p "$taskBuild"
export CLANG_MODULE_CACHE_PATH="$taskBuild/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$taskBuild/SwiftModuleCache"
/usr/bin/xcrun swift test --package-path "$taskRoot" --scratch-path "$taskBuild/SwiftPM" --cache-path "$taskBuild/PackageCache" "$@"
