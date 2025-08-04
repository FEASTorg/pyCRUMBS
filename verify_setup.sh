#!/bin/bash

# Simple verification script for pyCRUMBS setup
# This script can be run to verify the installation worked correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

echo "========================================"
print_status "pyCRUMBS Installation Verification"
echo "========================================"

# Check if virtual environment exists
if [ -d "$HOME/pycrumbs_env" ]; then
    print_success "Virtual environment found"
else
    print_error "Virtual environment not found at $HOME/pycrumbs_env"
    exit 1
fi

# Check if repository exists
if [ -d "$HOME/pyCRUMBS" ]; then
    print_success "Repository found"
else
    print_error "Repository not found at $HOME/pyCRUMBS"
    exit 1
fi

# Check if convenience scripts exist
if [ -f "$HOME/activate_pycrumbs.sh" ] && [ -f "$HOME/test_pycrumbs.sh" ]; then
    print_success "Convenience scripts found"
else
    print_warning "Some convenience scripts missing"
fi

# Activate environment and test Python imports
print_status "Testing Python environment..."
source "$HOME/pycrumbs_env/bin/activate"

# Test smbus2 import
if python3 -c "import smbus2" 2>/dev/null; then
    print_success "smbus2 package available"
else
    print_error "smbus2 package not found"
    exit 1
fi

# Test pyCRUMBS import
cd "$HOME"
if python3 -c "from pyCRUMBS import CRUMBS, CRUMBSMessage" 2>/dev/null; then
    print_success "pyCRUMBS package imports successfully"
else
    print_error "pyCRUMBS package import failed"
    exit 1
fi

# Check I2C tools
if command -v i2cdetect >/dev/null 2>&1; then
    print_success "i2c-tools available"
else
    print_error "i2c-tools not found"
    exit 1
fi

# Check I2C permissions
if groups $USER | grep -q "\bi2c\b"; then
    print_success "User is in i2c group"
else
    print_warning "User not in i2c group - you may need to reboot"
fi

# Check if I2C is enabled
print_status "Checking I2C configuration..."
if command -v raspi-config >/dev/null 2>&1; then
    i2c_status=$(sudo raspi-config nonint get_i2c)
    if [ "$i2c_status" = "0" ]; then
        print_success "I2C is enabled (raspi-config)"
    else
        print_warning "I2C is disabled according to raspi-config"
    fi
else
    print_warning "raspi-config not available for I2C status check"
fi

# Check I2C device node
if [ -e "/dev/i2c-1" ]; then
    print_success "I2C device node (/dev/i2c-1) exists"
else
    print_warning "I2C device node (/dev/i2c-1) not found"
fi

# Check if I2C kernel module is loaded
if lsmod | grep -q "i2c_dev"; then
    print_success "I2C kernel module (i2c_dev) loaded"
else
    print_warning "I2C kernel module not loaded - may need to enable I2C"
fi

echo ""
echo "========================================"
print_success "Verification completed!"
echo ""
print_status "Next steps:"
echo "1. Connect your I2C devices"
echo "2. Check devices with: i2cdetect -y 1"
echo "3. Run the test: ./test_pycrumbs.sh"
echo "4. Or activate environment: ./activate_pycrumbs.sh"
echo ""
print_warning "If you see warnings above, you may need to reboot or enable I2C"
echo "========================================"
