#!/bin/bash

# Affinity v2 (by Canva) setup script
# Based on the official guide: https://affinity.liz.pet/v2/
#
# Unlike the legacy v1 setup, this does NOT need ElementalWarrior's wine fork or rum:
# Affinity v2.x runs on stock Wine >= 10.17 with winetricks and a small wintypes.dll shim.
#
# Usage:
#   sh ./scripts/affinity-wine-v2.sh [path-to-affinity-installer.exe]
#
# The wineprefix location can be overridden with the WINEPREFIX env var,
# it defaults to "$HOME/.wineAffinity3".

set -e

command_exists() {
    command -v "$1" &> /dev/null
}

# Get the full absolute path of the user's home directory
if command_exists realpath; then
    FULL_PATH=$(realpath "$HOME")
else
    FULL_PATH="/home/$(whoami)"
fi

export WINEPREFIX="${WINEPREFIX:-$FULL_PATH/.wineAffinity3}"
WINTYPES_URL="https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity/raw/refs/heads/master/wintypes_shim.dll.so"
WINMD_URL="https://github.com/microsoft/windows-rs/raw/master/crates/libs/bindgen/default/Windows.winmd"

# Install wine, wine-mono and winetricks if needed
install_dependencies() {
    if [ -f /etc/arch-release ]; then
        echo "Detected Arch Linux system. Installing dependencies..."
        sudo pacman -S --needed wine wine-mono winetricks
    elif [ -f /etc/debian_version ]; then
        echo "Detected Debian-based system. Installing dependencies..."
        sudo apt update && sudo apt install -y wine winetricks
    elif [ -f /etc/fedora-release ]; then
        echo "Detected Fedora system. Installing dependencies..."
        sudo dnf install -y wine wine-mono winetricks
    elif [ -f /etc/SuSE-release ] || [ -f /etc/SUSE-brand ]; then
        echo "Detected openSUSE system. Installing dependencies..."
        sudo zypper install -y wine wine-mono winetricks
    else
        echo "Unsupported OS. Please manually install wine (>= 10.17), wine-mono and winetricks."
        echo "Check https://repology.org for the package names on your distro."
        exit 1
    fi
}

if ! command_exists wine || ! command_exists winetricks; then
    install_dependencies
fi

WINE_VERSION=$(wine --version | grep -oE '[0-9]+\.[0-9]+' | head -n1)
WINE_MAJOR=$(echo "$WINE_VERSION" | cut -d. -f1)
WINE_MINOR=$(echo "$WINE_VERSION" | cut -d. -f2)
if [ "$WINE_MAJOR" -lt 10 ] || { [ "$WINE_MAJOR" -eq 10 ] && [ "$WINE_MINOR" -lt 17 ]; }; then
    echo "Warning: Affinity v2 requires Wine 10.17 or newer, found $WINE_VERSION."
    echo "Update wine through your distro's package manager (or check https://repology.org/project/wine/versions)."
fi

echo "Creating wineprefix at $WINEPREFIX..."
wineboot --init

echo "Installing required components with winetricks..."
winetricks --unattended --force remove_mono vcrun2022 dotnet48 corefonts win11

# Run the Affinity installer
INSTALLER="$1"
if [ -z "$INSTALLER" ]; then
    read -p "Path to the Affinity installer .exe: " INSTALLER
fi
INSTALLER=$(realpath "$INSTALLER")
echo "Running the Affinity installer..."
wine "$INSTALLER"

# Download and install wintypes.dll and Windows.winmd
echo "Downloading wintypes.dll and Windows.winmd..."
TMP_DIR=$(mktemp -d)
curl --output "$TMP_DIR/wintypes.dll" --location "$WINTYPES_URL"
curl --output "$TMP_DIR/Windows.winmd" --location "$WINMD_URL"

AFFINITY_DIR="$WINEPREFIX/drive_c/Program Files/Affinity/Affinity"
WINMETADATA_DIR="$WINEPREFIX/drive_c/windows/system32/WinMetadata"
mkdir -p "$AFFINITY_DIR" "$WINMETADATA_DIR"

cp "$TMP_DIR/wintypes.dll" "$AFFINITY_DIR/"
cp "$TMP_DIR/Windows.winmd" "$WINMETADATA_DIR/"
rm -rf "$TMP_DIR"

echo "Setup complete! Launch Affinity with:"
echo "WINEPREFIX=\"$WINEPREFIX\" wine \"$AFFINITY_DIR/Affinity.exe\""
