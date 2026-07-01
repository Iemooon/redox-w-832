# redox-w-832

Porting Redox Wireless Keyboard firmware from Nordic nRF51822/nRF51 to Nordic nRF52832/nRF52.

Initial goals:

- migrate keyboard left/right transmitter firmware to nRF52832
- migrate receiver firmware to nRF52832
- keep Nordic Gazell wireless protocol
- keep UART protocol between receiver and QMK side
- build with nRF5 SDK and GNU Arm Embedded Toolchain
