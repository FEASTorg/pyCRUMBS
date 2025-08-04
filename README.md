# pyCRUMBS

pyCRUMBS is the Python implementation of the CRUMBS protocol for use with Raspberry Pi as the leader.

## Quick Setup (Automated)

For Raspberry Pi users, we provide a fully automated setup script that handles all configuration including I2C enabling:

```bash
# First, update system and install git
sudo apt update && sudo apt upgrade -y
sudo apt install -y git

# Then clone and run setup
git clone https://github.com/FEASTorg/pyCRUMBS.git
cd pyCRUMBS
chmod +x setup_pycrumbs.sh
./setup_pycrumbs.sh
```

The script automatically:

- Updates system packages
- Enables I2C (no manual raspi-config needed!)
- Sets up Python virtual environment
- Installs required packages
- Configures user permissions
- Creates convenience scripts

After setup, verify the installation:

```bash
./verify_setup.sh
```

Then test the installation:

```bash
./test_pycrumbs.sh
```

For detailed automated setup instructions, see [`docs/auto_setup_testing.md`](docs/auto_setup_testing.md).

## Manual Setup

For manual setup instructions and detailed troubleshooting, see [`docs/manual_setup_testing.md`](docs/manual_setup_testing.md).

## Usage

After setup, you can run the leader example to test I2C communication:

```bash
# Activate the environment
./activate_pycrumbs.sh

# Run the leader example
cd ..
python -m pyCRUMBS.examples.leader_example
```

### Example Commands

- **Request a Message**: `request,0x0a`
- **Send a Message**: `0x0a,1,1,1,0,0,0,0,0,0`
- **Exit**: `exit` or Ctrl+C

## Hardware Requirements

- Raspberry Pi 4B+ (or compatible) with Raspberry Pi OS
- I2C devices (e.g., Arduino with appropriate level shifters)
- Proper I2C wiring with level shifting for voltage compatibility

## Documentation

- [`docs/auto_setup_testing.md`](docs/auto_setup_testing.md) - Automated setup guide
- [`docs/manual_setup_testing.md`](docs/manual_setup_testing.md) - Manual setup and troubleshooting
- [`examples/leader_example.py`](examples/leader_example.py) - Example implementation

## Troubleshooting

Common issues and solutions:

- **Permission errors**: Ensure user is in `i2c` group and reboot if needed
- **Module import errors**: Run from parent directory using `python -m pyCRUMBS.examples.leader_example`
- **I2C detection issues**: Check wiring and use `i2cdetect -y 1` to verify devices

For detailed troubleshooting, see the documentation files above.
