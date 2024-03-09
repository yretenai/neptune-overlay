# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/-bin*/}"
MY_PV="${PV/-r*/}"

DESCRIPTION="Swift is a general-purpose programming language that's approachable for newcomers and powerful for experts. It is fast, modern, safe, and a joy to write."
HOMEPAGE="https://github.com/apple/swift
	https://www.swift.org/
	https://developer.apple.com/swift/"
SRC_URI="
amd64? ( https://download.swift.org/swift-${MY_PV}-release/ubi9/swift-${MY_PV}-RELEASE/swift-${MY_PV}-RELEASE-ubi9.tar.gz )
arm64? ( https://download.swift.org/swift-${MY_PV}-release/ubi9-aarch64/swift-${MY_PV}-RELEASE/swift-${MY_PV}-RELEASE-ubi9-aarch64.tar.gz )
"

QA_PREBUILT="*"
S="${WORKDIR}"
SLOT="0"

LICENSE="Apache-2.0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test bindist mirror strip"

RDEPEND="
sys-devel/binutils[gold]
sys-devel/llvm:17
dev-libs/icu
sys-libs/timezone-data
sys-libs/zlib
dev-vcs/git
dev-db/sqlite
net-misc/curl
dev-lang/python:2.7
dev-libs/libedit
dev-libs/libxml2
dev-libs/libbsd
app-arch/gzip
"

SWIFTDIR="${MY_PN}-${MY_PV}-RELEASE-ubi9"

src_prepare() {
	default

	pushd ${SWIFTDIR}/usr/bin
	rm clang* ll* ld* wasm*
	cd ../lib
	rm -rf clang* libLTO.so* liblldb.so*
	rm swift/clang swift_static/clang
	cd ../include
	rm -rf llvm-c* unicode*
	popd
}

src_install() {
	dobin ${WORKDIR}/${SWIFTDIR}/usr/bin/docc \
		${WORKDIR}/${SWIFTDIR}/usr/bin/plutil \
		${WORKDIR}/${SWIFTDIR}/usr/bin/repl_swift \
		${WORKDIR}/${SWIFTDIR}/usr/bin/sourcekit-lsp \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-api-checker.py \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-build-sdk-interfaces \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-build-tool \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-demangle \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-driver \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-frontend \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-help \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-package \
		${WORKDIR}/${SWIFTDIR}/usr/bin/swift-plugin-server

	dosym "swift-frontend" "${EPREFIX}/usr/bin/swift"
	dosym "swift-frontend" "${EPREFIX}/usr/bin/swift-api-digester"
	dosym "swift-frontend" "${EPREFIX}/usr/bin/swift-api-extract"
	dosym "swift-frontend" "${EPREFIX}/usr/bin/swift-autolink-extract"
	dosym "swift-frontend" "${EPREFIX}/usr/bin/swift-cache-tool"
	dosym "swift-frontend" "${EPREFIX}/usr/bin/swift-symbolgraph-extract"
	dosym "swift-frontend" "${EPREFIX}/usr/bin/swiftc"

	dosym "swift-package" "${EPREFIX}/usr/bin/swift-build"
	dosym "swift-package" "${EPREFIX}/usr/bin/swift-experimental-sdk"
	dosym "swift-package" "${EPREFIX}/usr/bin/swift-package-collection"
	dosym "swift-package" "${EPREFIX}/usr/bin/swift-package-registry"
	dosym "swift-package" "${EPREFIX}/usr/bin/swift-run"
	dosym "swift-package" "${EPREFIX}/usr/bin/swift-test"

	exeinto /usr/libexec/swift/linux
	doexe ${WORKDIR}/${SWIFTDIR}/usr/libexec/swift/linux/swift-backtrace \
		${WORKDIR}/${SWIFTDIR}/usr/libexec/swift/linux/swift-backtrace-static

	doheader -r ${WORKDIR}/${SWIFTDIR}/usr/include/SourceKit
	doheader -r ${WORKDIR}/${SWIFTDIR}/usr/include/swift

	insinto /usr/lib
	doins -r ${WORKDIR}/${SWIFTDIR}/usr/lib/swift \
		${WORKDIR}/${SWIFTDIR}/usr/lib/swift_static

	dolib.so ${WORKDIR}/${SWIFTDIR}/usr/lib/libIndexStore.so.15git \
		${WORKDIR}/${SWIFTDIR}/usr/lib/libsourcekitdInProc.so \
		${WORKDIR}/${SWIFTDIR}/usr/lib/libswiftDemangle.so

	dosym "../lib64/libIndexStore.so.15git" "${EPREFIX}/usr/lib/libIndexStore.so"
	dosym "../lib64/libsourcekitdInProc.so" "${EPREFIX}/usr/lib/libsourcekitdInProc.so"
	dosym "../lib64/libswiftDemangle.so" "${EPREFIX}/usr/lib/libswiftDemangle.so"
	# maybe do clang 15?
	dosym "${EPREFIX}/usr/lib/clang/17" "${EPREFIX}/usr/lib/swift/clang"
	dosym "${EPREFIX}/usr/lib/clang/17" "${EPREFIX}/usr/lib/swift_static/clang"

	insinto /usr/share
	doins -r ${WORKDIR}/${SWIFTDIR}/usr/share/icuswift \
		${WORKDIR}/${SWIFTDIR}/usr/share/swift \
		${WORKDIR}/${SWIFTDIR}/usr/share/docc \
		${WORKDIR}/${SWIFTDIR}/usr/share/pm

	dodoc -r ${WORKDIR}/${SWIFTDIR}/usr/share/doc/swift
	doman ${WORKDIR}/${SWIFTDIR}/usr/share/man/man1/swift.1
}

pkg_postrm() {
	ewarn ""
	ewarn "Swift has a built-in package manager that has several global stores."
	ewarn "You may want to remove the following directories:"
	ewarn "~/.cache/org.swift.swiftpm"
	ewarn "~/.swiftpm"
	ewarn "It may contain (significant) debris."
	ewarn ""
}
