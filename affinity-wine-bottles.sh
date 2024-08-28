#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install Flatpak based on the detected package manager
install_flatpak() {
    echo "Flatpak is not installed. Installing Flatpak..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y flatpak
    elif [ -f /etc/fedora-release ]; then
        sudo dnf install -y flatpak
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S flatpak --noconfirm
    elif grep -q openSUSE /etc/os-release; then
        sudo zypper install -y flatpak
    else
        echo "Error: Unsupported Linux distribution."
        exit 1
    fi
}

# Function to ensure the custom Wine runner directory exists and clone from GitLab if necessary
setup_wine_runner() {
    echo "Setting up Wine runner..."

    WINE_DIR="$FULL_PATH/WINE"
    WINE_SRC_DIR="$WINE_DIR/ElementalWarrior-wine"
    WINE_RUNNER_PATH="$BOTTLES_RUNNERS_PATH/ElementalWarrior-wine/affinity-photo3-wine9.13-part3"

    if [ ! -d "$WINE_SRC_DIR" ]; then
        echo "Cloning ElementalWarrior's Wine fork..."
        git clone https://gitlab.winehq.org/ElementalWarrior/wine.git "$WINE_SRC_DIR"
        cd "$WINE_SRC_DIR" || { echo "Failed to enter directory $WINE_SRC_DIR"; exit 1; }
        git switch affinity-photo3-wine9.13-part3
        mkdir -p winewow64-build/ wine-install/
        cd winewow64-build || { echo "Failed to enter directory winewow64-build"; exit 1; }
        ../configure --prefix="$WINE_SRC_DIR/wine-install" --enable-archs=i386,x86_64
        make --jobs 4
        make install
    else
        echo "Wine source already exists. Skipping cloning and building."
    fi
}

# Function to install applications into a Bottle
install_affinity_apps() {
    local bottle_name="Affinity-Apps"
    local dependencies="dotnet48 corefonts"
    local win_version="win10"

    echo "Checking if bottle '$bottle_name' exists..."
    if ! bottles-cli list | grep -q "$bottle_name"; then
        echo "Creating a new bottle for $bottle_name with custom runner '$WINE_RUNNER'..."
        bottles-cli new --bottle-name "$bottle_name" --environment wine --arch win64 --runner "$WINE_RUNNER"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create the bottle '$bottle_name'."
            exit 1
        fi
    else
        echo "Bottle '$bottle_name' already exists. Skipping creation."
    fi

    echo "Installing dependencies: $dependencies..."
    bottles-cli run -b "$bottle_name" -p "winetricks $dependencies"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install dependencies."
        exit 1
    fi

    echo "Setting Windows version to $win_version..."
    bottles-cli run -b "$bottle_name" -p "winecfg -v $win_version"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to set Windows version to $win_version."
        exit 1
    fi

    # Install Affinity applications
    echo "Installing Affinity applications..."
    local apps=("affinity-designer-1.10.5.exe" "affinity-photo-1.10.5.exe" "affinity-publisher-1.10.5.exe")
    for app in "${apps[@]}"; do
        local app_path="$HOME/WINE-apps/$app"
        if [ -f "$app_path" ]; then
            echo "Running the $app installer..."
            bottles-cli run -b "$bottle_name" -p "wine $app_path"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to run the installer for $app."
                exit 1
            fi
        else
            echo "Error: Installer not found at $app_path. Skipping."
        fi
    done

    # Copy WinMetadata files
    echo "Copying WinMetadata files..."
    cp -r "$HOME/WINE/WinMetadata/" "$HOME/.local/share/bottles/bottles/$bottle_name/drive_c/windows/system32/WinMetadata"
}

# Main script execution starts here

# Check if Flatpak is installed, install if not
if ! command_exists flatpak; then
    install_flatpak
fi

# Set the Bottles runner path for Flatpak installation
BOTTLES_RUNNERS_PATH="$HOME/.var/app/com.usebottles.bottles/data/bottles/runners"

if [ ! -d "$BOTTLES_RUNNERS_PATH" ]; then
    echo "Error: Could not determine Bottles installation path."
    exit 1
fi

# Get the full absolute path of the user's home directory
if command_exists realpath; then
    FULL_PATH=$(realpath "$HOME")
else
    FULL_PATH="/home/$(whoami)"
fi

# Install Bottles if not installed (only with Flatpak)
if ! command_exists bottles-cli; then
    echo "Bottles is not installed. Installing Bottles via Flatpak..."
    flatpak install -y flathub com.usebottles.bottles
else
    echo "Bottles is already installed. Skipping installation."
fi

# Set up the Wine runner
setup_wine_runner
echo "Setup complete."

# Execute application installation
install_affinity_apps

echo "Installation complete. You can launch the Affinity products from Bottles or by using the following command:"
echo "bottles-cli run -b 'Affinity-Apps' -p 'wine $HOME/.local/share/bottles/bottles/Affinity-Apps/drive_c/Program Files/Affinity/Designer 2/Designer.exe'"
