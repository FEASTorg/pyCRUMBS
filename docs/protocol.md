# Protocol Documentation

CRUMBS protocol specification for I2C communication between Raspberry Pi and Arduino devices.

## Message Structure

### Binary Format

Every CRUMBS message is exactly **27 bytes**:

| Byte(s) | Field         | Type      | Description                         |
| ------- | ------------- | --------- | ----------------------------------- |
| 0       | `typeID`      | uint8     | Message type (0-255)                |
| 1       | `commandType` | uint8     | Command identifier (0-255)          |
| 2-25    | `data[0-5]`   | 6×float32 | Six IEEE 754 floats (little-endian) |
| 26      | `errorFlags`  | uint8     | Error status bits (0-255)           |

### Field Details

#### typeID (Message Types)

| Value | Purpose | Description                    |
| ----- | ------- | ------------------------------ |
| 0     | System  | Status, ping, reset commands   |
| 1     | Sensor  | Sensor data requests/responses |
| 2     | Motor   | Motor control commands         |
| 3     | Config  | Configuration parameters       |
| 4-254 | Custom  | Application-specific types     |
| 255   | Debug   | Debug and diagnostic messages  |

#### commandType (Commands by Type)

**System (typeID=0):**

- 0: Ping/heartbeat
- 1: Status request
- 2: Reset command

**Sensor (typeID=1):**

- 0: Read all sensors
- 1-6: Read specific sensor

**Motor (typeID=2):**

- 0: Emergency stop
- 1: Set motor speeds
- 2: Set directions

#### data[0-5] (Float Array)

Six IEEE 754 32-bit floats in little-endian format. Usage depends on message type:

```python
# Motor control example
data = [
    50.0,   # Motor 1 speed (%)
    75.0,   # Motor 2 speed (%)
    1.0,    # Direction (1=forward, -1=reverse)
    0.0,    # Reserved
    0.0,    # Reserved
    0.0     # Reserved
]

# Sensor data example
data = [
    23.5,   # Temperature (°C)
    45.2,   # Humidity (%)
    1013.8, # Pressure (hPa)
    12.4,   # Voltage (V)
    0.0,    # Reserved
    0.0     # Reserved
]
```

#### errorFlags (Error Bits)

| Bit | Value | Description            |
| --- | ----- | ---------------------- |
| 0   | 0x01  | Invalid command        |
| 1   | 0x02  | Parameter out of range |
| 2   | 0x04  | Device busy            |
| 3   | 0x08  | Hardware error         |
| 4   | 0x10  | Communication timeout  |
| 5   | 0x20  | Memory error           |
| 6   | 0x40  | Sensor fault           |
| 7   | 0x80  | Critical error         |

## Encoding/Decoding

### Python Implementation

```python
import struct

def encode_message(message):
    """Encode CRUMBSMessage to 27-byte binary format"""
    return struct.pack(
        '<BB6fB',           # Little-endian format
        message.typeID,     # uint8
        message.commandType, # uint8
        *message.data,      # 6 × float32
        message.errorFlags  # uint8
    )

def decode_message(data):
    """Decode 27-byte binary to CRUMBSMessage"""
    if len(data) != 27:
        return None

    unpacked = struct.unpack('<BB6fB', data)
    return CRUMBSMessage(
        typeID=unpacked[0],
        commandType=unpacked[1],
        data=list(unpacked[2:8]),
        errorFlags=unpacked[8]
    )
```

### Format String Breakdown

- `<`: Little-endian byte order
- `B`: Unsigned byte (typeID)
- `B`: Unsigned byte (commandType)
- `6f`: Six 32-bit floats (data array)
- `B`: Unsigned byte (errorFlags)

### Byte Order

Protocol uses **little-endian** for cross-platform compatibility:

```python
# Float 1.5 in little-endian
value = 1.5
encoded = struct.pack('<f', value)  # [0x00, 0x00, 0xc0, 0x3f]
```

## I2C Communication

### Master-Slave Pattern

```text
Raspberry Pi (Master)    Arduino (Slave)
        |                       |
        |-- Send (27 bytes) ---->|
        |<-- ACK/NACK ----------|
        |                       |
        |-- Request ------------>|
        |<-- Response (27 bytes)-|
```

### Send Operation

```python
def send_message(bus, message, address):
    """Send message via I2C"""
    data = encode_message(message)
    write_msg = i2c_msg.write(address, data)
    bus.i2c_rdwr(write_msg)
```

### Request Operation

```python
def request_message(bus, address):
    """Request message via I2C"""
    read_msg = i2c_msg.read(address, 27)
    bus.i2c_rdwr(read_msg)
    return decode_message(bytes(read_msg.buf))
```

## Error Handling

### Communication Errors

**Common I2C errors:**

