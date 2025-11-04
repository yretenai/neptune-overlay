# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-4 )
PYTHON_COMPAT=( python3_{8..14} python3_{13..14}t )

inherit cmake optfeature lua-single python-any-r1 xdg-utils

DESCRIPTION="Chat client for https://twitch.tv, 7tv soft fork"
HOMEPAGE="https://github.com/SevenTV/chatterino7"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SevenTV/chatterino7.git"
else
	SANITIZERS_CMAKE_COMMIT=0573e2ea8651b9bb3083f193c41eb086497cc80a
	CERTIFY_COMMIT=a448a3915ddac716ce76e4b8cbf0e7f4153ed1e2
	CRASH_HANDLER_COMMIT=c8cf62b64906f794ac84cb0c22ceb401f4ea1e8d
	LIBCOMMUNI_COMMIT=2979eb96262756047a8dca47f2e509168138c0d0
	WEBSOCKETPP_COMMIT=f1736a8e72b910810ff6869fe20f647a62f3bc35
	KIMAGEFORMATS_COMMIT=7420f47c17454de49dd617e35626704d09dbc757
	LUA_COMMIT=1ab3208a1fceb12fca8f24ba57d6e13c5bff15e3
	SERIALIZE_COMMIT=17946d65a41a72b447da37df6e314cded9650c32
	SETTINGS_COMMIT=9b5c05ee2129e9eaa641d08a49096682105c2588
	SIGNALS_COMMIT=d06770649a7e83db780865d09c313a876bf0f4eb
	SOL2_COMMIT=2b0d2fe8ba0074e16b499940c4f3126b9c7d3471

	SRC_URI="
		https://github.com/SevenTV/chatterino7/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/arsenm/sanitizers-cmake/archive/${SANITIZERS_CMAKE_COMMIT}.tar.gz -> sanitizers-cmake-${SANITIZERS_CMAKE_COMMIT}.tar.gz
		https://github.com/Chatterino/certify/archive/${CERTIFY_COMMIT}.tar.gz -> ${PN}-certify-${CERTIFY_COMMIT}.tar.gz
		https://github.com/Chatterino/crash-handler/archive/${CRASH_HANDLER_COMMIT}.tar.gz -> ${PN}-crash-handler-${CRASH_HANDLER_COMMIT}.tar.gz
		https://github.com/Chatterino/libcommuni/archive/${LIBCOMMUNI_COMMIT}.tar.gz -> ${PN}-libcommuni-${LIBCOMMUNI_COMMIT}.tar.gz
		https://github.com/Chatterino/websocketpp/archive/${WEBSOCKETPP_COMMIT}.tar.gz -> ${PN}-websocketpp-${WEBSOCKETPP_COMMIT}.tar.gz
		https://github.com/pajlada/serialize/archive/${SERIALIZE_COMMIT}.tar.gz -> ${PN}-serialize-${SERIALIZE_COMMIT}.tar.gz
		https://github.com/pajlada/settings/archive/${SETTINGS_COMMIT}.tar.gz -> ${PN}-settings-${SETTINGS_COMMIT}.tar.gz
		https://github.com/pajlada/signals/archive/${SIGNALS_COMMIT}.tar.gz -> ${PN}-signals-${SIGNALS_COMMIT}.tar.gz
		https://github.com/KDE/kimageformats/archive/${KIMAGEFORMATS_COMMIT}.tar.gz -> kimageformats-${KIMAGEFORMATS_COMMIT}.tar.gz
		https://github.com/lua/lua/archive/${LUA_COMMIT}.tar.gz -> lua-${LUA_COMMIT}.tar.gz
		https://github.com/ThePhD/sol2/archive/${SOL2_COMMIT}.tar.gz -> sol2-${SOL2_COMMIT}.tar.gz
	"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="debug"

