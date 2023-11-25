#! /bin/bash

set -e

./install_godot.sh

./godot ./src/project.godot </dev/null &>/dev/null &

