import struct
import logging
from smbus2 import SMBus, i2c_msg
from .CRUMBSMessage import CRUMBSMessage

# Set up logging (similar to CRUMBS_DEBUG macros)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("pyCRUMBS")

# Constants
TWI_CLOCK_FREQ = 100000  # Documentational; not used in Python.
CRUMBS_MESSAGE_SIZE = 27  # 1 + 1 + (6 * 4) + 1


class CRUMBS:
    """
    CRUMBS library implementation for Raspberry Pi as I2C master.
    """

    def __init__(self, bus_number: int = 1):
        """
        Initialize the CRUMBS instance.
        :param bus_number: The I2C bus number (usually 1 on a Raspberry Pi).
        """
        self.bus_number = bus_number
        self.bus: SMBus = None

    def begin(self):
        """
        Opens the I2C bus.
        """
        self.bus = SMBus(self.bus_number)
        logger.info("I2C bus %d opened as master.", self.bus_number)

    def encode_message(self, message: CRUMBSMessage) -> bytes:
        """
        Encodes a CRUMBSMessage into bytes.
        :param message: The message to encode.
        :return: A bytes object of size 27.
        """
        try:
            # Little-endian format: two unsigned bytes, 6 floats, and one unsigned byte.
            encoded = struct.pack(
                "<BB6fB",
                message.typeID,
                message.commandType,
                *message.data,
                message.errorFlags
            )
            logger.debug("Encoded message: %s", encoded.hex())
            return encoded
        except struct.error as e:
            logger.error("Encoding error: %s", e)
            return bytes()

    def decode_message(self, buffer: bytes) -> CRUMBSMessage:
        """
        Decodes a bytes object into a CRUMBSMessage.
        :param buffer: The bytes buffer (must be at least 27 bytes).
        :return: The decoded CRUMBSMessage.
        """
        if len(buffer) < CRUMBS_MESSAGE_SIZE:
            logger.error(
                "Buffer size too small for decoding. Received %d bytes.", len(buffer)
            )
            return None
        try:
            unpacked = struct.unpack("<BB6fB", buffer[:CRUMBS_MESSAGE_SIZE])
            msg = CRUMBSMessage(
                typeID=unpacked[0],
                commandType=unpacked[1],
                data=list(unpacked[2:8]),
                errorFlags=unpacked[8],
            )
            logger.debug("Decoded message: %s", msg)
            return msg
        except struct.error as e:
            logger.error("Decoding error: %s", e)
            return None

    def send_message(self, message: CRUMBSMessage, target_address: int):
        """
        Sends a CRUMBSMessage to the specified I2C target address.
        :param message: The message to send.
        :param target_address: I2C address of the target device.
        """
        encoded = self.encode_message(message)
        if len(encoded) != CRUMBS_MESSAGE_SIZE:
            logger.error(
                "Encoded message size mismatch. Expected %d bytes, got %d.",
                CRUMBS_MESSAGE_SIZE,
                len(encoded),
            )
            return
        try:
            # Create an I2C write message with the raw bytes.
            write = i2c_msg.write(target_address, encoded)
            self.bus.i2c_rdwr(write)
            logger.info("Message sent to address 0x%02X", target_address)
        except Exception as e:
            logger.error("Failed to send message: %s", e)

    def request_message(self, target_address: int) -> CRUMBSMessage:
        """
        Requests a CRUMBSMessage from the specified I2C target address.
        :param target_address: The I2C address of the target device.
        :return: The received CRUMBSMessage, or None on failure.
        """
        try:
            read = i2c_msg.read(target_address, CRUMBS_MESSAGE_SIZE)
            self.bus.i2c_rdwr(read)
            buffer = bytes(list(read))
            logger.info(
                "Received %d bytes from address 0x%02X", len(buffer), target_address
            )
            return self.decode_message(buffer)
        except Exception as e:
            logger.error("Failed to request message: %s", e)
            return None

    def close(self):
        """
        Closes the I2C bus.
        """
        if self.bus:
            self.bus.close()
            logger.info("I2C bus closed.")
