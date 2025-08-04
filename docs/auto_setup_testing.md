# Automated Setup and Testing Guide

This guide provides an automated setup process for pyCRUMBS on Raspberry Pi using the included setup script. This method significantly simplifies the manual setup process documented in [`manual_setup_testing.md`](manual_setup_testing.md).

## Prerequisites

- Raspberry Pi 4B+ (or compatible) with Raspberry Pi OS Lite 64-bit
- Arduino Nano R3 with level shifter (for I2C communication)
- SSH access to the Raspberry Pi
- Internet connection for downloading packages and repository

## Quick Setup Process

### 1. SSH into the Raspberry Pi

From your terminal, connect via SSH:

```bash
ssh username@raspberry_pi_address
```

Accept the host key if prompted and enter your password.

### 2. Update System and Install Git

First, update your system and install git:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git
```

### 3. Download and Run the Setup Script

Clone the repository and run the automated setup script:

```bash
git clone https://github.com/FEASTorg/pyCRUMBS.git
cd pyCRUMBS
chmod +x setup_pycrumbs.sh
./setup_pycrumbs.sh
```

### 4. I2C Configuration (Automated)

The script will automatically detect and enable I2C if it's not already configured:

- **If I2C is already enabled**: The script continues normally
- **If I2C is disabled**: The script automatically enables it using `raspi-config` non-interactive mode
- **If raspi-config fails**: The script falls back to directly modifying `/boot/firmware/config.txt`
- **If a reboot is needed**: The script will prompt you and can reboot automatically

No manual raspi-config navigation is required!

### 5. Complete Setup

The script will handle everything automatically and may prompt for a reboot if I2C configuration changes were made.

### 6. Verify and Test

After setup (and any required reboot), verify the installation:

```bash
cd ~/pyCRUMBS
./verify_setup.sh
```

Then test the setup:

```bash
~/test_pycrumbs.sh
```

## What the Setup Script Does

The automated setup script (`setup_pycrumbs.sh`) performs the following operations:

1. **System Update**: Updates package lists and installs required system packages

   - `i2c-tools` for I2C communication testing
   - `git` for repository management
   - `python3`, `python3-venv`, `python3-pip` for Python development

2. **I2C Configuration**: Automatically detects and enables I2C using multiple methods:

   - Uses `raspi-config nonint do_i2c 0` for automatic enabling
   - Falls back to direct `/boot/firmware/config.txt` modification if needed
   - Creates backups before making changes
   - Handles both new (`/boot/firmware/config.txt`) and legacy (`/boot/config.txt`) file locations

3. **User Permissions**: Adds the current user to the `i2c` group for device access

4. **Python Environment**: Creates a dedicated virtual environment at `./pycrumbs_env` (within the repository)

5. **Python Packages**: Installs required Python packages (`smbus2`) in the virtual environment

6. **Repository Update**: Updates the current repository to the latest version (since you're already in it)

7. **Convenience Scripts**: Creates helper scripts for easy environment management

The virtual environment is created within the repository directory for better organization and portability.

## Convenience Scripts Created

The setup script creates two helper scripts in your home directory:

### `activate_pycrumbs.sh`

Activates the Python virtual environment and navigates to the repository:

```bash
~/activate_pycrumbs.sh
```

### `test_pycrumbs.sh`

Runs a complete test of the setup:

```bash
~/test_pycrumbs.sh
```

## Testing I2C Communication

After setup completion, test your I2C devices:

```bash
i2cdetect -y 1
```

This command will show a grid with addresses of detected I2C devices.

## Running the Leader Example

To run the leader example for testing communication:

```bash
# Method 1: Use the test script
~/test_pycrumbs.sh

# Method 2: Manual activation
~/activate_pycrumbs.sh
cd ..
python -m pyCRUMBS.examples.leader_example
```

### Example Commands

Once the leader example is running, you can test with these commands:

- **Request a Message**: `request,0x08`
- **Send a Message**: `0x08,1,1,75.0,1.0,0.0,65.0,2.0,7.0,0`
- **Exit**: `exit` or press Ctrl+C

## Troubleshooting

### Permission Issues

If you encounter I2C permission errors:

1. Verify you're in the i2c group: `groups $USER`
2. If the group is missing, reboot the system: `sudo reboot`
3. Re-test after reboot

### I2C Configuration Issues

If the automatic I2C setup fails:

1. Check if raspi-config is available: `which raspi-config`
2. Manually enable using: `sudo raspi-config nonint do_i2c 0`
3. Verify config.txt has the line: `grep "dtparam=i2c_arm=on" /boot/firmware/config.txt`
4. If the file is at the old location: `grep "dtparam=i2c_arm=on" /boot/config.txt`
5. Reboot the system: `sudo reboot`

### I2C Not Detected

If `i2cdetect -y 1` shows no devices:

1. Check physical wiring connections
2. Verify level shifter is properly connected
3. Ensure target device is powered and responding
4. Try I2C bus 0 instead: `i2cdetect -y 0`

### Module Import Errors

If you get `ModuleNotFoundError`:

1. Ensure you're running from the parent directory of pyCRUMBS
2. Use the full module path: `python -m pyCRUMBS.examples.leader_example`
3. Verify virtual environment is activated

### Environment Issues

If virtual environment activation fails:

1. Delete the environment: `rm -rf ./pycrumbs_env`
2. Re-run the setup script: `./setup_pycrumbs.sh`

## Manual Cleanup

To remove the automated setup:

```bash
# Remove virtual environment (from within the repository)
rm -rf ./pycrumbs_env

# Remove convenience scripts
rm ~/activate_pycrumbs.sh ~/test_pycrumbs.sh

# Remove user from i2c group (optional)
sudo deluser $USER i2c

# Remove entire repository (if desired)
cd .. && rm -rf pyCRUMBS
```

## Comparison with Manual Setup

| Task                 | Manual Process                  | Automated Process                           |
| -------------------- | ------------------------------- | ------------------------------------------- |
| System updates       | Multiple apt commands           | Single script execution                     |
| I2C configuration    | Manual raspi-config navigation  | Fully automated with fallback methods       |
| Virtual environment  | Manual creation and activation  | Automatic creation with error handling      |
| Package installation | Manual pip commands             | Automatic with dependency management        |
| Repository cloning   | Manual git commands             | Automatic with cleanup of existing installs |
| Permission setup     | Manual group addition           | Automatic with instructions                 |
| Testing              | Manual navigation and execution | One-command testing script                  |

The automated setup reduces setup time from ~15-20 minutes to ~3-5 minutes, with significantly reduced chance of user error.

## Next Steps

After successful setup, you can:

1. **Develop Custom Applications**: Use the pyCRUMBS library in your own Python scripts
2. **Modify Examples**: Customize the leader example for your specific use case
3. **Add More Devices**: Connect additional I2C devices and test communication
4. **Integrate with Projects**: Use pyCRUMBS as part of larger Raspberry Pi projects

For more detailed information about the library and troubleshooting, refer to `manual_setup_testing.md`.
