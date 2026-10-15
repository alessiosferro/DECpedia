#!/bin/bash
set -euo pipefail
taskRoot="$(cd "$(dirname "$0")" && pwd)"
"$taskRoot/Scripts/build-app.sh" --launch
