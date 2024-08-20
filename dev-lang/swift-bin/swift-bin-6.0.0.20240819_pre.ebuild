# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_SLOT=17

MY_PN="${PN/-bin*/}"
MY_PV="swift-6.0-DEVELOPMENT-SNAPSHOT-2024-08-19-a"

DESCRIPTION="Swift is a general-purpose programming language"
HOMEPAGE="https://github.com/swiftlang/swift
	https://www.swift.org/
	https://developer.apple.com/swift/"
SRC_URI="
	amd64? ( https://download.swift.org/swift-6.0-branch/ubi9/${MY_PV}/${MY_PV}-ubi9.tar.gz )
	arm64? ( https://download.swift.org/swift-6.0-branch/ubi9-aarch64/${MY_PV}/${MY_PV}-ubi9-aarch64.tar.gz )
"

SWIFTDIR="${MY_PV}-ubi9"

if [[ "$ARCH" == "arm64" ]]; then
	SWIFTDIR="${MY_PV}-ubi9-aarch64"
fi

QA_PREBUILT="*"
S="${WORKDIR}/${SWIFTDIR}"
LICENSE="Apache-2.0"
SLOT="0"
IUSE="+plutil"
RESTRICT="test bindist mirror strip"

RDEPEND="
	arm64? ( sys-devel/binutils[gold] )
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

src_prepare() {
	default

	pushd usr/bin
	rm clang* ll* ld* wasm*
	cd ../lib
	rm -rf clang* libLTO.so* liblldb.so*
	rm swift/clang swift_static/clang
	patchelf --remove-rpath swift/linux/libicudataswift.so.69.1
	cd ../include
	rm -rf llvm-c* unicode*
	popd
}

src_install() {
	dobin "usr/bin/docc" \
		"usr/bin/repl_swift" \
		"usr/bin/sourcekit-lsp" \
		"usr/bin/swift-api-checker.py" \
		"usr/bin/swift-build-sdk-interfaces" \
		"usr/bin/swift-build-tool" \
		"usr/bin/swift-demangle" \
		"usr/bin/swift-driver" \
		"usr/bin/swift-format" \
		"usr/bin/swift-frontend" \
		"usr/bin/swift-help" \
		"usr/bin/swift-package" \
		"usr/bin/swift-plugin-server"

	newbin "usr/bin/plutil" "swift-plutil"

	if use plutil; then
		dosym "swift-plutil" "/usr/bin/plutil"
	fi

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
	doexe "usr/libexec/swift/linux/swift-backtrace" \
		"usr/libexec/swift/linux/swift-backtrace-static"

	doheader -r "usr/include/SourceKit"
	doheader -r "usr/include/swift"
	doheader -r "usr/local/include/indexstore"

	insinto /etc/clang
	doins "usr/bin/aarch64-swift-linux-musl-clang.cfg" \
		"usr/bin/x86_64-swift-linux-musl-clang.cfg"
	dosym "aarch64-swift-linux-musl-clang.cfg" "/etc/clang/aarch64-swift-linux-musl-clang++.cfg"
	dosym "x86_64-swift-linux-musl-clang.cfg" "/etc/clang/x86_64-swift-linux-musl-clang++.cfg"

	insinto /usr/lib
	doins -r "usr/lib/swift" \
		"usr/lib/swift_static"

	dolib.so "usr/lib/libIndexStore.so.17" \
		"usr/lib/libsourcekitdInProc.so" \
		"usr/lib/libswiftDemangle.so" \
		"usr/lib/libswiftGenericMetadataBuilder.so"

	local clang_version=${LLVM_SLOT}
	if [[ ! -e "/usr/lib/clang/${LLVM_SLOT}" ]]; then
		clang_version=$(best_version sys-devel/clang:${LLVM_SLOT})
		clang_version=${clang_version#*/*-} # reduce it to ${PV}-${PR}
		clang_version=${clang_version%%[_-]*} # main version without beta/pre/patch/revision
	fi

	dosym "../clang/${clang_version}" "/usr/lib/swift/clang"
	dosym "../clang/${clang_version}" "/usr/lib/swift_static/clang"

	insinto /usr/share
	doins -r "usr/share/icuswift" \
		"usr/share/swift" \
		"usr/share/docc" \
		"usr/share/pm"

	insinto /usr/share/clang
	doins "usr/share/clang/features.json"

	dodoc -r "usr/share/doc/swift"
	doman "usr/share/man/man1/swift.1"

	if [[ "$ARCH" == "amd64" ]]; then
		dosym ld /usr/bin/ld.gold
	fi
}

pkg_postinst() {
	ewarn
	ewarn "'swift repl' is known to error with 'multiple possible languages'"
	ewarn "there unfortunately is no workaround without isolating swift into"
	ewarn "it's own environment folder."
	ewarn "However, this also copies clang and requires a specific python"
	ewarn "version to be installed."
	ewarn
}

pkg_postrm() {
	ewarn ""
	ewarn "Swift has a built-in package manager that has several global stores."
	ewarn "You may want to remove the following directories:"
	ewarn "\t~/.cache/org.swift.swiftpm"
	ewarn "\t~/.swiftpm"
	ewarn "It may contain (significant) debris."
	ewarn ""
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		ewarn "If you are upgrading major Swift versions;"
		ewarn "You MUST erase this directory and rebuild all projects that use swift."
		ewarn ""
	fi
}
