SDK_ROOT ?= $(REDOX_NRF5_SDK)
GNU_INSTALL_ROOT ?= $(REDOX_GNU_INSTALL_ROOT)/bin/

.PHONY: all clean receiver keyboard

all: receiver keyboard

receiver:
	$(MAKE) -C redox-w-receiver-basic/custom/armgcc SDK_ROOT=$(SDK_ROOT) GNU_INSTALL_ROOT=$(GNU_INSTALL_ROOT)

keyboard:
	$(MAKE) -C redox-w-keyboard-basic/custom/armgcc SDK_ROOT=$(SDK_ROOT) GNU_INSTALL_ROOT=$(GNU_INSTALL_ROOT)

clean:
	$(MAKE) -C redox-w-receiver-basic/custom/armgcc clean
	$(MAKE) -C redox-w-keyboard-basic/custom/armgcc clean
