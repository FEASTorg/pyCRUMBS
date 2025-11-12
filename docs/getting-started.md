# Getting Started with pyCRUMBS

pyCRUMBS enables I2C communication between Raspberry Pi and Arduino devices using a structured 31-byte message protocol that now includes a CRC-8 checksum for each frame.

## Installation

### Automated Setup (Recommended)

```bash
git clone https://github.com/FEASTorg/pyCRUMBS.git
cd pyCRUMBS
chmod +x setup_pycrumbs.sh
./setup_pycrumbs.sh
```

**Test:** `~/test_pycrumbs.sh`

### Manual Setup

See [Manual Setup Guide](manual-setup-testing.md).

### Development

```bash
pip install -e . --config-settings editable_mode=compat
```

## Basic Usage

```python
from pyCRUMBS import CRUMBS, CRUMBSMessage

crumbs = CRUMBS()
crumbs.begin()

# Send message
message = CRUMBSMessage(
    typeID=1,
    commandType=1,
    data=[25.5, 50.0, 75.5, 100.0, 0.0, 0.0, 0.0],
)
crumbs.send_message(message, 0x08)

# Request response
response = crumbs.request_message(0x08)
if response:
    print(f"Data: {response.data}")

crumbs.close()
```

## Message Format

| Field         | Type          | Description            | Range    |
| ------------- | ------------- | ---------------------- | -------- |
| `typeID`      | `int`         | Message type           | 0-255    |
| `commandType` | `int`         | Command ID             | 0-255    |
| `data`        | `List[float]` | Seven floats (payload) | IEEE 754 |
| `crc8`        | `int`         | CRC-8 checksum         | 0-255    |

The library automatically calculates and appends the CRC when sending messages. The `crc8` field is exposed so received frames can report the checksum that was validated.

## CRC-8 Support

To build the optional native CRC-8 helper (recommended for performance), generate and compile the shared library from the project root:

```bash
python scripts/generate_crc8_c99.py
python scripts/compile_crc8_c99.py
```

If the compiled library is unavailable, pyCRUMBS falls back to a pure-Python CRC implementation at runtime.

## Hardware

### Wiring

```text
Pi GPIO 2/3  Level Shifter  Arduino A4/A5
3.3V/5V/GND  Level Shifter  Arduino VCC/GND
```

### Addresses

- Valid: 0x08-0x77
- Arduino: `Wire.begin(0x08);`

## Troubleshooting

**Permission errors:** `sudo adduser $USER i2c && sudo reboot`

**No devices:** `i2cdetect -y 1`

**Import errors:** Run from parent dir: `python -m pyCRUMBS.examples.leader_example`

**Debug:** `logging.basicConfig(level=logging.DEBUG)`

## Error Handling

```python
try:
    if crumbs.send_message(message, address):
        response = crumbs.request_message(address)
        if response and response.errorFlags == 0:
            return response.data
except Exception as e:
    print(f"Error: {e}")
```

## Resource Management

```python
from contextlib import contextmanager

@contextmanager
def crumbs_connection():
    crumbs = CRUMBS()
    try:
        crumbs.begin()
        yield crumbs
    finally:
        crumbs.close()

with crumbs_connection() as crumbs:
    # Use crumbs here
    pass
```

## Next Steps

- **[API Reference](api-reference.md)** - Complete documentation
- **[Protocol Details](protocol.md)** - Message encoding
- **[Examples](examples.md)** - Advanced patterns
