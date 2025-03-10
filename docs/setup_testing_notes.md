# Setup and Testing Steps for pyCRUMBS on Raspberry Pi

This was tested using a Raspberry Pi 4B+ with the default Raspberry Pi OS Lite 64-bit distribution and an Arduino Nano R3 with a level shifter bridging the two.

1. **SSH into the Raspberry Pi:**

   - From terminal connect via SSH:

     ```bash
     ssh username@address
     ```

   - Accept the host key if prompted and enter your password.

2. **Update the System and Enable I2C:**

   - Run system update and install i2c-tools:

     ```bash
     sudo apt-get update
     sudo apt-get install -y i2c-tools
     ```

   - Enable I2C (if not already enabled) via:

     ```bash
     sudo raspi-config
     ```

     (Navigate to **Interface Options** → **I2C** and enable it.)

3. **Set Up a Python Virtual Environment:**

   - In your home directory, create and activate a virtual environment:

     ```bash
     python3 -m venv myenv
     source myenv/bin/activate
     ```

   - Install required Python package (smbus2):

     ```bash
     pip install smbus2
     ```

4. **Install Git (if not already installed):**

   - Install Git using apt:

     ```bash
     sudo apt install git
     ```

5. **Clone the pyCRUMBS Repository:**

   - Clone your repository from GitHub:

     ```bash
     git clone https://github.com/CameronBrooks11/pyCRUMBS.git
     ```

   - Navigate to the repository directory:

     ```bash
     cd pyCRUMBS
     ```

6. **Run the Leader Example:**

   - To ensure the package is correctly located, run the example using module notation from the parent directory:

     ```bash
     cd ..
     python -m pyCRUMBS.examples.leader_example
     ```

   - You should see the usage instructions and a prompt for commands.

7. **Testing I2C Communication:**

   - Verify connected I2C devices with:

     ```bash
     i2cdetect -y 1
     ```

   - At the prompt in the leader example, test commands:
     - **Request a Message:**  
       Type, for example:  
       `request,0x0a`
     - **Send a Message:**  
       Type, for example:  
       `0x0a,1,1,1,0,0,0,0,0,0`

8. **Shutdown:**

   - To exit the example, type `exit` or use Ctrl+C.
   - Deactivate the virtual environment with:

     ```bash
     deactivate
     ```

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
