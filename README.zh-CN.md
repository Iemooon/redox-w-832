# redox-w-firmware for nrf52832

[English](README.md) | 简体中文

Redox无线键盘nRF52832-QFAA固件移植版。

本仓库将原Redox Wireless Keyboard的nRF51822/nRF51固件移植到nRF52832/nRF52，并保留原有架构：

- 左手键盘发射端固件
- 右手键盘发射端固件
- USB侧接收器固件
- Nordic Gazell无线协议
- 接收器到QMK侧的UART协议

本移植基于nRF5 SDK17.1.0和GNU Arm Embedded Toolchain，可在Ubuntu或WSL环境下直接编译，不使用Docker。

## 当前编译状态

以下目标已使用GCC7和nRF5 SDK17.1.0验证通过：

| 目标 | 输出文件 |
| --- | --- |
| 左手键盘 | `redox-w-keyboard-basic/custom/armgcc/_build/nrf52832_xxaa-keyboard-left.hex` |
| 右手键盘 | `redox-w-keyboard-basic/custom/armgcc/_build/nrf52832_xxaa-keyboard-right.hex` |
| 接收器 | `redox-w-receiver-basic/custom/armgcc/_build/nrf52832_xxaa-receiver.hex` |

已验证的size输出：

```text
nrf52832_xxaa-receiver.out        text=20224 data=156 bss=1440 dec=21820
nrf52832_xxaa-keyboard-left.out   text=20232 data=140 bss=1168 dec=21540
nrf52832_xxaa-keyboard-right.out  text=20216 data=140 bss=1168 dec=21524
```

## 硬件目标

- MCU：Nordic nRF52832-QFAA
- 编译宏：`NRF52832_XXAA`
- CPU：Cortex-M4
- ABI：hard-float，`fpv4-sp-d16`
- Flash布局：`0x00000000`，长度`0x80000`
- RAM布局：`0x20000000`，长度`0x10000`
- SoftDevice：不使用
- 无线协议栈：nRF5 SDK17.1.0中的Nordic Gazell

## 接收器UART协议

接收器保留原QMK侧所需协议：

- QMK发送字符`s`轮询接收器
- 接收器返回10字节矩阵数据
- 接收器追加结束字节`0xE0`
- UART引脚：
  - RX：P0.25
  - TX：P0.24
  - CTS：P0.23
  - RTS：P0.22
- 固件中关闭硬件流控
- 波特率：115200

## 依赖安装

安装基础工具：

```bash
sudo apt update
sudo apt install -y make gcc curl wget unzip python3 git
```

安装GNU Arm Embedded Toolchain 7-2018-q2-update。本版本已通过移植验证：

```bash
mkdir -p ~/toolchains/redox-w-832
cd ~/toolchains/redox-w-832
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2
tar -xf gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2
```

安装nRF5 SDK17.1.0：

```bash
cd ~/toolchains/redox-w-832
wget https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v17.x.x/nRF5_SDK_17.1.0_ddde560.zip
unzip nRF5_SDK_17.1.0_ddde560.zip
```

设置环境变量：

```bash
export REDOX_NRF5_SDK=$HOME/toolchains/redox-w-832/nRF5_SDK_17.1.0_ddde560
export REDOX_GNU_INSTALL_ROOT=$HOME/toolchains/redox-w-832/gcc-arm-none-eabi-7-2018-q2-update
export PATH=$REDOX_GNU_INSTALL_ROOT/bin:$PATH
```

可选检查：

```bash
arm-none-eabi-gcc --version
ls "$REDOX_NRF5_SDK/components/proprietary_rf/gzll/gcc/gzll_nrf52_gcc.a"
```

Gazell库是必需文件。预期SDK文件路径为：

```text
$REDOX_NRF5_SDK/components/proprietary_rf/gzll/gcc/gzll_nrf52_gcc.a
```

## 编译

克隆仓库：

```bash
git clone https://github.com/Iemooon/redox-w-832.git
cd redox-w-832
```

编译全部固件目标：

```bash
make clean
make all
```

也可以分别编译：

```bash
make -C redox-w-keyboard-basic/custom/armgcc clean all
make -C redox-w-receiver-basic/custom/armgcc clean all
```

预期输出：

```text
redox-w-keyboard-basic/custom/armgcc/_build/nrf52832_xxaa-keyboard-left.hex
redox-w-keyboard-basic/custom/armgcc/_build/nrf52832_xxaa-keyboard-right.hex
redox-w-receiver-basic/custom/armgcc/_build/nrf52832_xxaa-receiver.hex
```

## 烧录

在主机安装Nordic nRF Command Line Tools，以获得`nrfjprog`和SEGGER J-Link工具。

Nordic下载页面：

```text
https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools
```

安装后确认：

```bash
nrfjprog --version
JLinkExe -version
```

烧录左手键盘：

```bash
cd redox-w-keyboard-basic
./program_left.sh
```

烧录右手键盘：

```bash
cd redox-w-keyboard-basic
./program_right.sh
```

烧录接收器：

```bash
cd redox-w-receiver-basic
./program.sh
```

脚本会调用`nrfjprog`对连接的nRF52832设备执行recover、program、verify和reset。

## 测试流程

1. 编译全部三个目标，确认三个`.hex`文件存在。
2. 将`nrf52832_xxaa-keyboard-left.hex`烧录到左手键盘。
3. 将`nrf52832_xxaa-keyboard-right.hex`烧录到右手键盘。
4. 将`nrf52832_xxaa-receiver.hex`烧录到接收器。
5. 按原引脚映射连接接收器UART与QMK侧。
6. 确认QMK侧可发送`s`轮询，并收到10字节矩阵数据加`0xE0`结束字节。
7. 先分别测试左右手键盘矩阵事件，再测试完整键盘使用。

## 移植说明

本次nRF52/SDK17移植的主要变化：

- MCU宏从`nRF51822_xxAC`切换为`NRF52832_XXAA`
- 启动文件和system文件切换为SDK17 nRF52 MDK文件
- Gazell静态库切换为`gzll_nrf52_gcc.a`
- 链接脚本更新为nRF52832-QFAA的Flash和RAM布局
- 保留legacy `nrf_drv_rtc.h` API，但编译SDK17中的`nrfx_rtc.c`
- 保留接收器`app_uart`流程，矩阵数据通过`app_uart_put()`发送
- 为键盘和接收器新增SDK17最小化`sdk_config.h`
- 避免继续引用SDK17中已不存在的SDK11文件

## 常见问题

`fatal error: sdk_config.h: No such file or directory`

- 确认`redox-w-keyboard-basic/config/sdk_config.h`和`redox-w-receiver-basic/config/sdk_config.h`存在。

`gzll_nrf52_gcc.a: No such file or directory`

- 确认`REDOX_NRF5_SDK`指向nRF5 SDK17.1.0，并且Gazell库存在于`components/proprietary_rf/gzll/gcc/`目录下。

`arm-none-eabi-gcc: command not found`

- 确认已设置`REDOX_GNU_INSTALL_ROOT`，并将`$REDOX_GNU_INSTALL_ROOT/bin`加入`PATH`。

`nrfjprog: command not found`

- 安装Nordic nRF Command Line Tools。该工具只用于烧录，不影响编译。

## 原项目

本移植基于原Redox Wireless Keyboard固件：

```text
https://github.com/mattdibi/redox-w-firmware
```

原README保存在：

```text
vendor/original/README.redox-w-firmware.md
```
