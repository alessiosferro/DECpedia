#!/bin/bash
set -euo pipefail
taskRoot="$(cd "$(dirname "$0")/.." && pwd)"
taskBuild="${DECPEDIA_BUILD_DIR:-$taskRoot/Build}"
if [[ -z "${DEVELOPER_DIR:-}" && "$(/usr/bin/xcode-select -p)" == *CommandLineTools* && -d /Applications/Xcode.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
mkdir -p "$taskBuild"
export CLANG_MODULE_CACHE_PATH="$taskBuild/ModuleCache"
/usr/bin/xcrun xcodebuild -project "$taskRoot/DECpedia.xcodeproj" -scheme DECpedia \
    -configuration Release -derivedDataPath "$taskBuild/DerivedData" \
    CODE_SIGN_IDENTITY=- CODE_SIGNING_ALLOWED=YES build
/usr/bin/ditto "$taskBuild/DerivedData/Build/Products/Release/DECpedia.app" "$taskBuild/DECpedia.app"
/usr/bin/codesign --verify --deep --strict "$taskBuild/DECpedia.app"
echo "App pronta: $taskBuild/DECpedia.app"
if [[ "${1:-}" == "--launch" ]]; then /usr/bin/open "$taskBuild/DECpedia.app"; fi
