#! /usr/bin/env bash

set -e

VERSION="4.1.3-stable"
TEMPLATE_VERSION=""4.1.3.stable""

export EXE_FILENAME="Godot_v${VERSION}_linux.x86_64"
EXE_URL="https://github.com/godotengine/godot/releases/download/${VERSION}/${EXE_FILENAME}.zip"
TEMPLATE_URL="https://github.com/godotengine/godot/releases/download/${VERSION}/Godot_v${VERSION}_export_templates.tpz"

# Creating this file makes Godot run in self-contained mode.
touch ._sc_

if ! test -d ./editor_data; then
    mkdir -p ./editor_data/export_templates
fi

# If studio file doesnt exist, download and install it.
if ! test -f ./${EXE_FILENAME}; then
    echo "Downloading Godot v${VERSION}"
    wget ${EXE_URL} -q -O godot_installer.zip
    unzip godot_installer.zip
    rm godot_installer.zip
    chmod +x ./${EXE_FILENAME}
    rm -f godot
    ln -s ${EXE_FILENAME} godot

    echo "Downloading v${VERSION} export templates"
    wget ${TEMPLATE_URL} -q -O export_templates.tpz
    unzip export_templates.tpz
    rm export_templates.tpz
    mv templates editor_data/export_templates/$TEMPLATE_VERSION
fi


