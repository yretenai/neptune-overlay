# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Hand Tracking Models for Monado"
HOMEPAGE="https://monado.dev"
EGIT_LFS=yes
EGIT_REPO_URI="https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models.git"
LICENSE="Boost-1.0"
SLOT="0"

src_install() {
	insinto /usr/share/monado/hand-tracking-models
	doins -r *.onnx
}
