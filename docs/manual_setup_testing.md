# Manual Setup and Testing Guide

This document provides step-by-step manual setup instructions for pyCRUMBS on Raspberry Pi. For a faster automated setup, see [`auto_setup_testing.md`](auto_setup_testing.md).

This setup was tested using a Raspberry Pi 4B+ with the default Raspberry Pi OS Lite 64-bit distribution and an Arduino Nano R3 with a level shifter bridging the two.

## Prerequisites

- Raspberry Pi 4B+ (or compatible) with Raspberry Pi OS Lite 64-bit
- Arduino Nano R3 with level shifter (for I2C communication)
- SSH access to the Raspberry Pi
- Internet connection for downloading packages and repository

## Manual Setup Process

1. **SSH into the Raspberry Pi:**

   From your terminal, connect via SSH:

   ```bash
   ssh username@raspberry_pi_address
   ```

   Accept the host key if prompted and enter your password.

2. **Update the System and Install Prerequisites:**

   Run system update and install required packages:

   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y i2c-tools git python3 python3-venv python3-pip
   ```

3. **Enable I2C:**

   Enable I2C via raspi-config:

   ```bash
   sudo raspi-config
   ```

   Navigate to **Interface Options** → **I2C** and enable it, then reboot if prompted.

4. **Set Up a Python Virtual Environment:**

   In your home directory, create and activate a virtual environment:

   ```bash
   python3 -m venv myenv
   source myenv/bin/activate
   ```

   Install required Python package (smbus2):

   ```bash
   pip install smbus2
   ```

5. **Add User to I2C Group:**

   Add your user to the i2c group for proper permissions:

   ```bash
   sudo adduser $USER i2c
   ```

   Log out and log back in for the changes to take effect.

6. **Clone the pyCRUMBS Repository:**

   Clone repository from GitHub:

   ```bash
   git clone https://github.com/FEASTorg/pyCRUMBS.git
   ```

   Navigate to the repository directory:

   ```bash
   cd pyCRUMBS
   ```

7. **Run the Leader Example:**

   To ensure the package is correctly located, run the example using module notation from the parent directory:

   ```bash
   cd ..
   python -m pyCRUMBS.examples.leader_example
   ```

   You should see the usage instructions and a prompt for commands.

8. **Testing I2C Communication:**

   Verify connected I2C devices with:

   ```bash
   i2cdetect -y 1
   ```

   At the prompt in the leader example, test commands:

   - **Request a Message:** Type, for example: `request,0x08`
   - **Send a Message:** Type, for example: `0x08,1,1,75.0,1.0,0.0,65.0,2.0,7.0,0`

9. **Shutdown:**

   To exit the example, type `exit` or use Ctrl+C.

   Deactivate the virtual environment with:

   ```bash
   deactivate
   ```

## Hardware Requirements

- Raspberry Pi 4B+ (or compatible) with Raspberry Pi OS
- I2C devices (e.g., Arduino with appropriate level shifters)
- Proper I2C wiring with level shifting for voltage compatibility
- Bi-directional level shifter for 5V/3.3V compatibility
- Pull-up resistors (if not provided by hardware)

## Common Issues and Troubleshooting

- **Externally-Managed Environment Error:**

  - **Problem:** When installing Python packages system-wide, pip may display an "externally-managed-environment" error.
  - **Solution:** Create and activate a virtual environment using:

    ```bash
    python3 -m venv myenv
    source myenv/bin/activate
    ```

    This isolates package installations and avoids conflicts with system-managed environments.

- **ModuleNotFoundError:**

  - **Problem:** Running the example script from within the repository directory can trigger a `ModuleNotFoundError` for the `pyCRUMBS` package.
  - **Solution:** Execute the script from the parent directory using:

    ```bash
    python -m pyCRUMBS.examples.leader_example
    ```

    This approach ensures Python correctly locates and recognizes the package structure.

- **I2C Communication Issues:**
  - **Problem:** Receiving input/output errors when making I2C requests (e.g., targeting an inactive or incorrect address).
  - **Solution:** Use `i2cdetect -y 1` to verify that the intended I2C devices are visible on the bus. Double-check wiring, ensure proper voltage level shifting, and confirm that the correct I2C address is being used.
- **Permission and Device Access Problems:**

  - **Problem:** Access to the I2C bus might be denied if the current user does not have sufficient permissions.
  - **Solution:** Ensure the user is part of the `i2c` group or run the commands with appropriate privileges. You can add a user to the `i2c` group using:

    ```bash
    sudo adduser $USER i2c
    ```

    Then, log out and log back in for the changes to take effect.

- **Dependency or Package Version Conflicts:**

  - **Problem:** Conflicts may occur if system packages or outdated versions are present.
  - **Solution:** Use the virtual environment to manage dependencies independently from system packages, and ensure that you are installing the latest stable versions from trusted repositories.

- **Wiring and Hardware Setup:**

  - **Problem:** Incorrect wiring or missing pull-up resistors can lead to unreliable I2C communication.
  - **Solution:** Verify that SDA and SCL lines are correctly connected through a bi-directional level shifter, and that pull-up resistors are in place if not already provided by the hardware.

## Comparison with Automated Setup

For a faster, more reliable setup process, consider using the automated setup script instead:

- **Time:** Manual setup takes 15-20 minutes vs 3-5 minutes for automated
- **Complexity:** Manual setup requires multiple commands vs single script execution
- **Error prone:** Manual steps can be missed vs automated error handling
- **I2C setup:** Manual raspi-config navigation vs fully automated enabling

See [`auto_setup_testing.md`](auto_setup_testing.md) for the automated approach.

## Next Steps

After successful setup, you can:

1. **Develop Custom Applications**: Use the pyCRUMBS library in your own Python scripts
2. **Modify Examples**: Customize the leader example for your specific use case
3. **Add More Devices**: Connect additional I2C devices and test communication
4. **Integrate with Projects**: Use pyCRUMBS as part of larger Raspberry Pi projects

For automated setup and additional troubleshooting, refer to [`auto_setup_testing.md`](auto_setup_testing.md).