RDEPEND="
	${LUA_DEPS}
	>media-libs/libavif-1.0.0-r0:=
	dev-libs/openssl:=
	dev-libs/qtkeychain:=
	dev-qt/qtbase:6[concurrent,dbus,gui,network,widgets]
	dev-qt/qt5compat:6[icu]
	dev-qt/qtmultimedia:6
	dev-qt/qtimageformats:6
	dev-qt/qtsvg:6
"
DEPEND="
	${RDEPEND}
	dev-libs/boost
"
BDEPEND="
	${PYTHON_DEPS}
	dev-qt/qttools:6[linguist]
	dev-cpp/magic_enum
	dev-libs/rapidjson
	dev-libs/miniaudio
	dev-libs/date
	dev-cpp/expected-lite
	$(lua_gen_cond_dep 'dev-cpp/sol2[${LUA_USEDEP}]')
"

PATCHES=(
	"${FILESDIR}/${PN}-7.5.3-miniaudio.patch"
	"${FILESDIR}/${PN}-7.5.4-name.patch"
)

src_unpack() {
	default

	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	else
		rmdir "${S}/cmake/sanitizers-cmake"; mv "${WORKDIR}/sanitizers-cmake-${SANITIZERS_CMAKE_COMMIT}" "${S}/cmake/sanitizers-cmake" || die "Cannot move sanitizers-cmake"
		rmdir "${S}/lib/certify"; mv "${WORKDIR}/certify-${CERTIFY_COMMIT}" "${S}/lib/certify" || die "Cannot move certify"
		rmdir "${S}/tools/crash-handler"; mv "${WORKDIR}/crash-handler-${CRASH_HANDLER_COMMIT}" "${S}/tools/crash-handler" || die "Cannot move crash-handler"
		rmdir "${S}/lib/libcommuni"; mv "${WORKDIR}/libcommuni-${LIBCOMMUNI_COMMIT}" "${S}/lib/libcommuni" || die "Cannot move libcommuni"
		rmdir "${S}/lib/websocketpp"; mv "${WORKDIR}/websocketpp-${WEBSOCKETPP_COMMIT}" "${S}/lib/websocketpp" || die "Cannot move websocketpp"
		rmdir "${S}/lib/serialize"; mv "${WORKDIR}/serialize-${SERIALIZE_COMMIT}" "${S}/lib/serialize" || die "Cannot move serialize"
		rmdir "${S}/lib/settings"; mv "${WORKDIR}/settings-${SETTINGS_COMMIT}" "${S}/lib/settings" || die "Cannot move settings"
		rmdir "${S}/lib/signals"; mv "${WORKDIR}/signals-${SIGNALS_COMMIT}" "${S}/lib/signals" || die "Cannot move signals"
		rmdir "${S}/lib/kimageformats"; mv "${WORKDIR}/kimageformats-${KIMAGEFORMATS_COMMIT}" "${S}/lib/kimageformats" || die "Cannot move kimageformats"
		rmdir "${S}/lib/lua/src"; mv "${WORKDIR}/lua-${LUA_COMMIT}" "${S}/lib/lua/src" || die "Cannot move lua"
		rmdir "${S}/lib/sol2"; mv "${WORKDIR}/sol2-${SOL2_COMMIT}" "${S}/lib/sol2" || die "Cannot move sol2"
	fi
}

src_configure() {
	local mycmakeargs=(
		-DUSE_SYSTEM_QTKEYCHAIN=ON
		-DBUILD_WITH_QT6=ON
		-DBUILD_SHARED_LIBS=OFF
	)

	# Chatterino uses NDEBUG extensively to disable debug code paths.
	if ! use debug; then
		mycmakeargs+=(
			-DCMAKE_C_FLAGS="${CFLAGS} -DNDEBUG"
			-DCMAKE_CXX_FLAGS="${CXXFLAGS} -DNDEBUG"
		)
	fi

	CMAKE_BUILD_TYPE=$(usex debug Debug Release) cmake_src_configure
}

pkg_postinst() {
	xdg_icon_cache_update
	optfeature "for opening streams in a local video player" net-misc/streamlink
}

pkg_postrm() {
	xdg_icon_cache_update
}
