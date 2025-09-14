# Manual Setup Guide

Step-by-step manual setup for pyCRUMBS on Raspberry Pi. For faster setup, see [Automated Setup](auto-setup-testing.md).

## Prerequisites

- Raspberry Pi 4B+ with Raspberry Pi OS Lite 64-bit
- SSH access and internet connection
- Arduino with level shifter for I2C (optional for testing)

## Manual Setup Steps

### 1. System Update and Packages

```bash
ssh username@raspberry_pi_address
sudo apt update && sudo apt upgrade -y
sudo apt install -y i2c-tools git python3 python3-venv python3-pip
```

### 2. Enable I2C

```bash
sudo raspi-config
```

Navigate: **Interface Options** → **I2C** → **Enable** → **Reboot**

### 3. Python Virtual Environment

```bash
python3 -m venv pycrumbs_env
source pycrumbs_env/bin/activate
pip install smbus2
```

### 4. User Permissions

```bash
sudo adduser $USER i2c
```

Log out and back in for changes to take effect.

### 5. Clone Repository

```bash
git clone https://github.com/FEASTorg/pyCRUMBS.git
cd pyCRUMBS
```

### 6. Test Installation

```bash
# From parent directory
cd ..
python -m pyCRUMBS.examples.leader_example
```

### 7. Verify I2C Devices

```bash
i2cdetect -y 1
```

## Testing Commands

In the leader example:

- **Request message**: `request,0x08`
- **Send message**: `0x08,1,1,75.0,1.0,0.0,65.0,2.0,7.0,0`
- **Exit**: `exit` or Ctrl+C

## Common Issues

### Externally-Managed Environment Error

**Problem**: Pip shows "externally-managed-environment" error.

**Solution**: Use virtual environment:

```bash
python3 -m venv pycrumbs_env
source pycrumbs_env/bin/activate
pip install smbus2
```

### ModuleNotFoundError

**Problem**: Cannot import pyCRUMBS module.

**Solutions**:

1. Run from parent directory: `python -m pyCRUMBS.examples.leader_example`
2. Ensure virtual environment is activated
3. Install in editable mode: `pip install -e .`

### I2C Communication Errors

**Problem**: Input/output errors when accessing I2C devices.

**Solutions**:

1. Check device connections and wiring
2. Verify I2C is enabled: `lsmod | grep i2c`
3. Scan for devices: `i2cdetect -y 1`
4. Check address is correct (0x08-0x77 range)
5. Ensure level shifters for 5V devices

### Permission Denied

**Problem**: Access denied to I2C bus.

**Solutions**:

1. Add user to i2c group: `sudo adduser $USER i2c`
2. Log out and back in
3. Check group membership: `groups $USER`
4. Run with sudo as temporary workaround

### Wiring Issues

**Problem**: Devices not detected or unreliable communication.

**Solutions**:

1. Verify SDA/SCL connections through level shifter
2. Check power connections (3.3V/5V and GND)
3. Add pull-up resistors if not present (4.7kΩ recommended)
4. Test with shorter wires
5. Check for loose connections

## Hardware Requirements

- **Raspberry Pi**: 4B+ or compatible with Raspberry Pi OS
- **Level Shifter**: Bi-directional for 5V devices
- **Wiring**: SDA/SCL with proper voltage levels
- **Pull-ups**: 4.7kΩ resistors (if not built-in)

## Comparison with Automated Setup

| Aspect             | Manual                 | Automated                     |
| ------------------ | ---------------------- | ----------------------------- |
| **Time**           | 15-20 minutes          | 3-5 minutes                   |
| **I2C Setup**      | Manual raspi-config    | Automatic detection           |
| **Error Handling** | Manual troubleshooting | Built-in error recovery       |
| **Environment**    | Manual creation        | Automatic with validation     |
| **Dependencies**   | Manual installation    | Automatic with error checking |

## Next Steps

1. **Test Communication**: Use leader example with actual hardware
2. **Develop Applications**: Create custom scripts using pyCRUMBS
3. **Advanced Usage**: Review [Examples](examples.md) for patterns
4. **API Reference**: See [API Reference](api-reference.md) for details

For automated setup that handles these steps automatically, see [Automated Setup Guide](auto-setup-testing.md).
