# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Manpages for dotnet"
HOMEPAGE="https://github.com/dotnet/sdk"

SRC_URI="https://github.com/dotnet/sdk/archive/refs/tags/v${PV}.tar.gz"

KEYWORDS="amd64 arm arm64"
LICENSE="MIT"
SLOT="0"

S="${WORKDIR}/sdk-${PV}"

src_install() {
	cd documentation/manpages/sdk
	doman dotnet-add-package.1 \
		dotnet-add-reference.1 \
		dotnet-build-server.1 \
		dotnet-build.1 \
		dotnet-clean.1 \
		dotnet-dev-certs.1 \
		dotnet-environment-variables.7 \
		dotnet-format.1 \
		dotnet-help.1 \
		dotnet-list-package.1 \
		dotnet-list-reference.1 \
		dotnet-migrate.1 \
		dotnet-msbuild.1 \
		dotnet-new-details.1 \
		dotnet-new-install.1 \
		dotnet-new-list.1 \
		dotnet-new-sdk-templates.7 \
		dotnet-new-search.1 \
		dotnet-new-uninstall.1 \
		dotnet-new-update.1 \
		dotnet-new.1 \
		dotnet-nuget-add-source.1 \
		dotnet-nuget-delete.1 \
		dotnet-nuget-disable-source.1 \
		dotnet-nuget-enable-source.1 \
		dotnet-nuget-list-source.1 \
		dotnet-nuget-locals.1 \
		dotnet-nuget-push.1 \
		dotnet-nuget-remove-source.1 \
		dotnet-nuget-sign.1 \
		dotnet-nuget-trust.1 \
		dotnet-nuget-update-source.1 \
		dotnet-nuget-verify.1 \
		dotnet-pack.1 \
		dotnet-publish.1 \
		dotnet-remove-package.1 \
		dotnet-remove-reference.1 \
		dotnet-restore.1 \
		dotnet-run.1 \
		dotnet-sdk-check.1 \
		dotnet-sln.1 \
		dotnet-store.1 \
		dotnet-test.1 \
		dotnet-tool-install.1 \
		dotnet-tool-list.1 \
		dotnet-tool-restore.1 \
		dotnet-tool-run.1 \
		dotnet-tool-search.1 \
		dotnet-tool-uninstall.1 \
		dotnet-tool-update.1 \
		dotnet-vstest.1 \
		dotnet-watch.1 \
		dotnet-workload-install.1 \
		dotnet-workload-list.1 \
		dotnet-workload-repair.1 \
		dotnet-workload-restore.1 \
		dotnet-workload-search.1 \
		dotnet-workload-uninstall.1 \
		dotnet-workload-update.1 \
		dotnet-workload.1 \
		dotnet.1
}
