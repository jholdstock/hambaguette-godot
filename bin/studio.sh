#! /usr/bin/env bash

set -e

./bin/install_godot.sh

./godot ./src/project.godot </dev/null &>/dev/null &

