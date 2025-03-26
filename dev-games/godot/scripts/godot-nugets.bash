#!/bin/bash

DOTNET_ROOT="/opt/neptune-dotnet"
PV="$1"
NEPTUNE_LIST="/var/tmp/portage/dev-games/godot-${PV}/work/nugets.lst"
HERE="${PWD}"
TARGET="${PWD}/nugets.lst"
MONO_ROOT="/var/tmp/portage/dev-games/godot-${PV}/work/godot-${PV}-stable/modules/mono"

ebuild godot-${PV}.ebuild clean unpack

cd "${MONO_ROOT}/editor/Godot.NET.Sdk"
gdmt restore -x "${DOTNET_ROOT}/dotnet" > "${NEPTUNE_LIST}"
cd "${MONO_ROOT}/editor/GodotTools"
gdmt restore -x "${DOTNET_ROOT}/dotnet" >> "${NEPTUNE_LIST}"
cd "${MONO_ROOT}/glue/GodotSharp"
gdmt restore -x "${DOTNET_ROOT}/dotnet" >> "${NEPTUNE_LIST}"

cat "${NEPTUNE_LIST}" | grep \@ | sort | uniq > "${TARGET}"
cd "${HERE}"

ebuild godot-${PV}.ebuild clean
