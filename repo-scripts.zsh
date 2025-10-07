#!/usr/bin/env zsh

export NEPTUNE_REPO_ROOT="~/overlay/neptune"
export NEPTUNE_UTILS_ROOT="~/overlay/neptune-utils"
export NEPTUNE_SCRIPTS_ROOT="~/overlay/neptune-scripts"
export NEPTUNE_REPO_PKGDEV=y

function neptune-discord {
	pushd "${NEPTUNE_SCRIPTS_ROOT}/net-im/discord"
	./discord-update-ebuilds.sh
	popd
}

function neptune-dotnet {
	pushd "${NEPTUNE_SCRIPTS_ROOT}/neptune-dotnet"
	./update-dotnet-versions.sh
	popd
}

function neptune-maint {
	pushd "${NEPTUNE_UTILS_ROOT}/Neptunian/bin/Release/net9.0"
	./neptunian check --repo-root "${NEPTUNE_REPO_ROOT}"
	popd
}

function neptune-electron {
	pushd "${NEPTUNE_REPO_ROOT}"
	mv "dev-electron/electron-bin/electron-bin-$1.ebuild" \
	   "dev-electron/electron-bin/electron-bin-$2.ebuild"
	mv "virtual/electron/electron-$1.ebuild" \
	   "virtual/electron/electron-$2.ebuild"
	git add .
	pkgdev commit -m "electron: add $2, drop $1"
	popd
}

function neptune-electron-wvcus {
	pushd "${NEPTUNE_REPO_ROOT}"
	mv "dev-electron/electron-wvcus-bin/electron-wvcus-bin-$1.ebuild" \
	   "dev-electron/electron-wvcus-bin/electron-wvcus-bin-$2.ebuild"
	mv "virtual/electron-widevine/electron-widevine-$1.ebuild" \
	   "virtual/electron-widevine/electron-widevine-$2.ebuild"
	git add .
	pkgdev commit -m "electron-widevine: add $2, drop $1"
	popd
}

function neptune-vulkan {
	pushd "${NEPTUNE_REPO_ROOT}"
	cp dev-util/volk/volk-9999.ebuild \
		dev-util/volk/volk-$1.ebuild
	cp dev-util/spirv-headers/spirv-headers-9999.ebuild \
		dev-util/spirv-headers/spirv-headers-$1.ebuild
	cp dev-util/vulkan-headers/vulkan-headers-9999.ebuild \
		dev-util/vulkan-headers/vulkan-headers-$1.ebuild
	cp dev-util/glslang/glslang-9999.ebuild \
		dev-util/glslang/glslang-$1.ebuild
	cp dev-util/vulkan-tools/vulkan-tools-9999.ebuild \
		dev-util/vulkan-tools/vulkan-tools-$1.ebuild
	cp dev-util/vulkan-utility-libraries/vulkan-utility-libraries-9999.ebuild \
		dev-util/vulkan-utility-libraries/vulkan-utility-libraries-$1.ebuild
	cp dev-util/spirv-tools/spirv-tools-9999.ebuild \
		dev-util/spirv-tools/spirv-tools-$1.ebuild
	cp media-libs/vulkan-layers/vulkan-layers-9999.ebuild \
		media-libs/vulkan-layers/vulkan-layers-$1.ebuild
	cp media-libs/vulkan-loader/vulkan-loader-9999.ebuild \
		media-libs/vulkan-loader/vulkan-loader-$1.ebuild
	cp dev-debug/gfxreconstruct/gfxreconstruct-9999.ebuild \
		dev-debug/gfxreconstruct/gfxreconstruct-$1.ebuild
	git add .
	pkgdev commit -m "vulkan: bump $1"
	popd
}
