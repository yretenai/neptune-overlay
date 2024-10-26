# Notes<br/>neptune-overlay

### npm.eclass planning

cargo.eclass/nuget.eclass style? (NODE_PACKAGES eclass var?)

```Gentoo-Ebuild
NODE_PACKAGES="
	https://registry.npmjs.org/@electron/asar/-/asar-3.2.13.tgz -> node_modules/@electron/asar
	...
	...
"

# should construct NPM_URIS and NODE_RDEPEND, detect build system?
inherit npm

SRC_URI="
	${NPM_URIS}
"

RDEPEND="
	${NODE_RDEPEND}
"

BDEPEND="
	${NODE_BDEPEND}
"

src_unpack() {
	npm_src_unpack
}

src_configure() {
	npm_src_configure
}

src_compile() {
	npm_src_compile
}

src_install() {
	# global package store is ${EPREFIX}/lib/node
	insinto "/usr/share/node/${P}"
	doins -r dist
	dosym "/usr/share/node/${P}/bin/${PN}" "/usr/bin/${PN}"
	# or something 
}
```

regen lockfile:

```sh
npm i --no-audit --ignore-scripts --package-lock-only
```

get all resolved packages:
```sh
jq .packages\[\].resolved < package-lock.json
```

also get all of the licenses (read every package.json from every package listed in package-lock.json)

bundle all of this into a gdmt-esque program
