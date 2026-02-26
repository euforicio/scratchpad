# -*- mode: makefile-gmake -*-

SRC := ../../onilibvim/src/xdiff

SRCS := $(notdir $(wildcard $(SRC)/*.c))
HEADERS := $(notdir $(wildcard $(SRC)/*.h))
ALL := $(SRCS) $(HEADERS)

all: $(ALL)

$(ALL):
	install $(SRC)/$@ $@

.PHONY: clean
clean:
	rm -f $(ALL)
