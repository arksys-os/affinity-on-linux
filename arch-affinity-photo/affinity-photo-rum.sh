#!/bin/bash

# Script to install Affinity Photo on Arch Linux
# Adapted from: https://codeberg.org/Wanesty/affinity-wine-docs
#
# Prerequisites files goees under "/home/your-user/WINE" (directory to group content):
# Affnity Photo executable: $HOME/WINE/affinity-photo-msi-2.x.x.exe
# Directory containing the necessary WinMetadata files: $HOME/WINE/WinMetadata/
#
# To update an app with WINE, you need:
# update system, rum and wine (optional)
# download new app version "affinity-photo-msi-2.x.x.exe" and copy under the WINE folder $HOME/WINE/
# launch exe (to reinstall app), just cliking in .desktop: rum affinity-photo3-wine9.13-part3 $HOME/.wineAffinity wine $HOME/WINE/affinity-photo-msi-2.x.x.exe


set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to detect the OS and install dependencies
install_dependencies() {
    if [ -f /etc/arch-release ]; then
        echo "Detected Arch Linux system. Installing dependencies..."
        sudo pacman -Syu --needed \
            alsa-lib alsa-plugins cups desktop-file-utils dosbox ffmpeg fontconfig \
            freetype2 gcc-libs gettext giflib gnutls gst-plugins-base-libs gtk3 \
            libgphoto2 libpcap libpulse libva libxcomposite libxcursor libxi \
            libxinerama libxrandr mingw-w64-gcc opencl-headers opencl-icd-loader samba \
            sane sdl2 v4l-utils vulkan-icd-loader wine-mono git
    else
        echo "Unsupported OS. Please manually install the required dependencies."
        exit 1
    fi
}

# Get the absolute path of the user's home directory
if command_exists realpath; then
    FULL_PATH=$(realpath "$HOME")
else
    FULL_PATH="/home/$(whoami)"
fi

# Variables
WINE_DIR="$FULL_PATH/WINE"
WINE_PREFIX="$FULL_PATH/.wineAffinity"
WINE_RUNNER="affinity-photo3-wine9.13-part3"
RUM_DIR="$WINE_DIR/rum"
RUM_BIN="/usr/local/bin/rum"
WINE_SRC_DIR="$WINE_DIR/ElementalWarrior-wine"
WINE_INSTALL_DIR="/opt/wines/$WINE_RUNNER"
AFFINITY_INSTALLER_PATH="$WINE_DIR/affinity-photo-msi-2.5.5.exe" # adapt downloaded version
DESKTOP_ENTRY_PATH="$FULL_PATH/.local/share/applications/photo.desktop"

# Update and install dependencies
echo "Updating system and installing necessary dependencies..."
install_dependencies || { echo "Failed to install dependencies"; exit 1; }

# Clone the rum repository if it doesn't exist
if [ ! -d "$RUM_DIR" ]; then
    echo "Cloning the rum repository..."
    git clone https://gitlab.com/xkero/rum "$RUM_DIR" || { echo "Failed to clone rum repository"; exit 1; }
else
    echo "Rum repository already exists. Skipping clone."
fi

# Copy rum to /usr/local/bin if it isn't already there
if [ ! -f "$RUM_BIN" ]; then
    echo "Copying rum to /usr/local/bin..."
    sudo cp "$RUM_DIR/rum" "$RUM_BIN"
    sudo chmod +x "$RUM_BIN"
else
    echo "Rum is already installed in /usr/local/bin."
fi

# Clone and compile ElementalWarrior's Wine fork if not already done
if [ ! -d "$WINE_SRC_DIR" ]; then
    echo "Cloning ElementalWarrior's Wine fork..."
    git clone https://gitlab.winehq.org/ElementalWarrior/wine.git "$WINE_SRC_DIR"
    cd "$WINE_SRC_DIR" || exit
    git switch affinity-photo3-wine9.13-part3
    mkdir -p winewow64-build wine-install
    cd winewow64-build || exit
    ../configure --prefix="$WINE_SRC_DIR/wine-install" --enable-archs=i386,x86_64
    make --jobs 4
    sudo make install
else
    echo "Wine source already exists. Skipping cloning and building."
fi

# Copy the compiled Wine build to /opt/wines
echo "Copying compiled Wine build to /opt/wines..."
sudo mkdir -p /opt/wines
sudo cp -r "$WINE_SRC_DIR/wine-install/" "$WINE_INSTALL_DIR"
sudo ln -sf "$WINE_INSTALL_DIR/bin/wine" "/usr/bin/wine-affinity"
sudo ln -sf "$WINE_INSTALL_DIR/bin/wine64" "/usr/bin/wine64-affinity"

# Initialize Wine prefix and install necessary dependencies with rum
echo "Initializing Wine prefix and installing dependencies..."
rum "$WINE_RUNNER" "$WINE_PREFIX" wineboot --init
rum "$WINE_RUNNER" "$WINE_PREFIX" winetricks dotnet48 corefonts
rum "$WINE_RUNNER" "$WINE_PREFIX" winecfg -v win11

# Copy WinMetadata files
echo "Copying WinMetadata files..."
cp -r "$WINE_DIR/WinMetadata/" "$WINE_PREFIX/drive_c/windows/system32/WinMetadata"

# Install Affinity Photo
echo "Installing Affinity Photo..."
rum "$WINE_RUNNER" "$WINE_PREFIX" wine "$AFFINITY_INSTALLER_PATH"

# Copy desktop entry file
echo "Setting up desktop entry..."
mkdir -p "$(dirname "$DESKTOP_ENTRY_PATH")"
cp "$WINE_DIR/photo.desktop" "$DESKTOP_ENTRY_PATH"

echo "Setup complete. You can now launch Affinity Photo from your application menu."
