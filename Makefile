# src dir
SRCROOT      := ./src
# exec file
TARGET       := $(SRCROOT)/tcp
# src sub dir
SRCDIRS      := $(shell find $(SRCROOT) -type d)
# all src 
SOURCES      := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.sh))
# shellcheck disable err code
EXCLUDE_CODE := SC2154,SC2206,SC2207,SC2012,SC2155,SC2034,SC1090
# Integration Test
IT_SRC := ./tests/run.sh

install:
	/bin/bash ./scripts/install.sh

uninstall:
	/bin/bash ./scripts/uninstall.sh

test:
	/bin/bash $(IT_SRC) $(TARGET)

check-scripts:
	shellcheck $(TARGET) $(SOURCES) -e $(EXCLUDE_CODE)
