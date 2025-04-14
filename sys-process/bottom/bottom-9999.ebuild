# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion cargo git-r3

DESCRIPTION="A graphical process/system monitor with a customizable interface"
HOMEPAGE="https://github.com/ClementTsang/bottom"
EGIT_REPO_URI="https://github.com/ClementTsang/bottom.git"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0 ISC MPL-2.0 Unicode-DFS-2016"
SLOT="0"
IUSE="+battery +gpu +zfs nvidia"

# Rust packages ignore CFLAGS and LDFLAGS so let's silence the QA warnings
QA_FLAGS_IGNORED="usr/bin/btm"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_prepare() {
	# Stripping symbols should be the choice of the user.
	sed -i '/strip = "symbols"/d' Cargo.toml || die "Unable to patch out symbol stripping"

	default
}

src_configure() {
	local myfeatures=(
		$(usev battery)
		$(usev nvidia)
		$(usev gpu)
		$(usev zfs)
	)

	# This will turn on generation of shell completion scripts
	export BTM_GENERATE=true

	# https://github.com/ClementTsang/bottom/blob/bacaca5548c2b23d261ef961ee6584b609529567/Cargo.toml#L63
	# fern and log features are for debugging only, so disable default features
	cargo_src_configure $(usev !debug --no-default-features)
}

src_install() {
	cargo_src_install

	# Find generated shell completion files. btm.bash can be present in multiple dirs if we build
	# additional features, so grab the first match only.
	local build_dir="$(dirname $(find target -name btm.bash -print -quit || die) || die)"

	newbashcomp "${build_dir}"/btm.bash btm
	dofishcomp "${build_dir}"/btm.fish
	dozshcomp "${build_dir}"/_btm

	local DOCS=( README.md )
	einstalldocs
}
