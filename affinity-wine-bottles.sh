#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Error: Unsupported Linux distribution."
    exit 1
fi

# Install Bottles if not installed (only with flatpak)
if ! command -v bottles-cli &> /dev/null; then
    echo "Bottles is not installed. Installing Bottles via Flatpak..."
    flatpak install -y flathub com.usebottles.bottles
else
    echo "Bottles is already installed. Skipping installation."
fi

# Set the Wine Runner path for Flatpak installation of Bottles
if [ -d "$HOME/.var/app/com.usebottles.bottles" ]; then
    BOTTLES_RUNNERS_PATH="$HOME/.var/app/com.usebottles.bottles/data/bottles/runners"
else
    echo "Error: Could not determine Bottles installation path."
    exit 1
fi

# Ensure the custom runner directory exists
CUSTOM_RUNNER="affinity-photo3-wine9.13-part3"
CUSTOM_RUNNER_PATH="$BOTTLES_RUNNERS_PATH/$CUSTOM_RUNNER"
if [ ! -d "$CUSTOM_RUNNER_PATH" ]; then
    echo "Custom runner not found. Copying compiled Wine build to Bottles runner directory..."
    sudo mkdir -p "$CUSTOM_RUNNER_PATH"
    sudo cp -r "/opt/wines/$CUSTOM_RUNNER/" "$CUSTOM_RUNNER_PATH"
else
    echo "Custom runner '$CUSTOM_RUNNER' already exists. Skipping copying."
fi

# Function to install applications into a Bottle
install_affinity_apps() {
    local bottle_name="Affinity-Apps"
    local dependencies="dotnet48 corefonts"
    local win_version="win10"

    echo "Checking if bottle '$bottle_name' exists..."
    if ! bottles-cli list | grep -q "$bottle_name"; then
        echo "Creating a new bottle for $bottle_name with custom runner '$CUSTOM_RUNNER'..."
        bottles-cli new --bottle-name "$bottle_name" --environment wine --arch win64 --runner "$CUSTOM_RUNNER"
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

# Execute application installation
install_affinity_apps

echo "Installation complete. You can launch the Affinity products from Bottles or by using the following command:"
echo "bottles-cli run -b 'Affinity-Apps' -p 'wine $HOME/.local/share/bottles/bottles/Affinity-Apps/drive_c/Program Files/Affinity/Designer 2/Designer.exe'"
