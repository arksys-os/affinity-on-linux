#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Ensure yay is installed
if ! command_exists yay; then
    echo "Error: yay is not installed. Please install yay or another AUR helper."
    exit 1
fi

# Ensure Bottles is installed
if ! command_exists bottles-cli; then
    echo "Bottles is not installed. Installing Bottles..."
    yay -S bottles --noconfirm
    if ! command_exists bottles-cli; then
        echo "Error: Bottles installation failed. Please check your system and try again."
        exit 1
    fi
else
    echo "Bottles is already installed. Skipping installation."
fi

# Function to install an Affinity product in Bottles
install_affinity_product() {
    local app_name="$1"
    local app_path="$HOME/WINE-apps/$app_name"
    local bottle_name="${app_name%.exe}"
    local dependencies="dotnet48 corefonts"
    local win_version="win10"

    # Check if the installer exists
    if [ ! -f "$app_path" ]; then
        echo "Error: Installer not found at $app_path. Please ensure the installer is present."
        exit 1
    fi

    echo "Checking if bottle '$bottle_name' exists..."
    if ! bottles-cli list | grep -q "$bottle_name"; then
        echo "Creating a new bottle for $bottle_name..."
        bottles-cli new --bottle-name "$bottle_name" --environment wine --arch win64
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

    echo "Running the $app_name installer..."
    bottles-cli run -b "$bottle_name" -p "wine $app_path"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to run the installer."
        exit 1
    fi
}

# Function to select Affinity products to install
select_affinity_products() {
    echo "Select the Affinity products to install (e.g., 1 2 3 for all):"
    echo "1) Affinity Designer"
    echo "2) Affinity Photo"
    echo "3) Affinity Publisher"
    read -p "Enter your choices (separated by space): " -a choices

    for choice in "${choices[@]}"; do
        case $choice in
            1)
                install_affinity_product "affinity-designer-1.10.5.exe"
                ;;
            2)
                install_affinity_product "affinity-photo-1.10.5.exe"
                ;;
            3)
                install_affinity_product "affinity-publisher-1.10.5.exe"
                ;;
            *)
                echo "Invalid choice: $choice"
                ;;
        esac
    done
}

# Execute product selection and installation
select_affinity_products

echo "Installation complete. You can launch the Affinity products from Bottles or by using the following command:"
echo "bottles-cli run -b '<Bottle-Name>' -p 'wine $app_path'"
