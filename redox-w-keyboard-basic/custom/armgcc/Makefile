PROJECT_NAME := redox-w-keyboard-basic

SDK_ROOT ?= /home/ubuntu/toolchains/redox-w-832/nRF5_SDK_17.1.0_ddde560
GNU_INSTALL_ROOT ?= /home/ubuntu/toolchains/redox-w-832/gcc-arm-none-eabi-7-2018-q2-update/bin/
GNU_PREFIX ?= arm-none-eabi
GNU_VERSION ?= 7.3.1

MK := mkdir -p
RM := rm -rf

ifeq ("$(VERBOSE)","1")
NO_ECHO :=
else
NO_ECHO := @
endif

CC      := '$(GNU_INSTALL_ROOT)$(GNU_PREFIX)-gcc'
OBJCOPY := '$(GNU_INSTALL_ROOT)$(GNU_PREFIX)-objcopy'
SIZE    := '$(GNU_INSTALL_ROOT)$(GNU_PREFIX)-size'

OBJECT_DIRECTORY := _build
LISTING_DIRECTORY := $(OBJECT_DIRECTORY)
OUTPUT_BINARY_DIRECTORY := $(OBJECT_DIRECTORY)
BUILD_DIRECTORIES := $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY))

LINKER_SCRIPT := gzll_gcc_nrf52.ld

SRC_COMMON += \
$(SDK_ROOT)/modules/nrfx/mdk/gcc_startup_nrf52.S \
$(SDK_ROOT)/modules/nrfx/mdk/system_nrf52.c \
$(SDK_ROOT)/components/libraries/util/app_util_platform.c \
$(SDK_ROOT)/components/libraries/util/app_error.c \
$(SDK_ROOT)/components/libraries/util/app_error_weak.c \
$(SDK_ROOT)/components/libraries/util/nrf_assert.c \
$(SDK_ROOT)/integration/nrfx/legacy/nrf_drv_clock.c \
$(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_clock.c \
$(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_rtc.c \
$(SDK_ROOT)/modules/nrfx/drivers/src/prs/nrfx_prs.c \
$(SDK_ROOT)/modules/nrfx/soc/nrfx_atomic.c

LIBS += $(SDK_ROOT)/components/proprietary_rf/gzll/gcc/gzll_nrf52_gcc.a

INC_PATHS += -I$(abspath ../../config)
INC_PATHS += -I$(SDK_ROOT)/components
INC_PATHS += -I$(SDK_ROOT)/components/libraries/util
INC_PATHS += -I$(SDK_ROOT)/components/libraries/log
INC_PATHS += -I$(SDK_ROOT)/components/libraries/log/src
INC_PATHS += -I$(SDK_ROOT)/components/libraries/experimental_section_vars
INC_PATHS += -I$(SDK_ROOT)/components/libraries/balloc
INC_PATHS += -I$(SDK_ROOT)/components/libraries/memobj
INC_PATHS += -I$(SDK_ROOT)/components/libraries/strerror
INC_PATHS += -I$(SDK_ROOT)/components/libraries/delay
INC_PATHS += -I$(SDK_ROOT)/components/toolchain/cmsis/include
INC_PATHS += -I$(SDK_ROOT)/components/proprietary_rf/gzll
INC_PATHS += -I$(SDK_ROOT)/components/drivers_nrf/nrf_soc_nosd
INC_PATHS += -I$(SDK_ROOT)/integration/nrfx
INC_PATHS += -I$(SDK_ROOT)/integration/nrfx/legacy
INC_PATHS += -I$(SDK_ROOT)/modules/nrfx
INC_PATHS += -I$(SDK_ROOT)/modules/nrfx/mdk
INC_PATHS += -I$(SDK_ROOT)/modules/nrfx/hal
INC_PATHS += -I$(SDK_ROOT)/modules/nrfx/drivers/include
INC_PATHS += -I$(SDK_ROOT)/components/toolchain/gcc

DEFINES += -DNRF52
DEFINES += -DNRF52832_XXAA
DEFINES += -DNRF52_PAN_74
DEFINES += -DGAZELL_PRESENT
DEFINES += -DBOARD_CUSTOM
DEFINES += -DBSP_DEFINES_ONLY
DEFINES += -DCONFIG_GPIO_AS_PINRESET
DEFINES += -D__HEAP_SIZE=8192
DEFINES += -D__STACK_SIZE=8192

OPT := -O3 -g3

CFLAGS += $(OPT) $(DEFINES)
CFLAGS += -mcpu=cortex-m4 -mthumb -mabi=aapcs --std=gnu99
CFLAGS += -Wall -Werror
CFLAGS += -Wno-unused-function -Wno-unused-variable
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin -fshort-enums

ASMFLAGS += $(OPT) $(DEFINES)
ASMFLAGS += -x assembler-with-cpp
ASMFLAGS += -mcpu=cortex-m4 -mthumb -mabi=aapcs
ASMFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16

LDFLAGS += $(OPT)
LDFLAGS += -mthumb -mabi=aapcs -L$(SDK_ROOT)/modules/nrfx/mdk -T$(LINKER_SCRIPT)
LDFLAGS += -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(LISTING_DIRECTORY)/$(@F:.out=.map)
LDFLAGS += --specs=nano.specs

C_SOURCE_FILE_NAMES = $(notdir $(filter %.c,$(SRC_COMMON)))
ASM_SOURCE_FILE_NAMES = $(notdir $(filter %.S,$(SRC_COMMON)))
C_PATHS = $(sort $(dir $(filter %.c,$(SRC_COMMON))))
ASM_PATHS = $(sort $(dir $(filter %.S,$(SRC_COMMON))))
C_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/,$(C_SOURCE_FILE_NAMES:.c=.o))
ASM_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/,$(ASM_SOURCE_FILE_NAMES:.S=.o))
OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

