#!/bin/bash
# Script generated from: https://codeberg.org/Wanesty/affinity-wine-docs

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
            sane sdl2 v4l-utils vulkan-icd-loader wine-mono
    elif [ -f /etc/debian_version ]; then
        echo "Detected Debian-based system. Installing dependencies..."
        sudo apt update && sudo apt install -y \
            gcc-mingw-w64 gcc-multilib libasound2-dev libcups2-dev libdbus-1-dev \
            libfontconfig-dev libfreetype-dev libgl-dev libgnutls28-dev libgphoto2-dev \
            libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev libosmesa6-dev \
            libpcap-dev libpulse-dev libsane-dev libsdl2-dev libudev-dev libunwind-dev \
            libusb-1.0-0-dev libvulkan-dev libx11-dev libxcomposite-dev libxcursor-dev \
            libxext-dev libxfixes-dev libxi-dev libxrandr-dev libxrender-dev \
            ocl-icd-opencl-dev samba-dev
    elif [ -f /etc/fedora-release ]; then
        echo "Detected Fedora system. Installing dependencies..."
        sudo dnf install -y \
            alsa-lib-devel cups-devel dbus-libs fontconfig-devel freetype-devel \
            glibc-devel.i686 gnutls-devel gstreamer1-devel gstreamer1-plugins-base-devel \
            libgphoto2-devel libunwind-devel libusbx-devel libX11-devel libXcomposite-devel \
            libXcursor-devel libXext-devel libXfixes-devel libXi-devel libXrandr-devel \
            libXrender-devel mesa-libGL-devel mesa-libOSMesa-devel mingw32-gcc mingw64-gcc \
            ocl-icd-devel samba-devel sane-backends-devel SDL2-devel vulkan-headers \
            vulkan-loader vulkan-loader-devel
    elif [ -f /etc/SuSE-release ] || [ -f /etc/SUSE-brand ]; then
        echo "Detected openSUSE system. Installing dependencies..."
        sudo zypper install -y \
            alsa-lib-devel cups-devel dbus-libs fontconfig-devel freetype-devel \
            glibc-devel-32bit gnutls-devel gstreamer-devel gstreamer-plugins-base-devel \
            libgphoto2-devel libOSMesa-devel libunwind-devel libusb-1_0-devel \
            libusb-compat-devel libX11-devel libXcomposite-devel libXcursor-devel \
            libXext-devel libXfixes-devel libXi-devel libXrandr-devel libXrender-devel \
            Mesa-libGL-devel mingw32-gcc mingw64-gcc ocl-icd-devel samba-devel \
            sane-backends-devel SDL2-devel vulkan-devel vulkan-headers vulkan-tools
    else
        echo "Unsupported OS. Please manually install the required dependencies."
        exit 1
    fi
}

# Get the full absolute path of the user's home directory
if command_exists realpath; then
    FULL_PATH=$(realpath "$HOME")
else
    FULL_PATH="/home/$(whoami)"
fi

# Example usage of FULL_PATH
WINE_DIR="$FULL_PATH/WINE"
WINE_PREFIX="$FULL_PATH/.wineAffinity"
WINE_RUNNER="affinity-photo3-wine9.13-part3"
RUM_DIR="$WINE_DIR/rum"
RUM_BIN="/usr/local/bin/rum"

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
WINE_SRC_DIR="$WINE_DIR/ElementalWarrior-wine"
if [ ! -d "$WINE_SRC_DIR" ]; then
    echo "Cloning ElementalWarrior's Wine fork..."
    git clone https://gitlab.winehq.org/ElementalWarrior/wine.git "$WINE_SRC_DIR"
    cd "$WINE_SRC_DIR" || exit
    git switch affinity-photo3-wine9.13-part3
    mkdir -p winewow64-build/ wine-install/
    cd winewow64-build || exit
    ../configure --prefix="$WINE_SRC_DIR/wine-install" --enable-archs=i386,x86_64
    make --jobs 4
    make install
else
    echo "Wine source already exists. Skipping cloning and building."
fi

# Copy the compiled Wine build to /opt/wines
echo "Copying compiled Wine build to /opt/wines..."
sudo mkdir -p /opt/wines
sudo cp -r "$WINE_SRC_DIR/wine-install/" "/opt/wines/$WINE_RUNNER"
sudo ln -sf "/opt/wines/$WINE_RUNNER/bin/wine" "/opt/wines/$WINE_RUNNER/bin/wine64"

# Initialize Wine prefix and install necessary dependencies with rum
echo "Initializing Wine prefix and installing dependencies..."
rum "$WINE_RUNNER" "$WINE_PREFIX" wineboot --init
rum "$WINE_RUNNER" "$WINE_PREFIX" winetricks dotnet48 corefonts
rum "$WINE_RUNNER" "$WINE_PREFIX" winecfg -v win11

# Copy WinMetadata files
echo "Copying WinMetadata files..."
cp -r $WINE_DIR/WinMetadata/ "$WINE_PREFIX/drive_c/windows/system32/WinMetadata"

# Function to install Affinity applications
install_app() {
    local app_name=$1
    local installer_path=$2

    echo "Installing $app_name..."
    rum $WINE_RUNNER $WINE_PREFIX wine "$installer_path"
    echo "$app_name installation started."
}

# Prompt the user for which application(s) to install
echo "Which application(s) do you want to install?"
echo "1) Affinity Photo"
echo "2) Affinity Designer"
echo "3) Affinity Publisher"
echo "You can enter multiple numbers separated by spaces (e.g., '1 2', '1 2 3')."
read -p "Enter your choice (1-3): " choices

# Define paths to installers
declare -A INSTALLERS
INSTALLERS["1"]="$WINE_DIR/apps/affinity-photo-msi-2.5.3.exe"
INSTALLERS["2"]="$WINE_DIR/apps/affinity-designer-msi-2.5.3.exe"
INSTALLERS["3"]="$WINE_DIR/apps/affinity-publisher-msi-2.5.3.exe"

# Loop through each choice and install the corresponding application
for choice in $choices; do
    if [[ -n "${INSTALLERS[$choice]}" ]]; then
        install_app "Affinity $(case $choice in 1) echo "Photo";; 2) echo "Designer";; 3) echo "Publisher";; esac)" "${INSTALLERS[$choice]}"
    else
        echo "Invalid choice: $choice. Skipping."
    fi
done

# Finish and prompt user to launch the application
echo -e "Setup complete.\nNow launch the executable Affinity app with rum..."
echo "Example: rum $WINE_RUNNER $WINE_PREFIX wine '$WINE_PREFIX/drive_c/Program Files/Affinity/Designer 2/Designer.exe'"