| Error       | Errno | Description           |
| ----------- | ----- | --------------------- |
| Remote I/O  | 121   | Device not responding |
| Device busy | 16    | Device processing     |
| I/O error   | 5     | Communication failure |

```python
try:
    response = crumbs.request_message(address)
except OSError as e:
    if e.errno == 121:
        print("Device not responding")
    elif e.errno == 16:
        print("Device busy")
    else:
        print(f"I2C error: {e}")
```

### Protocol Errors

**Message validation:**

```python
def validate_message(msg):
    if not (0 <= msg.typeID <= 255):
        return False, "Invalid typeID"

    if len(msg.data) != 6:
        return False, "Data must have 6 elements"

    # Check for NaN/infinity
    import math
    for value in msg.data:
        if math.isnan(value) or math.isinf(value):
            return False, "Invalid float value"

    return True, "Valid"
```

**Error flag processing:**

```python
def decode_error_flags(flags):
    errors = []
    if flags & 0x01: errors.append("Invalid command")
    if flags & 0x02: errors.append("Parameter error")
    if flags & 0x04: errors.append("Device busy")
    if flags & 0x08: errors.append("Hardware error")
    if flags & 0x10: errors.append("Timeout")
    if flags & 0x20: errors.append("Memory error")
    if flags & 0x40: errors.append("Sensor fault")
    if flags & 0x80: errors.append("Critical error")
    return errors
```

## Performance

### Timing Analysis

| I2C Speed | Transfer Time | Max Frequency |
| --------- | ------------- | ------------- |
| 100 kHz   | ~2.7 ms       | ~370 Hz       |
| 400 kHz   | ~0.7 ms       | ~1400 Hz      |
| 1 MHz     | ~0.3 ms       | ~3300 Hz      |

**Note:** Actual performance depends on device processing time.

### I2C Configuration

```bash
# Fast mode (400 kHz) - add to /boot/firmware/config.txt
dtparam=i2c_arm_baudrate=400000

# Fast mode plus (1 MHz) - may not work with all devices
dtparam=i2c_arm_baudrate=1000000
```

### Benchmarking

```python
import time

def benchmark_communication(crumbs, address, iterations=100):
    message = CRUMBSMessage(typeID=1, commandType=1, data=[1,2,3,4,5,6])

    # Send benchmark
    start = time.time()
    for _ in range(iterations):
        crumbs.send_message(message, address)
    send_time = time.time() - start

    print(f"Send: {send_time/iterations*1000:.2f}ms average")

    # Request benchmark
    start = time.time()
    for _ in range(iterations):
        crumbs.request_message(address)
    request_time = time.time() - start

    print(f"Request: {request_time/iterations*1000:.2f}ms average")
```

## Advanced Topics

### Custom Message Types

```python
class SensorMessage(CRUMBSMessage):
    """Specialized sensor message"""

    def __init__(self, temp=0.0, humidity=0.0, pressure=0.0):
        super().__init__(
            typeID=1, commandType=0,
            data=[temp, humidity, pressure, 0.0, 0.0, 0.0]
        )

    @property
    def temperature(self):
        return self.data[0]

    @property
    def humidity(self):
        return self.data[1]

    @property
    def pressure(self):
        return self.data[2]
```

### Message Versioning

```python
class VersionedMessage(CRUMBSMessage):
    """Message with protocol version"""

    PROTOCOL_VERSION = 1.0

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.data[5] = self.PROTOCOL_VERSION  # Use last data field
```

### Checksums

```python
def calculate_checksum(data):
    """Simple XOR checksum"""
    checksum = 0
    for byte in data:
        checksum ^= byte
    return checksum & 0xFF

def encode_with_checksum(message):
    """Encode with checksum in errorFlags"""
    base_data = struct.pack('<BB6f', message.typeID, message.commandType, *message.data)
    checksum = calculate_checksum(base_data)
    return base_data + bytes([checksum])
```

## Compatibility

### Cross-Platform

- **Endianness**: Little-endian mandatory for compatibility
- **Float Format**: IEEE 754 32-bit standard
- **Address Range**: 0x08-0x77 (standard I2C)

### Arduino Implementation

```cpp
// Arduino side message structure
struct CRUMBSMessage {
    uint8_t typeID;
    uint8_t commandType;
    float data[6];
    uint8_t errorFlags;
} __attribute__((packed));

// Send message
void sendMessage(CRUMBSMessage& msg) {
    Wire.write((uint8_t*)&msg, sizeof(msg));
}

// Receive message
void receiveMessage(CRUMBSMessage& msg) {
    Wire.readBytes((uint8_t*)&msg, sizeof(msg));
}
```

## See Also

- **[API Reference](api-reference.md)** - Python implementation details
- **[Getting Started](getting-started.md)** - Basic setup and usage
- **[Examples](examples.md)** - Practical usage patterns
