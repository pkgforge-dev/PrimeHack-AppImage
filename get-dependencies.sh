#!/bin/sh

set -eu

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel       \
	bluez-libs       \
	bzip2            \
	cmake            \
	enet             \
	hidapi           \
	kvantum          \
	libusb           \
	lz4              \
	lzo              \
	lxqt-qtplugin    \
	mesa             \
	pipewire-audio   \
	pipewire-jack    \
	qt6ct            \
	qt6-wayland      \
	sdl3             \
	speexdsp         \
	vulkan-headers   \
	xcb-util-cursor  \
	xxhash           \
	xz

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common ! gtk3

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

echo "Building primehack..."
echo "---------------------------------------------------------------"
git clone https://github.com/shiiion/dolphin.git ./dolphin
cd ./dolphin

# Determine to build nightly or stable
if [ "${DEVEL_RELEASE-}" = 1 ]; then
	git rev-parse --short HEAD > ~/version
else
	git fetch --tags origin
	# Manually excludes the old Dolphin releases. This will likely need maintenance eventually.
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|pre\|nJoy\|2\.0\|3\.0\|3\.5\|4\.0\|5\.0' | head -1)
	git checkout "$TAG"
	echo "$TAG" > ~/version
fi

# BUILD PRIMEHACK
mkdir ./build
cd ./build
git submodule update --init --recursive
cmake .. \
	-DDISTRIBUTOR=pkgforge-dev   \
	-DCMAKE_INSTALL_PREFIX=/usr  \
	-DENABLE_ANALYTICS=OFF       \
	-DENABLE_LLVM=OFF            \
	-DUSE_DISCORD_PRESENCE=OFF   \
	-DENABLE_AUTOUPDATE=OFF      \
	-DENCODE_FRAMEDUMPS=OFF
make -j$(nproc)
sudo make install
