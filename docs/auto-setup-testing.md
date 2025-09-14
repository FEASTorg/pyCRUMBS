# Automated Setup Guide

Automated installation for pyCRUMBS on Raspberry Pi using the included setup script.

## Prerequisites

- Raspberry Pi 4B+ with Raspberry Pi OS Lite 64-bit
- SSH access and internet connection
- Arduino with level shifter for I2C (optional for testing)

## Quick Setup

### 1. Download and Run Setup

```bash
ssh username@raspberry_pi_address
sudo apt update && sudo apt install -y git
git clone https://github.com/FEASTorg/pyCRUMBS.git
cd pyCRUMBS
chmod +x setup_pycrumbs.sh
./setup_pycrumbs.sh
```

### 2. Verify Installation

```bash
./verify_setup.sh
~/test_pycrumbs.sh
```

## What the Script Does

The setup script automatically handles:

1. **System packages**: Installs `i2c-tools`, `python3-venv`, etc.
2. **I2C configuration**: Enables I2C using `raspi-config` or direct config file modification
3. **User permissions**: Adds user to `i2c` group
4. **Python environment**: Creates virtual environment in `./pycrumbs_env`
5. **Dependencies**: Installs `smbus2` package
6. **Helper scripts**: Creates convenience scripts in home directory

### I2C Auto-Configuration

The script automatically detects and enables I2C:

- Uses `raspi-config nonint do_i2c 0` for automatic enabling
- Falls back to direct `/boot/firmware/config.txt` modification
- Handles both new and legacy config file locations
- Prompts for reboot if needed

## Helper Scripts Created

**`~/activate_pycrumbs.sh`** - Activates environment:

```bash
~/activate_pycrumbs.sh
```

**`~/test_pycrumbs.sh`** - Runs complete test:

```bash
~/test_pycrumbs.sh
```

## Testing Communication

After setup, test I2C devices:

```bash
i2cdetect -y 1
```

Run the leader example:

```bash
~/activate_pycrumbs.sh
cd ..
python -m pyCRUMBS.examples.leader_example
```

### Example Commands

- **Request message**: `request,0x08`
- **Send message**: `0x08,1,1,75.0,1.0,0.0,65.0,2.0,7.0,0`
- **Exit**: `exit` or Ctrl+C

## Troubleshooting

### Permission Issues

If I2C permission errors occur:

```bash
groups $USER  # Check if i2c group is present
sudo reboot   # Reboot if group was just added
```

### I2C Configuration Issues

If automatic I2C setup fails:

```bash
# Manual enable
sudo raspi-config nonint do_i2c 0

# Verify config
grep "dtparam=i2c_arm=on" /boot/firmware/config.txt

# Check for old location
grep "dtparam=i2c_arm=on" /boot/config.txt

sudo reboot
```

### Module Import Errors

If getting `ModuleNotFoundError`:

```bash
# Ensure running from parent directory
python -m pyCRUMBS.examples.leader_example

# Verify environment activation
~/activate_pycrumbs.sh
```

### Environment Issues

If virtual environment problems occur:

```bash
# Delete and recreate
rm -rf ./pycrumbs_env
./setup_pycrumbs.sh
```

## Manual Cleanup

To remove automated setup:

```bash
# Remove virtual environment
rm -rf ./pycrumbs_env

# Remove helper scripts
rm ~/activate_pycrumbs.sh ~/test_pycrumbs.sh

# Remove user from i2c group (optional)
sudo deluser $USER i2c

# Remove repository (if desired)
cd .. && rm -rf pyCRUMBS
```

## Setup vs Manual Comparison

| Task           | Manual              | Automated                 |
| -------------- | ------------------- | ------------------------- |
| Time           | 15-20 min           | 3-5 min                   |
| I2C setup      | Manual navigation   | Fully automated           |
| Error handling | User responsibility | Built-in fallbacks        |
| Environment    | Manual creation     | Automatic with validation |

For manual setup details, see [Manual Setup Guide](manual-setup-testing.md).

## Next Steps

After successful setup:

1. Connect I2C devices and test communication
2. Develop custom applications using the library
3. Explore advanced examples in [Examples](examples.md)
4. Review [API Reference](api-reference.md) for detailed documentation
