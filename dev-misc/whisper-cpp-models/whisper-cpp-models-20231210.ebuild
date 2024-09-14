# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit check-reqs

DESCRIPTION="OpenAI's Whisper models converted to ggml format"
HOMEPAGE="https://huggingface.co/ggerganov/whisper.cpp"
HUGGINGFACE_REV="d15393806e24a74f60827e23e986f0c10750b358"

SRC_URI="
	https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-base.en.bin -> whisper-ggml-base.en.bin
	whisper-models-tiny? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-tiny.bin -> whisper-ggml-tiny.bin )
	whisper-models-tiny-q5-1? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-tiny-q5_1.bin -> whisper-ggml-tiny-q5-1.bin )
	whisper-models-tiny-en? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-tiny.en.bin -> whisper-ggml-tiny.en.bin )
	whisper-models-tiny-en-q5-1? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-tiny.en-q5_1.bin -> whisper-ggml-tiny.en-q5-1.bin )
	whisper-models-tiny-en-q8-0? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-tiny.en-q8_0.bin -> whisper-ggml-tiny.en-q8-0.bin )
	whisper-models-base? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-base.bin -> whisper-ggml-base.bin )
	whisper-models-base-q5-1? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-base-q5_1.bin -> whisper-ggml-base-q5-1.bin )
	whisper-models-base-en-q5-1? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-base.en-q5_1.bin -> whisper-ggml-base.en-q5-1.bin )
	whisper-models-small? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-small.bin -> whisper-ggml-small.bin )
	whisper-models-small-q5-1? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-small-q5_1.bin -> whisper-ggml-small-q5-1.bin )
	whisper-models-small-en? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-small.en.bin -> whisper-ggml-small.en.bin )
	whisper-models-small-en-q5-1? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-small.en-q5_1.bin -> whisper-ggml-small.en-q5-1.bin )
	whisper-models-medium? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-medium.bin -> whisper-ggml-medium.bin )
	whisper-models-medium-q5-0? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-medium-q5_0.bin -> whisper-ggml-medium-q5-0.bin )
	whisper-models-medium-en? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-medium.en.bin -> whisper-ggml-medium.en.bin )
	whisper-models-medium-en-q5-0? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-medium.en-q5_0.bin -> whisper-ggml-medium.en-q5-0.bin )
	whisper-models-large-v1? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-large-v1.bin -> whisper-ggml-large-v1.bin )
	whisper-models-large-v2? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-large-v2.bin -> whisper-ggml-large-v2.bin )
	whisper-models-large-v2-q5-0? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-large-v2-q5_0.bin -> whisper-ggml-large-v2-q5-0.bin )
	whisper-models-large-v3? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-large-v3.bin -> whisper-ggml-large-v3.bin )
	whisper-models-large-v3-q5-0? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/${HUGGINGFACE_REV}/ggml-large-v3-q5_0.bin -> whisper-ggml-large-v3-q5-0.bin )
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="
	whisper-models-tiny whisper-models-tiny-q5-1 whisper-models-tiny-en whisper-models-tiny-en-q5-1 whisper-models-tiny-en-q8-0
	whisper-models-base whisper-models-base-q5-1 whisper-models-base-en-q5-1
	whisper-models-small whisper-models-small-q5-1 whisper-models-small-en whisper-models-small-en-q5-1
	whisper-models-medium whisper-models-medium-q5-0 whisper-models-medium-en whisper-models-medium-en-q5-0
	whisper-models-large-v1 whisper-models-large-v2 whisper-models-large-v2-q5-0 whisper-models-large-v3 whisper-models-large-v3-q5-0
"

RESTRICT="bindist mirror"

