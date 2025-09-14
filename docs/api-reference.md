# API Reference

Complete API documentation for pyCRUMBS Python library.

## Classes

### CRUMBSMessage

Data structure for CRUMBS protocol messages.

```python
@dataclass
class CRUMBSMessage:
    typeID: int = 0
    commandType: int = 0
    data: List[float] = field(default_factory=lambda: [0.0] * 6)
    errorFlags: int = 0
```

#### Fields

| Field         | Type          | Description             | Range           |
| ------------- | ------------- | ----------------------- | --------------- |
| `typeID`      | `int`         | Message type identifier | 0-255           |
| `commandType` | `int`         | Command type identifier | 0-255           |
| `data`        | `List[float]` | Array of 6 float values | IEEE 754 32-bit |
| `errorFlags`  | `int`         | Error status flags      | 0-255           |

#### Methods

**`__str__() -> str`**

Returns formatted string representation.

```python
msg = CRUMBSMessage(typeID=1, commandType=2, data=[1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
print(str(msg))
# Output: CRUMBSMessage(typeID=1, commandType=2, data=[1.00, 2.00, 3.00, 4.00, 5.00, 6.00], errorFlags=0)
```

### CRUMBS

Main class for I2C communication with CRUMBS devices.

```python
class CRUMBS:
    def __init__(self, bus_number: int = 1):
        """Initialize with I2C bus number (default: 1)"""
```

#### Methods

**`begin() -> None`**

Initialize I2C bus connection. Must be called before communication.

```python
crumbs = CRUMBS()
crumbs.begin()
```

**`send_message(message: CRUMBSMessage, target_address: int) -> bool`**

Send message to I2C device.

- **Parameters:**
  - `message`: CRUMBSMessage to send
  - `target_address`: I2C address (0x08-0x77)
- **Returns:** `True` if successful, `False` otherwise

```python
msg = CRUMBSMessage(typeID=1, commandType=1, data=[1,2,3,4,5,6])
success = crumbs.send_message(msg, 0x08)
```

**`request_message(target_address: int) -> Optional[CRUMBSMessage]`**

Request message from I2C device.

- **Parameters:**
  - `target_address`: I2C address (0x08-0x77)
- **Returns:** `CRUMBSMessage` if successful, `None` otherwise

```python
response = crumbs.request_message(0x08)
if response:
    print(f"Data: {response.data}")
```

**`close() -> None`**

Close I2C bus and release resources.

```python
crumbs.close()
```

#### Properties

**`bus`** - SMBus object or None if not initialized

## Usage Patterns

### Basic Communication

```python
from pyCRUMBS import CRUMBS, CRUMBSMessage

crumbs = CRUMBS()
crumbs.begin()

try:
    # Send message
    msg = CRUMBSMessage(typeID=1, commandType=1, data=[1,2,3,4,5,6])
    if crumbs.send_message(msg, 0x08):
        # Request response
        response = crumbs.request_message(0x08)
        if response:
            print(f"Response: {response}")
finally:
    crumbs.close()
```

### Context Manager

```python
from contextlib import contextmanager

@contextmanager
def crumbs_context(bus_number=1):
    crumbs = CRUMBS(bus_number)
    crumbs.begin()
    try:
        yield crumbs
    finally:
        crumbs.close()

with crumbs_context() as crumbs:
    msg = CRUMBSMessage(typeID=1, commandType=1)
    crumbs.send_message(msg, 0x08)
```

### Error Handling

```python
def safe_communication(crumbs, message, address):
    try:
        if crumbs.send_message(message, address):
            response = crumbs.request_message(address)
            if response and response.errorFlags == 0:
                return response
            elif response:
                print(f"Device error: 0x{response.errorFlags:02X}")
        return None
    except Exception as e:
        print(f"Communication error: {e}")
        return None
```

## Error Handling

### Common Exceptions

- **`Exception`**: General I2C communication errors
- **`OSError`**: I2C device not found or permission issues
- **`ValueError`**: Invalid message format or address

### Error Flags

| Flag            | Value | Description              |
| --------------- | ----- | ------------------------ |
| Invalid command | 0x01  | Command not recognized   |
| Parameter error | 0x02  | Value out of range       |
| Device busy     | 0x04  | Device processing        |
| Hardware error  | 0x08  | Hardware malfunction     |
| Timeout         | 0x10  | Communication timeout    |
| Memory error    | 0x20  | Memory allocation failed |
| Sensor fault    | 0x40  | Sensor malfunction       |
| Critical error  | 0x80  | Critical system failure  |

## Message Format

Messages are exactly 27 bytes:

```text
Byte 0:     typeID (uint8)
Byte 1:     commandType (uint8)
Bytes 2-25: data[0-5] (6 × float32, little-endian)
Byte 26:    errorFlags (uint8)
```

### Encoding/Decoding

Internal encoding uses `struct.pack('<BB6fB', ...)` for little-endian format.

## Performance

### I2C Speed

Default: 100kHz. For higher speed, add to `/boot/firmware/config.txt`:

```bash
dtparam=i2c_arm_baudrate=400000
```

### Frequency Limits

- Theoretical max: ~370 Hz (100kHz I2C)
- Recommended: <100 Hz for reliability
- Consider device processing time

### Resource Management

Always call `close()` to free I2C resources. Use context managers for automatic cleanup.

## Thread Safety

CRUMBS class is **not thread-safe**. Use separate instances per thread or implement locking.

## Compatibility

- **Python:** 3.7+ (3.9+ recommended)
- **Platform:** Raspberry Pi with Raspberry Pi OS
- **Hardware:** 3.3V I2C (use level shifters for 5V devices)
