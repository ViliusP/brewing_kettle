# STM32 heating controller

- Import CMake project (STM32 VS code extension tab);
- ...

## PINS

- B3 - RX to ESP32;
- A15 - TX to ESP32;
- A1 - temperature sensor data;
- ...


## UART Messages

This section describes the structure of UART messages used in the brewing kettle heating system.

The system uses 32-bit (4-byte) UART messages for communication. This fixed size simplifies parsing and ensures consistent data handling. The message is divided into three distinct parts:

- The **First 4 bits (the first byte)** represent the message type.
- **Bits 5 to 8 (the second byte)** represent the message entity.
- **Bits 9 to 32** contain the message content.

### Message type (4 bits)

The first 4 bits (the most significant nibble of the first byte) define the overall category of the message. This allows the receiver to quickly determine how to interpret the rest of the message.

- `0001`(`1`): Indicates a message containing system state information, such as temperature readings;
- `0002`(`2`): Signals an error condition within the system;
- `0003`(`3`): Used for debugging purposes, likely containing diagnostic information;

### Example (temperature reading of 16.0°C)

- `0001` (`0x01` or `1`): message of state type;
- `0001` (`0x01` or `1`): message about temperature;
- `0000 0000 0000 0001 0000 0000` (`0x100` or `256`): current temperature in decimal form (after decoding it need to be by multiplied resolution `0.0625`, e.g. `256*0.0625=16`);
