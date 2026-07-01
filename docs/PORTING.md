# Porting Notes

This repository ports the original Redox Wireless nRF51822 firmware to nRF52832-QFAA.

Upstream source repository: https://github.com/mattdibi/redox-w-firmware

Current retained behavior:
- keyboard left/right halves scan the Redox matrix and transmit payloads over Nordic Gazell;
- receiver accepts Gazell payloads and exposes matrix bytes to QMK over UART;
- the original precompiled nRF51/QMK HEX files are kept only as reference artifacts under `precompiled/`.