whisper_check-reqs() {
	req=150

	use whisper-models-base-q5-1 && ((req += 60))
	use whisper-models-base && ((req += 150))
	use whisper-models-base-en-q5-1 && ((req += 60))
	use whisper-models-large-v1 && ((req += 3100))
	use whisper-models-large-v2-q5-0 && ((req += 1100))
	use whisper-models-large-v2 && ((req += 3100))
	use whisper-models-large-v3-q5-0 && ((req += 1100))
	use whisper-models-large-v3 && ((req += 3100))
	use whisper-models-medium-q5-0 && ((req += 550))
	use whisper-models-medium && ((req += 1550))
	use whisper-models-medium-en-q5-0 && ((req += 550))
	use whisper-models-medium-en && ((req += 1550))
	use whisper-models-small-q5-1 && ((req += 200))
	use whisper-models-small && ((req += 500))
	use whisper-models-small-en-q5-1 && ((req += 200))
	use whisper-models-small-en && ((req += 500))
	use whisper-models-tiny-q5-1 && ((req += 50))
	use whisper-models-tiny && ((req += 80))
	use whisper-models-tiny-en-q5-1 && ((req += 50))
	use whisper-models-tiny-en-q8-0 && ((req += 50))
	use whisper-models-tiny-en && ((req += 80))

	if [ $req -ne 0 ]; then
		CHECKREQS_DISK_BUILD="${req}M"
		CHECKREQS_DISK_USR="${req}M"
		"$@"
	fi
}

pkg_pretend() {
	whisper_check-reqs check-reqs_pkg_pretend
}

pkg_setup() {
	whisper_check-reqs check-reqs_pkg_setup
}

src_unpack() {
	return
}

src_install() {
	insinto /usr/share/whisper/ggml-models

	newins "${DISTDIR}/whisper-ggml-base.en.bin" base.en.bin
	use whisper-models-tiny && newins "${DISTDIR}/whisper-ggml-tiny.bin" tiny.bin
	use whisper-models-tiny-q5-1 && newins "${DISTDIR}/whisper-ggml-tiny-q5-1.bin" tiny-q5-1.bin
	use whisper-models-tiny-en && newins "${DISTDIR}/whisper-ggml-tiny.en.bin" tiny.en.bin
	use whisper-models-tiny-en-q5-1 && newins "${DISTDIR}/whisper-ggml-tiny.en-q5-1.bin" tiny.en-q5-1.bin
	use whisper-models-tiny-en-q8-0 && newins "${DISTDIR}/whisper-ggml-tiny.en-q8-0.bin" tiny.en-q8-0.bin
	use whisper-models-base && newins "${DISTDIR}/whisper-ggml-base.bin" base.bin
	use whisper-models-base-q5-1 && newins "${DISTDIR}/whisper-ggml-base-q5-1.bin" base-q5-1.bin
	use whisper-models-base-en-q5-1 && newins "${DISTDIR}/whisper-ggml-base.en-q5-1.bin" base.en-q5-1.bin
	use whisper-models-small && newins "${DISTDIR}/whisper-ggml-small.bin" small.bin
	use whisper-models-small-q5-1 && newins "${DISTDIR}/whisper-ggml-small-q5-1.bin" small-q5-1.bin
	use whisper-models-small-en && newins "${DISTDIR}/whisper-ggml-small.en.bin" small.en.bin
	use whisper-models-small-en-q5-1 && newins "${DISTDIR}/whisper-ggml-small.en-q5-1.bin" small.en-q5-1.bin
	use whisper-models-medium && newins "${DISTDIR}/whisper-ggml-medium.bin" medium.bin
	use whisper-models-medium-q5-0 && newins "${DISTDIR}/whisper-ggml-medium-q5-0.bin" medium-q5-0.bin
	use whisper-models-medium-en && newins "${DISTDIR}/whisper-ggml-medium.en.bin" medium.en.bin
	use whisper-models-medium-en-q5-0 && newins "${DISTDIR}/whisper-ggml-medium.en-q5-0.bin" medium.en-q5-0.bin
	use whisper-models-large-v1 && newins "${DISTDIR}/whisper-ggml-large-v1.bin" large-v1.bin
	use whisper-models-large-v2 && newins "${DISTDIR}/whisper-ggml-large-v2.bin" large-v2.bin
	use whisper-models-large-v2-q5-0 && newins "${DISTDIR}/whisper-ggml-large-v2-q5-0.bin" large-v2-q5-0.bin
	use whisper-models-large-v3 && newins "${DISTDIR}/whisper-ggml-large-v3.bin" large-v3.bin
	use whisper-models-large-v3-q5-0 && newins "${DISTDIR}/whisper-ggml-large-v3-q5-0.bin" large-v3-q5-0.bin
}

pkg_postinst() {
	elog "The models have been installed in"
	elog "   ${EPREFIX}/usr/share/whisper/ggml-models"
}
