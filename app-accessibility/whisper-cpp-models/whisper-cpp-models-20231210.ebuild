# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit check-reqs

DESCRIPTION="OpenAI's Whisper models converted to ggml format"
HOMEPAGE="https://huggingface.co/ggerganov/whisper.cpp"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="bindist mirror"

MODELS=(
	"tiny" "tiny-q5_1" "tiny.en" "tiny.en-q5_1" "tiny.en-q8_0"
	"base" "base-q5_1" "base.en" "base.en-q5_1"
	"small" "small-q5_1" "small.en" "small.en-q5_1"
	"medium" "medium-q5_0" "medium.en" "medium.en-q5_0"
	"large-v1" "large-v2" "large-v2-q5_0" "large-v3" "large-v3-q5_0"
)

REQUIRED_USE="|| ("
for i in ${MODELS[@]}; do
	USE_DEFAULT=""
	if [ "$i" == "base" ]; then
		USE_DEFAULT="+"
	elif [ "$i" == "base-en" ]; then
		USE_DEFAULT="+"
	elif [ "$i" == "large*" ]; then
		USE_DEFAULT="-"
	fi
	IUSE="${IUSE} ${USE_DEFAULT}whisper_models_${i/./-}"
	REQUIRED_USE="${REQUIRED_USE} whisper_models_${i/./-}"
	SRC_URI="${SRC_URI} whisper_models_${i/./-}? ( https://huggingface.co/ggerganov/whisper.cpp/resolve/d15393806e24a74f60827e23e986f0c10750b358/ggml-${i}.bin -> whisper-ggml-${i}.bin )"
done
REQUIRED_USE="${REQUIRED_USE} )"

whisper_check-reqs() {
	req=0

	use whisper_models_base-q5_1 && ((req += 60))
	use whisper_models_base && ((req += 150))
	use whisper_models_base-en-q5_1 && ((req += 60))
	use whisper_models_base-en && ((req += 150))
	use whisper_models_large-v1 && ((req += 3100))
	use whisper_models_large-v2-q5_0 && ((req += 1100))
	use whisper_models_large-v2 && ((req += 3100))
	use whisper_models_large-v3-q5_0 && ((req += 1100))
	use whisper_models_large-v3 && ((req += 3100))
	use whisper_models_medium-q5_0 && ((req += 550))
	use whisper_models_medium && ((req += 1550))
	use whisper_models_medium-en-q5_0 && ((req += 550))
	use whisper_models_medium-en && ((req += 1550))
	use whisper_models_small-q5_1 && ((req += 200))
	use whisper_models_small && ((req += 500))
	use whisper_models_small-en-q5_1 && ((req += 200))
	use whisper_models_small-en && ((req += 500))
	use whisper_models_tiny-q5_1 && ((req += 50))
	use whisper_models_tiny && ((req += 80))
	use whisper_models_tiny-en-q5_1 && ((req += 50))
	use whisper_models_tiny-en-q8_0 && ((req += 50))
	use whisper_models_tiny-en && ((req += 80))

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

src_unpack() { :; }

src_install() {
	insinto /usr/share/whisper/ggml-models
	for i in ${MODELS[@]}; do
		use whisper_models_${i/./-} && newins "${DISTDIR}/whisper-ggml-${i}.bin" "${i}.bin"
	done
}

pkg_postinst() {
	elog "The models have been installed in"
	elog "   ${EROOT}/usr/share/whisper/ggml-models"
}
