import logging
from pyCRUMBS import CRUMBS, CRUMBSMessage

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("LeaderExample")


def print_usage():
    print("Usage:")
    print("  To send a message, enter comma-separated values:")
    print(
        "    target_address,typeID,commandType,"
        "data0,data1,data2,data3,data4,data5,data6"
    )
    print("  Example:")
    print("    0x08,1,1,75.0,1.0,0.0,65.0,2.0,7.0,3.14")
    print("")
    print("  To request a message from a target device, type:")
    print("    request,target_address")
    print("  Example:")
    print("    request,0x08")
    print("")
    print("  Type 'exit' to quit.")


def parse_message(input_str: str):
    parts = input_str.split(",")
    if len(parts) != 10:
        logger.error("Incorrect number of fields. Expected 10, got %d.", len(parts))
        return None, None
    try:
        # Parse target address (supports hex and decimal)
        target_address_str = parts[0].strip()
        if target_address_str.lower().startswith("0x"):
            target_address = int(target_address_str, 16)
        else:
            target_address = int(target_address_str)
        typeID = int(parts[1].strip())
        commandType = int(parts[2].strip())
        data = [float(x.strip()) for x in parts[3:10]]
        msg = CRUMBSMessage(typeID=typeID, commandType=commandType, data=data)
        return target_address, msg
    except (ValueError, TypeError) as e:
        logger.error("Failed to parse message: %s", e)
        return None, None


def main():
    bus_number = 1  # Default I2C bus on Raspberry Pi
    crumbs = CRUMBS(bus_number)
    crumbs.begin()

    print("pyCRUMBS Leader Example (Master) Running")
    print_usage()

    while True:
        try:
            line = input("Enter command: ").strip()
            if line.lower() == "exit":
                break
            if line.lower().startswith("request"):
                # Format: request,target_address
                parts = line.split(",")
                if len(parts) != 2:
                    logger.error("Invalid request format.")
                    continue
                target_address_str = parts[1].strip()
                if target_address_str.lower().startswith("0x"):
                    target_address = int(target_address_str, 16)
                else:
                    target_address = int(target_address_str)
                response = crumbs.request_message(target_address)
                if response:
                    print("Received response:")
                    print(response)
                else:
                    print("No valid response received.")
            else:
                target_address, msg = parse_message(line)
                if msg is None or target_address is None:
                    print("Failed to parse message. Please check your input.")
                    continue
                if crumbs.send_message(msg, target_address):
                    print("Message sent successfully.")
                else:
                    print("Failed to send message.")
        except KeyboardInterrupt:
            break
        except (OSError, ValueError, RuntimeError) as e:
            logger.error("Error in main loop: %s", e)

    crumbs.close()
    print("Exiting pyCRUMBS Leader Example.")


if __name__ == "__main__":
    main()
