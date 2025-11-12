# pyCRUMBS

pyCRUMBS is a Python library implementing the CRUMBS protocol for I2C communication on Raspberry Pi. It enables structured message exchange between a Raspberry Pi (master/leader) and Arduino or other microcontroller devices (slaves).

## Features

- **Simple API**: Easy-to-use classes for I2C communication
- **Structured Messages**: 31-byte fixed-format messages with automatic encoding/decoding
- **CRC-8 Integrity**: Matches the embedded firmware's AceCRC configuration for parity checks
- **Cross-Platform**: Compatible with any I2C-enabled Linux system
- **Well Documented**: Complete API documentation and examples

## Quick Start

```python
from pyCRUMBS import CRUMBS, CRUMBSMessage

crumbs = CRUMBS()
crumbs.begin()
message = CRUMBSMessage(
    typeID=1,
    commandType=1,
    data=[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],
)
crumbs.send_message(message, 0x08)
```

## Installation

```bash
git clone https://github.com/FEASTorg/pyCRUMBS.git
cd pyCRUMBS
chmod +x setup_pycrumbs.sh
./setup_pycrumbs.sh
```

The CRUMBS protocol uses a CRC-8 checksum that matches the embedded AceCRC implementation.  
Generate and compile the shared library (once per platform) with:

```bash
python scripts/generate_crc8_c99.py
python scripts/compile_crc8_c99.py
```

## Hardware Requirements

- Raspberry Pi or compatible Linux system with I2C enabled
- I2C bus with 4.7kΩ pull-up resistors on SDA/SCL lines
- Unique addresses (0x08-0x77) for each peripheral device

## Documentation

Complete documentation is available in the [docs](docs/) directory:

- [Getting Started](docs/getting-started.md) - Installation and basic usage
- [API Reference](docs/api-reference.md) - Complete class documentation
- [Protocol Specification](docs/protocol.md) - Message format details
- [Examples](docs/examples.md) - Code examples and patterns

## Examples

The library includes working Python examples:

- **Leader Example**: Interactive interface for sending commands and requesting data

## License

AGPL-3.0 - see [LICENSE](LICENSE) file for details.