vpath %.c $(C_PATHS)
vpath %.S $(ASM_PATHS)

.PHONY: default all clean cleanobj flash-left flash-right erase

default: all

all: $(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-left.hex \
     $(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-right.hex

$(BUILD_DIRECTORIES):
	$(MK) $@

$(OBJECT_DIRECTORY)/main-keyboard-left.o: CFLAGS += -DCOMPILE_LEFT
$(OBJECT_DIRECTORY)/main-keyboard-right.o: CFLAGS += -DCOMPILE_RIGHT

$(OBJECT_DIRECTORY)/main-%.o: $(abspath ../../main.c) | $(BUILD_DIRECTORIES)
	@echo Compiling file: $(notdir $<) for $*
	$(NO_ECHO)$(CC) $(CFLAGS) $(INC_PATHS) -c -o $@ $<

$(OBJECT_DIRECTORY)/%.o: %.c | $(BUILD_DIRECTORIES)
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) $(CFLAGS) $(INC_PATHS) -c -o $@ $<

$(OBJECT_DIRECTORY)/%.o: %.S | $(BUILD_DIRECTORIES)
	@echo Assembly file: $(notdir $<)
	$(NO_ECHO)$(CC) $(ASMFLAGS) $(INC_PATHS) -c -o $@ $<

$(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-left.out: $(OBJECTS) $(OBJECT_DIRECTORY)/main-keyboard-left.o
	@echo Linking target: $@
	$(NO_ECHO)$(CC) $(LDFLAGS) $^ $(LIBS) -lc -lnosys -lm -o $@
	$(NO_ECHO)$(SIZE) $@

$(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-right.out: $(OBJECTS) $(OBJECT_DIRECTORY)/main-keyboard-right.o
	@echo Linking target: $@
	$(NO_ECHO)$(CC) $(LDFLAGS) $^ $(LIBS) -lc -lnosys -lm -o $@
	$(NO_ECHO)$(SIZE) $@

$(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-left.hex: $(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-left.out
	@echo Preparing: $@
	$(NO_ECHO)$(OBJCOPY) -O ihex $< $@

$(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-right.hex: $(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-right.out
	@echo Preparing: $@
	$(NO_ECHO)$(OBJCOPY) -O ihex $< $@

clean:
	$(RM) $(BUILD_DIRECTORIES)

cleanobj:
	$(RM) $(BUILD_DIRECTORIES)/*.o

flash-left: $(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-left.hex
	nrfjprog -f nrf52 --program $< --sectorerase
	nrfjprog -f nrf52 --reset

flash-right: $(OUTPUT_BINARY_DIRECTORY)/nrf52832_xxaa-keyboard-right.hex
	nrfjprog -f nrf52 --program $< --sectorerase
	nrfjprog -f nrf52 --reset

erase:
	nrfjprog -f nrf52 --eraseall
