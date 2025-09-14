# Examples and Usage Patterns

Practical examples demonstrating pyCRUMBS usage patterns for I2C communication.

## Leader Example

The included `leader_example.py` demonstrates interactive I2C communication:

```bash
# Run the example
~/activate_pycrumbs.sh
python -m pyCRUMBS.examples.leader_example
```

**Commands:**

- Send: `0x08,1,1,75.0,1.0,0.0,65.0,2.0,7.0,0`
- Request: `request,0x08`
- Exit: `exit`

## Basic Examples

### Simple Send/Receive

```python
from pyCRUMBS import CRUMBS, CRUMBSMessage
import time

def basic_communication():
    crumbs = CRUMBS()
    try:
        crumbs.begin()

        # Send message
        message = CRUMBSMessage(
            typeID=1, commandType=1,
            data=[25.5, 50.0, 75.5, 100.0, 0.0, 0.0]
        )

        if crumbs.send_message(message, 0x08):
            time.sleep(0.1)  # Wait for processing
            response = crumbs.request_message(0x08)
            if response:
                print(f"Response: {response.data}")
    finally:
        crumbs.close()
```

### Device Scanner

```python
def scan_devices():
    crumbs = CRUMBS()
    crumbs.begin()

    found = []
    for addr in range(0x08, 0x78):
        try:
            if crumbs.request_message(addr):
                found.append(addr)
                print(f"Device at 0x{addr:02X}")
        except:
            pass

    crumbs.close()
    return found
```

## Advanced Patterns

### Multi-Device Manager

```python
class DeviceManager:
    def __init__(self):
        self.crumbs = CRUMBS()
        self.devices = {}  # address -> device_info

    def add_device(self, address, name):
        self.devices[address] = {'name': name, 'last_contact': None}

    def poll_all(self):
        results = {}
        for address, info in self.devices.items():
            try:
                response = self.crumbs.request_message(address)
                results[address] = response
                info['last_contact'] = time.time()
            except:
                results[address] = None
        return results

    def start(self):
        self.crumbs.begin()

    def stop(self):
        self.crumbs.close()

# Usage
manager = DeviceManager()
manager.add_device(0x08, "Sensor Array")
manager.add_device(0x09, "Motor Controller")
manager.start()

results = manager.poll_all()
for addr, response in results.items():
    if response:
        print(f"Device 0x{addr:02X}: {response.data}")

manager.stop()
```

### Data Logger

```python
import csv
from datetime import datetime

class DataLogger:
    def __init__(self, log_file="data.csv"):
        self.crumbs = CRUMBS()
        self.log_file = log_file

    def log_device(self, address, duration=60):
        self.crumbs.begin()

        with open(self.log_file, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['timestamp', 'address', 'data0', 'data1', 'data2', 'data3', 'data4', 'data5'])

            start_time = time.time()
            while time.time() - start_time < duration:
                response = self.crumbs.request_message(address)
                if response:
                    row = [datetime.now().isoformat(), f"0x{address:02X}"] + response.data
                    writer.writerow(row)
                time.sleep(1)

        self.crumbs.close()

# Usage
logger = DataLogger("sensor_log.csv")
logger.log_device(0x08, duration=300)  # Log for 5 minutes
```

### Real-Time Control

```python
import threading
import queue

class ControlSystem:
    def __init__(self):
        self.crumbs = CRUMBS()
        self.command_queue = queue.Queue()
        self.running = False

    def add_command(self, address, message):
        self.command_queue.put((address, message))

    def control_loop(self):
        while self.running:
            try:
                address, message = self.command_queue.get(timeout=0.1)
                self.crumbs.send_message(message, address)

                # Get feedback
                response = self.crumbs.request_message(address)
                if response and response.errorFlags != 0:
                    print(f"Device 0x{address:02X} error: {response.errorFlags}")

            except queue.Empty:
                continue

    def start(self):
        self.crumbs.begin()
        self.running = True
        self.thread = threading.Thread(target=self.control_loop)
        self.thread.start()

    def stop(self):
        self.running = False
        self.thread.join()
        self.crumbs.close()

# Usage
controller = ControlSystem()
controller.start()

# Send motor command
motor_cmd = CRUMBSMessage(typeID=2, commandType=1, data=[50, 0, 0, 0, 0, 0])
controller.add_command(0x09, motor_cmd)

time.sleep(5)
controller.stop()
```

