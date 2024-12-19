#!/bin/bash

DOTNET_ROOT="/opt/neptune-dotnet"
NEPTUNE_LIST="/var/tmp/portage/dev-games/godot-9999/work/nugets.lst"
HERE="${PWD}"
TARGET="${PWD}/nugets.lst"
MONO_ROOT="/var/tmp/portage/dev-games/godot-9999/work/godot-9999/modules/mono"

ebuild godot-9999.ebuild clean unpack

cd "${MONO_ROOT}/editor/Godot.NET.Sdk"
gdmt restore -x "${DOTNET_ROOT}/dotnet" > "${NEPTUNE_LIST}"
cd "${MONO_ROOT}/editor/GodotTools"
gdmt restore -x "${DOTNET_ROOT}/dotnet" >> "${NEPTUNE_LIST}"
cd "${MONO_ROOT}/glue/GodotSharp"
gdmt restore -x "${DOTNET_ROOT}/dotnet" >> "${NEPTUNE_LIST}"

cat "${NEPTUNE_LIST}" | grep \@ | sort | uniq > "${TARGET}"
cd "${HERE}"
ebuild godot-9999.ebuild clean
