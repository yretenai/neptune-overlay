# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CARGO_OPTIONAL=1
inherit cargo cmake flag-o-matic toolchain-funcs

DESCRIPTION="Lossless Scaling Frame Generation on Linux via DXVK/Vulkan"
HOMEPAGE="https://github.com/PancakeTAS/lsfg-vk"
LICENSE="MIT"
LICENSE+="
	gui? ( Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD ISC MIT Unicode-3.0 )
"
SLOT="0"
IUSE="+gui"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/PancakeTAS/lsfg-vk"
	EGIT_SUBMODULES=(
		thirdparty/dxbc
		thirdparty/pe-parse
	)
else
	DXBC_COMMIT=
	PEPARSE_COMMIT=
	SRC_URI="
		https://github.com/PancakeTAS/lsfg-vk/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/PancakeTAS/dxbc/archive/${DXBC_COMMIT}.tar.gz -> dxbc-${DXBC_COMMIT}.tar.gz
		https://github.com/trailofbits/pe-parse/archive/${PEPARSE_COMMIT}.tar.gz -> preparse-${DXBC_COMMIT}.tar.gz
		gui? (
			${CARGO_CRATE_URIS}
		)
	"
	KEYWORDS="~amd64"
fi

VULKAN_PV="1.4.313"

BDEPEND="
	>=dev-util/spirv-headers-${VULKAN_PV}
	>=dev-util/vulkan-headers-${VULKAN_PV}
	gui? ( ${RUST_DEPEND} )
"
DEPEND="
	dev-cpp/toml11
	>=dev-util/glslang-${VULKAN_PV}
	>=dev-util/volk-${VULKAN_PV}
	>=media-libs/vulkan-loader-${VULKAN_PV}
	gui? (
		dev-libs/glib:2
		gui-libs/gtk:4
		gui-libs/libadwaita
	)
	|| (
		media-libs/glfw
		media-libs/libsdl2
		media-libs/libsdl3
	)
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-0.9.0-system.patch"
)

src_unpack() {
	if [[ ${PV} != 9999 ]]; then
		default
	else
		git-r3_src_unpack
	fi

	if use gui; then
		oldS="${S}"
		S="${S}/ui"
		if [[ ${PV} != 9999 ]]; then
			cargo_src_unpack
		else
			cargo_live_src_unpack
		fi
		S="${oldS}"
	fi
}

src_prepare() {
	if [[ ${PV} != 9999 ]]; then
		rmdir thirdparty/dxbc || die
		mv "${WORKDIR}/dxbc-${DXBC_COMMIT}" thirdparty/dxbc || die
		rmdir thirdparty/pe-parse || die
		mv "${WORKDIR}/pe-parse-${PEPARSE_COMMIT}" thirdparty/pe-parse || die
	fi

	eapply_user
	cmake_src_prepare
}

src_configure() {
	tc-is-gcc && filter-lto # LTO with gcc causes segfaults at runtime
	cmake_src_configure
	if use gui; then
		cd ui
		cargo_src_configure
	fi
}

src_compile() {
	cmake_src_compile
	if use gui; then
		cd ui
		cargo_src_compile
	fi
}

src_install() {
	insinto "/usr/share/vulkan/implicit_layer.d/"
	doins "${S}/VkLayer_LS_frame_generation.json"
	dolib.so "${BUILD_DIR}/liblsfg-vk.so"
	if use gui; then
		cd ui
		cargo_src_install
	fi
}