## Error Handling Patterns

### Robust Communication

```python
from enum import Enum

class CommResult(Enum):
    SUCCESS = "success"
    TIMEOUT = "timeout"
    NO_RESPONSE = "no_response"
    DEVICE_ERROR = "device_error"

def robust_send(crumbs, message, address, retries=3):
    for attempt in range(retries):
        try:
            if crumbs.send_message(message, address):
                return CommResult.SUCCESS
            time.sleep(0.1 * (attempt + 1))  # Exponential backoff
        except Exception as e:
            if attempt == retries - 1:
                return CommResult.TIMEOUT
    return CommResult.TIMEOUT

def robust_request(crumbs, address, retries=3):
    for attempt in range(retries):
        try:
            response = crumbs.request_message(address)
            if response is None:
                if attempt < retries - 1:
                    time.sleep(0.1)
                    continue
                return CommResult.NO_RESPONSE, None

            if response.errorFlags != 0:
                return CommResult.DEVICE_ERROR, response

            return CommResult.SUCCESS, response
        except Exception:
            if attempt < retries - 1:
                time.sleep(0.1)

    return CommResult.TIMEOUT, None
```

### Message Validation

```python
def validate_message(message):
    """Validate message before sending"""
    if not isinstance(message, CRUMBSMessage):
        return False, "Not a CRUMBSMessage"

    if not (0 <= message.typeID <= 255):
        return False, f"Invalid typeID: {message.typeID}"

    if len(message.data) != 6:
        return False, f"Data must have 6 elements"

    # Check for NaN/infinity
    import math
    for i, value in enumerate(message.data):
        if math.isnan(value) or math.isinf(value):
            return False, f"Invalid data[{i}]: {value}"

    return True, "Valid"

# Usage
valid, error = validate_message(message)
if not valid:
    print(f"Message validation failed: {error}")
```

## Integration Examples

### Web Interface

```python
from flask import Flask, jsonify, request

app = Flask(__name__)
crumbs = CRUMBS()
crumbs.begin()

@app.route('/send', methods=['POST'])
def send_command():
    data = request.json
    message = CRUMBSMessage(
        typeID=data['typeID'],
        commandType=data['commandType'],
        data=data['data']
    )

    success = crumbs.send_message(message, data['address'])
    return jsonify({'success': success})

@app.route('/request/<int:address>')
def request_data(address):
    response = crumbs.request_message(address)
    if response:
        return jsonify({
            'data': response.data,
            'typeID': response.typeID,
            'commandType': response.commandType,
            'errorFlags': response.errorFlags
        })
    return jsonify({'error': 'No response'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

## Message Type Examples

### Sensor Reading

```python
# Request all sensors
sensor_request = CRUMBSMessage(typeID=1, commandType=0)

# Typical sensor response
# data[0] = temperature (°C)
# data[1] = humidity (%)
# data[2] = pressure (hPa)
```

### Motor Control

```python
# Motor speed control
motor_cmd = CRUMBSMessage(
    typeID=2, commandType=1,
    data=[speed1, speed2, 0, 0, 0, 0]  # Two motor speeds
)

# Emergency stop
stop_cmd = CRUMBSMessage(
    typeID=2, commandType=0,
    data=[0, 0, 0, 0, 0, 0]  # All zeros
)
```

### Configuration

```python
# Set parameters
config_cmd = CRUMBSMessage(
    typeID=3, commandType=1,
    data=[param1, param2, param3, 0, 0, 0]
)
```

## Best Practices

1. **Resource Management**: Always use `try/finally` or context managers
2. **Error Handling**: Check return values and error flags
3. **Timing**: Allow processing time between send/request
4. **Validation**: Validate messages before sending
5. **Logging**: Use logging for debugging and monitoring
6. **Retry Logic**: Implement retries for unreliable connections
7. **Threading**: Use separate CRUMBS instances per thread

## Performance Tips

- Reuse message objects to reduce allocations
- Use appropriate delays between operations
- Consider I2C speed settings for your application
- Monitor device response times
- Implement connection pooling for multiple devices

## See Also

- **[API Reference](api-reference.md)** - Complete class documentation
- **[Protocol Details](protocol.md)** - Message format specification
- **[Getting Started](getting-started.md)** - Basic setup and usage
