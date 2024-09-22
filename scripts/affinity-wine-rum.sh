#!/bin/bash
#
# Script to install Affinity Photo on Arch Linux
# Adapted from: https://codeberg.org/Wanesty/affinity-wine-docs
#
# Prerequisites:
# Create WINE dir to group downloaded content on "$HOME/WINE"
# Download Affnity .exe apps and put under "$HOME/WINE/apps/affinity-xxx.exe"
# Copy WinMetadata from Windows11 "C:/windows/system32/WinMetadata on WINE dir "$HOME/WINE/WinMetadata/"
#
# To update an app with WINE, you need:
# update system, rum and wine (optional)
# download new app version "affinity-photo-msi-2.x.x.exe" and copy under the WINE folder $HOME/WINE/
# launch exe (to reinstall app), just cliking in .desktop: rum affinity-photo3-wine9.13-part3 $HOME/.wineAffinity wine $HOME/WINE/affinity-photo-msi-2.x.x.exe

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to detect the OS and install dependencies
install_dependencies() {
    if [ -f /etc/arch-release ]; then
        echo "Detected Arch Linux system. Installing dependencies..."
        sudo pacman -Syu --needed \
            alsa-lib alsa-plugins autoconf bison cups desktop-file-utils flex fontconfig freetype2 gcc-libs gettext gnutls gst-plugins-bad gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly libcups libgphoto2 libpcap libpulse libunwind libxcomposite libxcursor libxi libxinerama libxkbcommon libxrandr libxxf86vm mesa mesa-libgl mingw-w64-gcc opencl-headers opencl-icd-loader pcsclite perl samba sane sdl2 unixodbc v4l-utils vulkan-headers vulkan-icd-loader wayland wine-gecko wine-mono
    elif [ -f /etc/debian_version ]; then
        echo "Detected Debian-based system. Installing dependencies..."
        sudo apt update && sudo apt install -y \
            bison dctrl-tools flex fontforge-nox freeglut3-dev gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 gettext icoutils imagemagick libasound2-dev libcapi20-dev libcups2-dev libdbus-1-dev libfontconfig-dev libfreetype-dev libgettextpo-dev libgl-dev libglu1-mesa-dev libgnutls28-dev libgphoto2-dev libgstreamer-plugins-base1.0-dev  libkrb5-dev libldap2-dev libncurses-dev libopenal-dev libosmesa6-dev libpcap0.8-dev libpcsclite-dev libpulse-dev librsvg2-bin libsdl2-dev libssl-dev libudev-dev libunwind-dev libusb-1.0-0-dev libv4l-dev libvulkan-dev libwayland-dev libx11-dev libxcomposite-dev libxcursor-dev libxext-dev libxfixes-dev libxi-dev libxinerama-dev libxkbfile-dev libxkbregistry-dev libxml-libxml-perl libxmu-dev libxrandr-dev libxrender-dev libxt-dev libxxf86dga-dev libxxf86vm-dev libz-mingw-w64-dev lzma ocl-icd-opencl-dev pkg-config quilt sharutils unicode-idna unixodbc-dev unzip
    elif [ -f /etc/fedora-release ]; then
        echo "Detected Fedora system. Installing dependencies..."
        sudo dnf install -y \
            alsa-lib-devel audiofile-devel autoconf bison chrpath cups-devel dbus-devel desktop-file-utils flex fontconfig-devel fontforge fontpackages-devel freeglut-devel freetype-devel gcc gettext-devel giflib-devel gnutls-devel gsm-devel gstreamer1-devel gstreamer1-plugins-base-devel icoutils libappstream-glib libgphoto2-devel libieee1284-devel libpcap-devel librsvg2 librsvg2-devel libstdc++-devel libv4l-devel libX11-devel libXcomposite-devel libXcursor-devel libXext-devel libXi-devel libXinerama-devel libXmu-devel libXrandr-devel libXrender-devel libXxf86dga-devel libXxf86vm-devel make mesa-libGL-devel mesa-libGLU-devel mesa-libOSMesa-devel mingw32-FAudio mingw32-gcc mingw32-lcms2 mingw32-libpng mingw32-libtiff mingw32-libxml2 mingw32-libxslt	 mingw32-vkd3d mingw32-vulkan-headers mingw64-FAudio mingw64-gcc mingw64-lcms2 mingw64-libpng mingw64-libtiff mingw64-libxml2 mingw64-libxslt mingw64-vkd3d mingw64-vulkan-headers mingw64-zlib mpg123-devel ocl-icd-devel opencl-headers openldap-devel perl-generators pulseaudio-libs-devel sane-backends-devel SDL2-devel systemd-devel unixODBC-devel vulkan-devel wine-mono
    elif [ -f /etc/SuSE-release ] || [ -f /etc/SUSE-brand ]; then
        echo "Detected openSUSE system. Installing dependencies..."
        sudo zypper install -y \
            alsa-devel autoconf bison cups-devel dbus-1-devel desktop-file-utils egl FAudio-devel fdupes flex fontconfig-devel freeglut-devel freetype2-devel giflib-devel git gl glib2-devel glu gstreamer-plugins-base-devel krb5-devel libcapi20-devel libgnutls-devel libgphoto2-devel libgsm-devel libjpeg-devel liblcms2-devel libpcap-devel libpng-devel libpulse-devel libtiff-devel libudev libusb-1.0 libv4l-devel libxml2-devel libxslt-devel mingw32-cross-gcc mingw32-libz mingw32-zlib-devel mingw64-cross-gcc mingw64-zlib-devel mpg123-devel ncurses-devel ocl-icd-devel openal-soft-devel openldap2-devel openssl-devel osmesa pcsc-lite-devel pkgconfig sane-backends-devel SDL2-devel systemd-devel update-desktop-files valgrind-devel vkd3d-devel vulkan-devel vulkan-headers vulkan-tools wayland-client wine-mono x11 x11-xcb xcb xcb-dri3 xcb-present xcb-xfixes xcomposite xcursor xext xfixes xi xinerama xkbcommon xkbregistry xrandr xrender xxf86vm zlib
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

# Function to select which Affinity applications to install
install_app() {
    local app_name=$1
    local installer_path=$2
    echo "Installing $app_name..."
    rum $WINE_RUNNER $WINE_PREFIX wine "$installer_path"
    echo "$app_name installation started."
}

# Prompt the user for which application(s) to install
echo "Which application(s) do you want to install?"
echo "1) Affinity Designer"
echo "2) Affinity Photo"
echo "3) Affinity Publisher"
echo "You can enter multiple numbers separated by spaces (e.g., '1', '1 2', '1 2 3')."
read -p "Enter your choice (1-3): " choices

# Define paths to installers
declare -A INSTALLERS
INSTALLERS["1"]="$WINE_DIR/apps/affinity-designer-msi-2.5.5.exe"
INSTALLERS["2"]="$WINE_DIR/apps/affinity-photo-msi-2.5.5.exe"
INSTALLERS["3"]="$WINE_DIR/apps/affinity-publisher-msi-2.5.5.exe"

# Loop through each choice and install the corresponding application
for choice in $choices; do
    if [[ -n "${INSTALLERS[$choice]}" ]]; then
        install_app "Affinity $(case $choice in 1) echo "Designer";; 2) echo "Photo";; 3) echo "Publisher";; esac)" "${INSTALLERS[$choice]}"
    else
        echo "Invalid choice: $choice. Skipping."
    fi
done

# Finish and prompt user to launch the application
echo -e "Setup complete.\nNow launch the executable Affinity app with rum..."
echo "rum $WINE_RUNNER $WINE_PREFIX wine '$WINE_PREFIX/drive_c/Program Files/Affinity/Designer 2/Designer.exe'"
