# Development Guide

Guide for contributing to and extending the pyCRUMBS library.

## Development Setup

### Editable Installation

```bash
git clone https://github.com/FEASTorg/pyCRUMBS.git
cd pyCRUMBS
pip install -e . --config-settings editable_mode=compat
```

### Development Tools

```bash
pip install pytest black flake8 mypy sphinx sphinx-rtd-theme
```

## Project Structure

```text
pyCRUMBS/
├── src/pyCRUMBS/           # Main package
│   ├── __init__.py         # Package exports
│   ├── CRUMBS.py          # Main communication class
│   └── CRUMBSMessage.py   # Message dataclass
├── examples/               # Usage examples
├── docs/                   # Documentation
├── tests/                  # Unit tests (to be added)
└── pyproject.toml          # Package configuration
```

## Code Standards

### Style Guidelines

```bash
# Format code
black src/ examples/

# Check style
flake8 src/ examples/

# Type checking
mypy src/
```

### Code Quality

- Follow PEP 8 standards
- Use type hints for all functions
- Document all public APIs with docstrings
- Write unit tests for new functionality
- Maintain backward compatibility

## Testing

### Unit Tests

```bash
# Run tests
pytest tests/

# With coverage
pytest --cov=pyCRUMBS tests/
```

### Hardware Testing

Test with actual Raspberry Pi hardware:

- Raspberry Pi with I2C enabled
- Arduino or compatible I2C device
- Level shifters for voltage conversion
- Proper pull-up resistors

### Mock Testing

```python
from unittest.mock import Mock, patch
from pyCRUMBS import CRUMBS

def test_send_message():
    with patch('smbus2.SMBus') as mock_bus:
        crumbs = CRUMBS()
        crumbs.begin()

        mock_bus.return_value.i2c_rdwr.return_value = None
        result = crumbs.send_message(message, 0x08)

        assert result == True
        mock_bus.return_value.i2c_rdwr.assert_called_once()
```

## Architecture

### Core Design

**CRUMBS Class**:

- Manages SMBus connection lifecycle
- Handles message encoding/decoding
- Provides error handling and logging
- One instance per I2C bus

**CRUMBSMessage Class**:

- Immutable data structure for messages
- Automatic binary encoding/decoding
- Built-in validation

### Design Patterns

- **Resource management**: Explicit begin()/close() lifecycle
- **Error propagation**: Return values and exceptions
- **Immutable messages**: Treat as read-only after creation
- **Type safety**: Comprehensive type hints

## Adding Features

### New Message Types

1. Define constants in CRUMBSMessage.py
2. Add validation logic
3. Update documentation
4. Add usage examples

```python
# Example: Add message type constant
SENSOR_MESSAGE_TYPE = 1
MOTOR_MESSAGE_TYPE = 2
CONFIG_MESSAGE_TYPE = 3
```

### New Communication Patterns

1. Extend CRUMBS class with new methods
2. Maintain backward compatibility
3. Add comprehensive error handling
4. Document usage patterns

```python
def bulk_send(self, messages, addresses):
    """Send multiple messages to multiple devices"""
    results = []
    for msg, addr in zip(messages, addresses):
        results.append(self.send_message(msg, addr))
    return results
```

### Custom Message Classes

```python
class SensorMessage(CRUMBSMessage):
    """Specialized sensor message"""

    def __init__(self, temp=0.0, humidity=0.0):
        super().__init__(
            typeID=1, commandType=0,
            data=[temp, humidity, 0, 0, 0, 0]
        )

    @property
    def temperature(self):
        return self.data[0]

    @property
    def humidity(self):
        return self.data[1]
```

## Contributing

### Development Workflow

1. **Fork**: Fork the repository on GitHub
2. **Branch**: Create feature branch from main
3. **Develop**: Make changes with tests
4. **Test**: Run full test suite
5. **Document**: Update documentation
6. **PR**: Submit pull request

### Pull Request Guidelines

- Clear description of changes
- Tests for new functionality
- Documentation updates
- Code style compliance
- Backward compatibility maintained

### Commit Messages

Use conventional commits format:

```text
feat: add bulk message sending capability
fix: handle I2C timeout errors gracefully
docs: update API reference examples
test: add unit tests for message validation
```

## Release Process

### Version Management

1. Update version in `pyproject.toml`
2. Update `CHANGELOG.md`
3. Create git tag: `git tag v0.2.0`
4. Build package: `python -m build`
5. Upload to PyPI: `twine upload dist/*`

### Documentation

1. Update all documentation files
2. Test code examples
3. Verify links and references
4. Generate API documentation

## Documentation

### Writing Guidelines

- Use clear, concise language
- Include practical examples
- Test all code snippets
- Keep documentation current with code

### Building Docs

```bash
# Install dependencies
pip install sphinx sphinx-rtd-theme

# Build documentation
cd docs
make html
```

## Performance Considerations

### Optimization Areas

1. **Message reuse**: Avoid unnecessary object creation
2. **Connection pooling**: Reuse CRUMBS instances
3. **Batch operations**: Group I2C transactions
4. **Error handling**: Minimize exception overhead

### Profiling

```python
import cProfile
import pstats

def profile_communication():
    # Your code here
    pass

if __name__ == "__main__":
    cProfile.run('profile_communication()', 'profile_stats')
    stats = pstats.Stats('profile_stats')
    stats.sort_stats('cumulative').print_stats(10)
```

## Debugging

### Logging Configuration

```python
import logging

# Enable detailed logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Enable specific loggers
logging.getLogger("pyCRUMBS").setLevel(logging.DEBUG)
```

### Common Issues

- **Thread safety**: CRUMBS is not thread-safe
- **Resource cleanup**: Always call close()
- **Address validation**: Check 0x08-0x77 range
- **Message size**: Always 27 bytes

## See Also

- **[API Reference](api-reference.md)** - Complete API documentation
- **[Examples](examples.md)** - Usage patterns and examples
- **[Getting Started](getting-started.md)** - Basic setup guide
