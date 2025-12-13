# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Frame profiler"
HOMEPAGE="https://github.com/wolfpld/tracy"

LICENSE="BSD"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/wolfpld/tracy.git"
else
	SRC_URI="https://github.com/wolfpld/tracy/archive/refs/tags/v${PV}.tar.gz -> ${PN}-v${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

DEPEND="
	sys-libs/libunwind
"

RDEPEND="
	${DEPEND}
"

RESTRICT="mirror"

PATCHES="
	${FILESDIR}/${PN}-0.13.0-missing-includes.patch
"

src_configure() {
	local emesonargs=(
		-Dlibunwind_backtrace=true
		-Don_demand=true
		-Dfibers=true
		-Dno_crash_handler=true
	)

	meson_src_configure
}
