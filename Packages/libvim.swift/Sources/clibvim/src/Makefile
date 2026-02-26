# -*- mode: makefile-gmake -*-

LIBVIM_SRC := ../onilibvim/src

ALL := auto/pathdef.c auto/config.h

all: $(ALL) xdiff

auto/pathdef.c:
	$(MAKE) -C $(LIBVIM_SRC) $@
	mv $(LIBVIM_SRC)/$@ $@

auto/config.h:
	ln -s ../../include/$@ $@

# We have to copy xdiff because it's #including config.h using relative path which
# bypasses our SPM-configured include path and fails, as config.h won't exist in the
# original source tree.
.PHONY: xdiff
xdiff:
	$(MAKE) -C xdiff

.PHONY: clean
clean:
	$(MAKE) -C xdiff clean
	rm -f $(ALL)
