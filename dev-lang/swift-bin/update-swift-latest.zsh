#!/bin/zsh
SWIFTBIN_ROOT='/var/db/repos/neptune/dev-lang/swift-bin'

DEV_6_VERSION=$(env python3 get-filename.py swift-6_0-branch)
DEV_VERSION=$(env python3 get-filename.py development)
VERSION_6_BUMP=$(env python3 strip-filename.py "${DEV_6_VERSION}")
VERSION_BUMP=$(env python3 strip-filename.py "${DEV_VERSION}")
echo $DEV_6_VERSION $DEV_VERSION

find "${SWIFTBIN_ROOT}" -iname "*_pre.ebuild" -print -delete
find "${SWIFTBIN_ROOT}" -iname "swift-bin-9999.*.ebuild" -print -delete

cp swift-bin-pre.ebuild ${SWIFTBIN_ROOT}/swift-bin-6.0.0.${VERSION_6_BUMP}_pre.ebuild
sed -i "/__SWIFT_VERSION__/s//${DEV_6_VERSION}/g" "${SWIFTBIN_ROOT}/swift-bin-6.0.0.${VERSION_6_BUMP}_pre.ebuild"
sed -i "/__BRANCH__/s//swift-6.0-branch/g" "${SWIFTBIN_ROOT}/swift-bin-6.0.0.${VERSION_6_BUMP}_pre.ebuild"

cp swift-bin-pre.ebuild ${SWIFTBIN_ROOT}/swift-bin-9999.${VERSION_BUMP}.ebuild
sed -i "/__SWIFT_VERSION__/s//${DEV_VERSION}/g" "${SWIFTBIN_ROOT}/swift-bin-9999.${VERSION_BUMP}.ebuild"
sed -i "/__BRANCH__/s//development/g" "${SWIFTBIN_ROOT}/swift-bin-9999.${VERSION_BUMP}.ebuild"

ebuild "${SWIFTBIN_ROOT}/swift-bin-9999.${VERSION_BUMP}.ebuild" manifest
