#! /usr/bin/env bash

set -e

./bin/install_godot.sh

if ! test -d src/export/html; then
    mkdir -p src/export/html
fi

./godot --headless --export-release "Web" "export/html/HamBaguette.html" ./src/project.godot 
