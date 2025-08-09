#!/bin/bash

# pyCRUMBS Automated Setup Script
# This script automates the setup process for pyCRUMBS on Raspberry Pi
# Run this script after SSHing into your Raspberry Pi

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if I2C is enabled
check_i2c_enabled() {
    # Check using raspi-config non-interactive mode
    # Returns 0 if enabled, 1 if disabled
    if command -v raspi-config >/dev/null 2>&1; then
        local status=$(sudo raspi-config nonint get_i2c)
        if [ "$status" = "0" ]; then
            return 0  # I2C is enabled
        else
            return 1  # I2C is disabled
        fi
    else
        # Fallback: check if device node exists
        if [ -e "/dev/i2c-1" ]; then
            return 0
        else
            return 1
        fi
    fi
}

# Function to enable I2C automatically
enable_i2c() {
    print_status "Enabling I2C..."
    
    # Method 1: Use raspi-config non-interactive mode (preferred)
    if command -v raspi-config >/dev/null 2>&1; then
        print_status "Using raspi-config to enable I2C..."
        sudo raspi-config nonint do_i2c 0
        
        # Verify it worked
        if check_i2c_enabled; then
            print_success "I2C enabled successfully using raspi-config"
            return 0
        else
            print_warning "raspi-config method failed, trying config.txt method..."
        fi
    else
        print_warning "raspi-config not found, using config.txt method..."
    fi
    
    # Method 2: Direct config.txt modification (fallback)
    print_status "Modifying /boot/firmware/config.txt directly..."
    
    # First try the new location
    local config_file="/boot/firmware/config.txt"
    if [ ! -f "$config_file" ]; then
        # Fallback to old location
        config_file="/boot/config.txt"
    fi
    
    if [ ! -f "$config_file" ]; then
        print_error "Could not find config.txt file"
        return 1
    fi
    
    # Backup the config file
    sudo cp "$config_file" "$config_file.backup.$(date +%Y%m%d_%H%M%S)"
    print_status "Created backup of config.txt"
    
    # Check if dtparam=i2c_arm=on already exists and is uncommented
    if grep -q "^dtparam=i2c_arm=on" "$config_file"; then
        print_success "I2C already enabled in config.txt"
        return 0
        elif grep -q "^#dtparam=i2c_arm=on" "$config_file"; then
        # Uncomment existing line
        print_status "Uncommenting dtparam=i2c_arm=on in config.txt..."
        sudo sed -i 's/^#dtparam=i2c_arm=on/dtparam=i2c_arm=on/' "$config_file"
    else
        # Add the line
        print_status "Adding dtparam=i2c_arm=on to config.txt..."
        echo "dtparam=i2c_arm=on" | sudo tee -a "$config_file" > /dev/null
    fi
    
    print_success "I2C enabled in config.txt"
    return 0
}

# Function to configure I2C
configure_i2c() {
    print_status "Checking I2C configuration..."
    
    if check_i2c_enabled; then
        print_success "I2C is already enabled"
        return 0
    fi
    
    print_status "I2C is not currently enabled. Attempting to enable automatically..."
    
    if enable_i2c; then
        # Check if we need a reboot
        if check_i2c_enabled; then
            print_success "I2C enabled successfully (no reboot required)"
            return 0
        else
            print_warning "I2C configuration updated, but may require a reboot to take effect"
            echo ""
            read -p "Would you like to reboot now to complete I2C setup? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status "Rebooting system..."
                echo "After reboot, please re-run this script to complete the setup."
                sudo reboot
                exit 0
            else
                print_warning "I2C setup completed but may require manual reboot later"
                print_warning "If you encounter I2C issues, try rebooting the system"
                return 0
            fi
        fi
    else
        print_error "Failed to enable I2C automatically"
        print_warning "Please enable I2C manually using: sudo raspi-config"
        echo "Navigate to: Interface Options → I2C → Yes"
        echo "Then reboot and re-run this script"
        exit 1
    fi
}

print_status "Starting pyCRUMBS automated setup..."
echo "========================================"

# Step 1: Update system and install required packages
print_status "Updating system packages..."
sudo apt-get update -qq

print_status "Installing required system packages..."
sudo apt-get install -y i2c-tools git python3 python3-venv python3-pip

print_success "System packages installed"

# Step 2: Check and configure I2C
configure_i2c

# Step 3: Add user to i2c group for permissions
print_status "Adding user to i2c group..."
sudo adduser $USER i2c
print_success "User added to i2c group"

# Step 4: Create virtual environment
VENV_DIR="$PWD/pycrumbs_env"
print_status "Creating Python virtual environment at $VENV_DIR..."

if [ -d "$VENV_DIR" ]; then
    print_warning "Virtual environment already exists. Removing old environment..."
    rm -rf "$VENV_DIR"
fi

python3 -m venv "$VENV_DIR"
print_success "Virtual environment created"

# Step 5: Activate virtual environment and install Python packages

print_status "Activating virtual environment and installing Python packages via setup.py..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -e .
print_success "pyCRUMBS package and dependencies installed"

# Step 6: Create convenience scripts
print_status "Creating convenience scripts..."

# Get the current repository directory
REPO_DIR="$PWD"

# Create activation script
cat > "$HOME/activate_pycrumbs.sh" << EOF
#!/bin/bash
# Activate pyCRUMBS environment
source "$REPO_DIR/pycrumbs_env/bin/activate"
cd "$REPO_DIR"
echo "pyCRUMBS environment activated!"
echo "Current directory: \$(pwd)"
echo ""
echo "To run the leader example:"
echo "  cd .."
echo "  python -m pyCRUMBS.examples.leader_example"
echo ""
echo "To check I2C devices:"
echo "  i2cdetect -y 1"
echo ""
echo "To deactivate environment:"
echo "  deactivate"
EOF

chmod +x "$HOME/activate_pycrumbs.sh"

# Create test script
cat > "$HOME/test_pycrumbs.sh" << EOF
#!/bin/bash
# Test pyCRUMBS setup
source "$REPO_DIR/pycrumbs_env/bin/activate"
cd "$REPO_DIR/.."
echo "Testing pyCRUMBS setup..."
echo "Checking I2C devices:"
i2cdetect -y 1
echo ""
echo "Starting leader example (press Ctrl+C to exit):"
python -m pyCRUMBS.examples.leader_example
EOF

chmod +x "$HOME/test_pycrumbs.sh"

print_success "Convenience scripts created in your home directory:"
echo "  - $HOME/activate_pycrumbs.sh (activate environment)"
echo "  - $HOME/test_pycrumbs.sh (run test example)"

# Step 7: Final instructions
echo ""
echo "========================================"
print_success "pyCRUMBS setup completed successfully!"
echo ""
echo "Virtual environment created at: $REPO_DIR/pycrumbs_env"
echo "Repository location: $REPO_DIR"
echo ""
echo "IMPORTANT: You may need to log out and log back in (or reboot) for"
echo "the i2c group membership to take effect."
echo ""
echo "After logging back in, you can:"
echo ""
echo "1. Verify the installation:"
echo "   ./verify_setup.sh"
echo ""
echo "2. Test the setup:"
echo "   ~/test_pycrumbs.sh"
echo ""
echo "3. Or manually activate the environment:"
echo "   ~/activate_pycrumbs.sh"
echo ""
echo "4. Check I2C devices:"
echo "   i2cdetect -y 1"
echo ""
echo "5. Run the leader example:"
echo "   cd .. && python -m pyCRUMBS.examples.leader_example"
echo ""
print_warning "If you encounter permission issues with I2C, try rebooting the system."
