# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	aho-corasick@1.1.3
	allocator-api2@0.2.21
	android_system_properties@0.1.5
	arrayvec@0.7.6
	ash@0.38.0+1.3.281
	autocfg@1.5.0
	bindgen@0.72.0
	bit-set@0.8.0
	bit-vec@0.8.0
	bitflags@1.3.2
	bitflags@2.9.1
	block@0.1.6
	bumpalo@3.19.0
	bytemuck@1.23.1
	bytemuck_derive@1.9.3
	cexpr@0.6.0
	cfg-if@1.0.1
	cfg_aliases@0.2.1
	clang-sys@1.8.1
	codespan-reporting@0.12.0
	core-foundation-sys@0.8.7
	core-foundation@0.9.4
	core-graphics-types@0.1.3
	crunchy@0.2.4
	document-features@0.2.11
	either@1.15.0
	equivalent@1.0.2
	fixedbitset@0.5.7
	foldhash@0.1.5
	foreign-types-macros@0.2.3
	foreign-types-shared@0.3.1
	foreign-types@0.5.0
	gl_generator@0.14.0
	glob@0.3.2
	glow@0.16.0
	glutin_wgl_sys@0.6.1
	gpu-alloc-types@0.3.0
	gpu-alloc@0.6.0
	gpu-allocator@0.27.0
	gpu-descriptor-types@0.2.0
	gpu-descriptor@0.3.2
	half@2.6.0
	hashbrown@0.15.4
	heck@0.5.0
	hexf-parse@0.2.1
	indexmap@2.10.0
	itertools@0.13.0
	jni-sys@0.3.0
	js-sys@0.3.77
	khronos-egl@6.0.0
	khronos_api@3.1.0
	libc@0.2.174
	libloading@0.8.8
	libm@0.2.15
	litrs@0.4.1
	lock_api@0.4.13
	log@0.4.27
	malloc_buf@0.0.6
	memchr@2.7.5
	metal@0.31.0
	minimal-lexical@0.2.1
	ndk-sys@0.5.0+25.2.9519653
	nom@7.1.3
	num-traits@0.2.19
	objc@0.2.7
	once_cell@1.21.3
	ordered-float@4.6.0
	parking_lot@0.12.4
	parking_lot_core@0.9.11
	paste@1.0.15
	petgraph@0.8.2
	pkg-config@0.3.32
	pp-rs@0.2.1
	presser@0.3.1
	prettyplease@0.2.35
	proc-macro2@1.0.95
	profiling@1.0.17
	quote@1.0.40
	range-alloc@0.1.4
	raw-window-handle@0.6.2
	redox_syscall@0.5.13
	regex-automata@0.4.9
	regex-syntax@0.8.5
	regex@1.11.1
	renderdoc-sys@1.1.0
	rustc-hash@1.1.0
	rustc-hash@2.1.1
	rustversion@1.0.21
	scopeguard@1.2.0
	serde@1.0.219
	serde_derive@1.0.219
	shlex@1.3.0
	slotmap@1.0.7
	smallvec@1.15.1
	spirv@0.3.0+sdk-1.3.268.0
	strum@0.26.3
	strum_macros@0.26.4
	syn@2.0.104
	termcolor@1.4.1
	thiserror-impl@1.0.69
	thiserror-impl@2.0.12
	thiserror@1.0.69
	thiserror@2.0.12
	unicode-ident@1.0.18
	unicode-width@0.2.1
	unicode-xid@0.2.6
	version_check@0.9.5
	wasm-bindgen-backend@0.2.100
	wasm-bindgen-macro-support@0.2.100
	wasm-bindgen-macro@0.2.100
	wasm-bindgen-shared@0.2.100
	wasm-bindgen@0.2.100
	web-sys@0.3.77
	winapi-util@0.1.9
	windows-core@0.58.0
	windows-implement@0.58.0
	windows-interface@0.58.0
	windows-result@0.2.0
	windows-strings@0.1.0
	windows-sys@0.59.0
	windows-targets@0.52.6
	windows-targets@0.53.2
	windows@0.58.0
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.0
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.0
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.0
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.0
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.0
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.0
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.0
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.0
	xml-rs@0.8.26
"

WGPU_VERSION="$(ver_cut 0-3)"

declare -A GIT_CRATES=(
	[naga]="https://github.com/gfx-rs/wgpu;v${WGPU_VERSION};wgpu-${WGPU_VERSION}/naga"
	[wgpu-core-deps-apple]="https://github.com/gfx-rs/wgpu;v${WGPU_VERSION};wgpu-${WGPU_VERSION}/wgpu-core/platform-deps/apple"
	[wgpu-core-deps-emscripten]="https://github.com/gfx-rs/wgpu;v${WGPU_VERSION};wgpu-${WGPU_VERSION}/wgpu-core/platform-deps/emscripten"
	[wgpu-core-deps-windows-linux-android]="https://github.com/gfx-rs/wgpu;v${WGPU_VERSION};wgpu-${WGPU_VERSION}/wgpu-core/platform-deps/windows-linux-android"
	[wgpu-core]="https://github.com/gfx-rs/wgpu;v${WGPU_VERSION};wgpu-${WGPU_VERSION}/wgpu-core"
	[wgpu-hal]="https://github.com/gfx-rs/wgpu;v${WGPU_VERSION};wgpu-${WGPU_VERSION}/wgpu-hal"
	[wgpu-types]="https://github.com/gfx-rs/wgpu;v${WGPU_VERSION};wgpu-${WGPU_VERSION}/wgpu-types"
)

inherit cargo

DESCRIPTION="Native WebGPU implementation based on wgpu-core"
HOMEPAGE="https://github.com/gfx-rs/wgpu-native"
SRC_URI="
	https://github.com/gfx-rs/wgpu-native/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

BDEPEND="
	~dev-util/webgpu-headers-20241112:=
	${RUST_DEPEND}
"

LICENSE="|| ( Apache-2.0 MIT )"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD CC0-1.0 ISC MIT Unicode-DFS-2016 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_prepare() {
	default

	sed -e "s|version = \"0.0.0\"|version = \"$(ver_cut 0-3)\"|" -i Cargo.toml

	rmdir ffi/webgpu-headers
	ln -s "${EPREFIX}/usr/include/webgpu" ffi/webgpu-headers
}

src_install() {
	dolib.a "$(cargo_target_dir)/libwgpu_native.a"
	dolib.so "$(cargo_target_dir)/libwgpu_native.so"
	mkdir webgpu
	mv ffi/wgpu.h webgpu
	doheader -r webgpu
}
