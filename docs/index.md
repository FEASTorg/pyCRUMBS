# pyCRUMBS Documentation

Python library for I2C communication between Raspberry Pi and Arduino devices using the CRUMBS protocol.

## Quick Start

```bash
git clone https://github.com/FEASTorg/pyCRUMBS.git
cd pyCRUMBS
chmod +x setup_pycrumbs.sh
./setup_pycrumbs.sh
```

Test: `~/activate_pycrumbs.sh` then `python -m pyCRUMBS.examples.leader_example`

## Documentation

- **[Getting Started](getting-started.md)** - Installation and basic usage
- **[API Reference](api-reference.md)** - Complete API documentation
- **[Protocol](protocol.md)** - Message format and encoding details
- **[Examples](examples.md)** - Practical usage examples
- **[Setup](auto-setup-testing.md)** - Installation guides

## Quick Reference

**Basic usage:**

```python
from pyCRUMBS import CRUMBS, CRUMBSMessage

crumbs = CRUMBS()
crumbs.begin()

# Send message
msg = CRUMBSMessage(typeID=1, commandType=1, data=[1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
crumbs.send_message(msg, 0x08)

# Request response
response = crumbs.request_message(0x08)
crumbs.close()
```

**Common issues:**

- Permission errors → `sudo adduser $USER i2c` and reboot
- Import errors → Run from parent directory with `-m pyCRUMBS.examples.leader_example`
- No devices → Check wiring and run `i2cdetect -y 1`
