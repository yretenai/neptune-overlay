# TODO<br/>neptune-overlay

Things left to do for neptune-overlay:

- [ ] compile dev-lang/swift
- [ ] electron.eclass -> `electron{SUFFIX}-{PV} path/to/resources/app.asar` works. we only need to install each electron version once. (install to /usr/lib/electron/{slot}/, apps to /usr/lib/{PN}?)
- [ ] package dev-libs/electorn-builder
- [ ] package www-misc(? app-misc?)/electron-bin
- [ ] compile www-misc(? app-misc?)/electron
- [ ] make virtual/electron (when electron and electron-bin)
- [ ] virtual/swift (when dev-lang/swift)
- [ ] migrate neptune-scripts (zsh) to neptune-util (C#)
- [ ] neptune-util: neptune-check update checker for git based ebuilds
