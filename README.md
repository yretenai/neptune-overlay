# neptune-overlay

Please [create an issue](https://github.com/yretenai/neptune-overlay/issues/new) for any bugs.

Primarily to package applications that I haven't seen on many overlays, or was incomplete/outdated.

## Installation

```shell
emerge app-eselect/eselect-repository
eselect repository add neptune-overlay git https://github.com/yretenai/neptune-overlay.git
emerge --sync
```

## Only unmask packages you use from this repository

Based on [Masking installed but unsafe ebuild repositories](https://wiki.gentoo.org/wiki/Ebuild_repository#Masking_installed_but_unsafe_ebuild_repositories).

In `/etc/portage/package.mask/neptune`, block all packages from this repository by default:

```plain
*/*::neptune
```

In `/etc/portage/package.unmask/neptune`, allow packages from this repository:

```plain
net-im/revolt-desktop::neptune
```

### neptune-dotnet

neptune-dotnet is a special category for my testing on multi-target dotnet deployments on Gentoo for using the dotnet sdk.

To install multiple sdks you must emerge them by slot i.e. `emerge "neptune-dotnet/dotnet-sdk:8.0" "neptune-dotnet/dotnet-sdk:7.0" "neptune-dotnet/dotnet-sdk:6.0"`

You must then set the DOTNET_HOME environment variable to `/opt/neptune-dotnet`.

At the end of `~/.profile`

```plain
export DOTNET_HOME=/opt/neptune-dotnet
```

Run `dotnet --list-sdks` to verify that all sdks are available.

The output should be something similar to:

```plain
$ dotnet --list-sdks
6.0.419 [/opt/neptune-dotnet/sdk]
7.0.406 [/opt/neptune-dotnet/sdk]
8.0.201 [/opt/neptune-dotnet/sdk]
```

### conflicts with other repositories

If you use this overlay's blender you should mask Gentoo's ebuilds for blender

```
media-gfx/blender::gentoo
```

OIDN if you use HIP

```
media-libs/oidn::gentoo
```

Mask Guru's imhex if you use neptune's imhex (`app-editors/imhex`)

```
app-editors/imhex::guru
```

and discord if you use discord 

```
net-im/discord::gentoo
```
