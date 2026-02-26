# -*- mode: makefile-gmake -*-

LIBVIM_SRC := onilibvim/src

all: src include

src: include

src include:
	$(MAKE) -C $@

clean:
	$(MAKE) -C $(LIBVIM_SRC) distclean
	$(MAKE) -C src clean
	$(MAKE) -C include clean

.PHONY: all src include clean
