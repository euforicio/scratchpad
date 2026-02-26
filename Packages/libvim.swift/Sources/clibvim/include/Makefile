# -*- mode: makefile-gmake -*-

LIBVIM_SRC := ../onilibvim/src
CFLAGS := -DHAVE_CONFIG_H -DMACOS_X -DMACOS_X_DARWIN -I. -I$(LIBVIM_SRC)/proto

-include .include.d

.include.d: auto/config.h
	set -eo pipefail; \
		$(CC) $(CFLAGS) -MM $(LIBVIM_SRC)/libvim.h \
		| sed "s|^libvim\.o|include|; s|$(LIBVIM_SRC)/||g; s|proto/||g" > $@

define MDCP
	@echo MDCP $^ "->" $@
	@mkdir -p $(dir $@)
	@install $^ $@
endef

# We need to flatten the include tree because there's no way to add include paths
# via module.modulemap and the proto includes aren't using relative paths
%.pro: $(LIBVIM_SRC)/proto/%.pro
	$(MDCP)

%.h: $(LIBVIM_SRC)/%.h
	$(MDCP)

auto/config.h:
	cd $(LIBVIM_SRC) && ./configure CFLAGS=-Wno-implicit-int
	mkdir -p $(dir $@)
	mv $(LIBVIM_SRC)/$@ $@
	echo '#include "fixes.h"' >> $@

.PHONY: clean
clean:
	rm -rf *.{h,pro} auto/config.h
