# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_SLOT=17

MY_PN="${PN/-bin*/}"
MY_PV="${PV/-r*/}"

DESCRIPTION="Swift is a general-purpose programming language"
HOMEPAGE="https://github.com/apple/swift
	https://www.swift.org/
	https://developer.apple.com/swift/"
SRC_URI="
	amd64? ( https://download.swift.org/development/ubi9/swift-DEVELOPMENT-SNAPSHOT-2024-06-08-a/swift-DEVELOPMENT-SNAPSHOT-2024-06-08-a-ubi9.tar.gz )
	arm64? ( https://download.swift.org/development/ubi9-aarch64/swift-DEVELOPMENT-SNAPSHOT-2024-06-08-a/swift-DEVELOPMENT-SNAPSHOT-2024-06-08-a-ubi9-aarch64.tar.gz )
"

QA_PREBUILT="*"
S="${WORKDIR}"
LICENSE="Apache-2.0"
SLOT="0"
RESTRICT="test bindist mirror strip"

RDEPEND="
	sys-devel/binutils[gold]
	dev-libs/icu
	sys-libs/timezone-data
	sys-libs/zlib
	dev-vcs/git
	dev-db/sqlite
	net-misc/curl
	dev-libs/libedit
	dev-libs/libxml2
	dev-libs/libbsd
	app-arch/gzip
	sys-devel/clang:${LLVM_SLOT}
	sys-devel/llvm:${LLVM_SLOT}
"

SWIFTDIR="${MY_PN}-DEVELOPMENT-SNAPSHOT-2024-06-08-a-ubi9"

if [[ ARCH == arm64 ]]; then
	SWIFTDIR="${MY_PN}-DEVELOPMENT-SNAPSHOT-2024-06-08-a-ubi9-aarch64"
fi

src_prepare() {
	default

	pushd ${SWIFTDIR}/usr/bin
	rm clang* ll* ld* wasm* *.cfg
	cd ../lib
	rm -rf clang* libLTO.so* liblldb.so*
	rm swift/clang swift_static/clang
	cd ../include
	rm -rf llvm-c* unicode*
	popd
}

src_install() {
	dobin "${WORKDIR}/${SWIFTDIR}/usr/bin/docc" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/repl_swift" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/sourcekit-lsp" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-api-checker.py" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-build-sdk-interfaces" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-build-tool" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-demangle" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-driver" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-format" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-frontend" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-help" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-package" \
		"${WORKDIR}/${SWIFTDIR}/usr/bin/swift-plugin-server"

	newbin "${WORKDIR}/${SWIFTDIR}/usr/bin/plutil" "swift-plutil"

	dosym "swift-frontend" "/usr/bin/swift-api-digester"
	dosym "swift-frontend" "/usr/bin/swift-api-extract"
	dosym "swift-frontend" "/usr/bin/swift-autolink-extract"
	dosym "swift-frontend" "/usr/bin/swift-cache-tool"
	dosym "swift-frontend" "/usr/bin/swift-legacy-driver"
	dosym "swift-frontend" "/usr/bin/swift-symbolgraph-extract"
	dosym "swift-frontend" "/usr/bin/swiftc-legacy-driver"

	dosym "swift-package" "/usr/bin/swift-build"
	dosym "swift-package" "/usr/bin/swift-experimental-sdk"
	dosym "swift-package" "/usr/bin/swift-package-collection"
	dosym "swift-package" "/usr/bin/swift-package-registry"
	dosym "swift-package" "/usr/bin/swift-run"
	dosym "swift-package" "/usr/bin/swift-sdk"
	dosym "swift-package" "/usr/bin/swift-test"

	dosym "swift-driver" "/usr/bin/swift"
	dosym "swift-driver" "/usr/bin/swiftc"

	exeinto /usr/libexec/swift/linux
	doexe "${WORKDIR}/${SWIFTDIR}/usr/libexec/swift/linux/swift-backtrace" \
		"${WORKDIR}/${SWIFTDIR}/usr/libexec/swift/linux/swift-backtrace-static"

	doheader -r "${WORKDIR}/${SWIFTDIR}/usr/include/SourceKit"
	doheader -r "${WORKDIR}/${SWIFTDIR}/usr/include/swift"
	doheader -r "${WORKDIR}/${SWIFTDIR}/usr/local/include/indexstore"

	insinto /usr/lib
	doins -r "${WORKDIR}/${SWIFTDIR}/usr/lib/swift" \
		"${WORKDIR}/${SWIFTDIR}/usr/lib/swift_static"

	dolib.so "${WORKDIR}/${SWIFTDIR}/usr/lib/libIndexStore.so.17" \
		"${WORKDIR}/${SWIFTDIR}/usr/lib/libsourcekitdInProc.so" \
		"${WORKDIR}/${SWIFTDIR}/usr/lib/libswiftDemangle.so"

	if [[ ARCH == amd64 ]]; then
		dosym "../lib64/libIndexStore.so.17" "/usr/lib/libIndexStore.so.17"
		dosym "../lib64/libIndexStore.so.17" "/usr/lib/libIndexStore.so"
		dosym "../lib64/libsourcekitdInProc.so" "/usr/lib/libsourcekitdInProc.so"
		dosym "../lib64/libswiftDemangle.so" "/usr/lib/libswiftDemangle.so"
	fi

	dosym "../clang/${LLVM_SLOT}" "/usr/lib/swift/clang"
	dosym "../clang/${LLVM_SLOT}" "/usr/lib/swift_static/clang"

	insinto /usr/share
	doins -r "${WORKDIR}/${SWIFTDIR}/usr/share/icuswift" \
		"${WORKDIR}/${SWIFTDIR}/usr/share/swift" \
		"${WORKDIR}/${SWIFTDIR}/usr/share/docc" \
		"${WORKDIR}/${SWIFTDIR}/usr/share/pm"

	dodoc -r "${WORKDIR}/${SWIFTDIR}/usr/share/doc/swift"
	doman "${WORKDIR}/${SWIFTDIR}/usr/share/man/man1/swift.1"
}

pkg_postrm() {
	ewarn ""
	ewarn "Swift has a built-in package manager that has several global stores."
	ewarn "You may want to remove the following directories:"
	ewarn "\t~/.cache/org.swift.swiftpm"
	ewarn "\t~/.swiftpm"
	ewarn "It may contain (significant) debris."
	ewarn ""
	ewarn "If you are upgrading Swift versions;"
	ewarn "you MUST erase this directory and rebuild all projects that use swift."
	ewarn ""
}
