# redox-w-firmware for nrf52832

English | [简体中文](README.zh-CN.md)

Redox Wireless Keyboard firmware port for Nordic nRF52832-QFAA.

This repository ports the original Redox Wireless Keyboard nRF51822/nRF51 firmware to nRF52832/nRF52 while keeping the original architecture:

- left half keyboard transmitter firmware
- right half keyboard transmitter firmware
- USB-side receiver firmware
- Nordic Gazell wireless protocol
- receiver-to-QMK UART protocol

The port is based on nRF5 SDK17.1.0 and GNU Arm Embedded Toolchain. It is intended to build on Ubuntu or WSL without Docker.

## Current build status

The following targets have been verified to build with GCC7 and nRF5 SDK17.1.0:

| Target | Output |
| --- | --- |
| keyboard left | `redox-w-keyboard-basic/custom/armgcc/_build/nrf52832_xxaa-keyboard-left.hex` |
| keyboard right | `redox-w-keyboard-basic/custom/armgcc/_build/nrf52832_xxaa-keyboard-right.hex` |
| receiver | `redox-w-receiver-basic/custom/armgcc/_build/nrf52832_xxaa-receiver.hex` |

Verified size output:

```text
nrf52832_xxaa-receiver.out        text=20224 data=156 bss=1440 dec=21820
nrf52832_xxaa-keyboard-left.out   text=20232 data=140 bss=1168 dec=21540
nrf52832_xxaa-keyboard-right.out  text=20216 data=140 bss=1168 dec=21524
```

## Hardware target

- MCU: Nordic nRF52832-QFAA
- Build macro: `NRF52832_XXAA`
- CPU: Cortex-M4
- ABI: hard-float, `fpv4-sp-d16`
- Flash layout: `0x00000000`, length `0x80000`
- RAM layout: `0x20000000`, length `0x10000`
- SoftDevice: not used
- Wireless stack: Nordic Gazell from nRF5 SDK17.1.0

## Receiver UART protocol

The receiver keeps the original protocol expected by the QMK side:

- QMK polls the receiver with character `s`
- receiver returns 10 matrix bytes
- receiver appends end byte `0xE0`
- UART pins:
  - RX: P0.25
  - TX: P0.24
  - CTS: P0.23
  - RTS: P0.22
- HW flow control: disabled in firmware
- baud rate: 115200

## Dependencies

Install common packages:

```bash
sudo apt update
sudo apt install -y make gcc curl wget unzip python3 git
```

Install GNU Arm Embedded Toolchain 7-2018-q2-update. This version has been verified for the port:

```bash
mkdir -p ~/toolchains/redox-w-832
cd ~/toolchains/redox-w-832
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2
tar -xf gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2
```

Install nRF5 SDK17.1.0:

```bash
cd ~/toolchains/redox-w-832
wget https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v17.x.x/nRF5_SDK_17.1.0_ddde560.zip
unzip nRF5_SDK_17.1.0_ddde560.zip
```

Set environment variables:

```bash
export REDOX_NRF5_SDK=$HOME/toolchains/redox-w-832/nRF5_SDK_17.1.0_ddde560
export REDOX_GNU_INSTALL_ROOT=$HOME/toolchains/redox-w-832/gcc-arm-none-eabi-7-2018-q2-update
export PATH=$REDOX_GNU_INSTALL_ROOT/bin:$PATH
```

Optional check:

```bash
arm-none-eabi-gcc --version
ls "$REDOX_NRF5_SDK/components/proprietary_rf/gzll/gcc/gzll_nrf52_gcc.a"
```

The Gazell library is required. The expected SDK file is:

```text
$REDOX_NRF5_SDK/components/proprietary_rf/gzll/gcc/gzll_nrf52_gcc.a
```

## Build

Clone the repository:

```bash
git clone https://github.com/Iemooon/redox-w-832.git
cd redox-w-832
```

Build all firmware targets:

```bash
make clean
make all
```

Or build targets separately:

```bash
make -C redox-w-keyboard-basic/custom/armgcc clean all
make -C redox-w-receiver-basic/custom/armgcc clean all
```

Expected outputs:

```text
redox-w-keyboard-basic/custom/armgcc/_build/nrf52832_xxaa-keyboard-left.hex
redox-w-keyboard-basic/custom/armgcc/_build/nrf52832_xxaa-keyboard-right.hex
redox-w-receiver-basic/custom/armgcc/_build/nrf52832_xxaa-receiver.hex
```

## Flashing

Install Nordic nRF Command Line Tools on the host machine to get `nrfjprog` and SEGGER J-Link tools.

Nordic download page:

```text
https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools
```

After installation, confirm:

```bash
nrfjprog --version
JLinkExe -version
```

Flash keyboard left:

```bash
cd redox-w-keyboard-basic
./program_left.sh
```

Flash keyboard right:

```bash
cd redox-w-keyboard-basic
./program_right.sh
```

Flash receiver:

```bash
cd redox-w-receiver-basic
./program.sh
```

The scripts use `nrfjprog` to recover, program, verify, and reset the connected nRF52832 device.

## Test flow

1. Build all three targets and confirm the three `.hex` files exist.
2. Flash `nrf52832_xxaa-keyboard-left.hex` to the left keyboard half.
3. Flash `nrf52832_xxaa-keyboard-right.hex` to the right keyboard half.
4. Flash `nrf52832_xxaa-receiver.hex` to the receiver board.
5. Connect the receiver UART pins to the QMK side using the original pin mapping.
6. Confirm the QMK side can poll with `s` and receive 10 matrix bytes followed by `0xE0`.
7. Test left and right key matrix events separately before testing full keyboard usage.

## Porting notes

Major nRF52/SDK17 changes in this port:

- switched MCU macro from `nRF51822_xxAC` to `NRF52832_XXAA`
- switched startup/system files to SDK17 nRF52 MDK files
- switched Gazell static library to `gzll_nrf52_gcc.a`
- updated linker scripts for nRF52832-QFAA flash and RAM
- kept the legacy `nrf_drv_rtc.h` API but builds SDK17 `nrfx_rtc.c`
- kept receiver `app_uart` flow and sends matrix bytes using `app_uart_put()`
- added SDK17 minimal `sdk_config.h` files for keyboard and receiver
- avoided SDK11-only files that no longer exist in SDK17

## Troubleshooting

`fatal error: sdk_config.h: No such file or directory`

- Confirm `redox-w-keyboard-basic/config/sdk_config.h` and `redox-w-receiver-basic/config/sdk_config.h` exist.

`gzll_nrf52_gcc.a: No such file or directory`

- Confirm `REDOX_NRF5_SDK` points to nRF5 SDK17.1.0 and the Gazell library exists under `components/proprietary_rf/gzll/gcc/`.

`arm-none-eabi-gcc: command not found`

- Confirm `REDOX_GNU_INSTALL_ROOT` is set and `$REDOX_GNU_INSTALL_ROOT/bin` is in `PATH`.

`nrfjprog: command not found`

- Install Nordic nRF Command Line Tools. This is only required for flashing, not for building.

## Original project

This port is based on the original Redox Wireless Keyboard firmware:

```text
https://github.com/mattdibi/redox-w-firmware
```

Original README is preserved at:

```text
vendor/original/README.redox-w-firmware.md
```
