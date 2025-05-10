SUBDIRS := $(shell find categories -mindepth 1 -maxdepth 1 -type d)

.PHONY: all clean
all:
	@for d in $(SUBDIRS); do $(MAKE) -C $$d; done

clean:
	@for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done
