# BPF Kernel Patch - Track kernel file modifications across experiments
#
# Usage:
#   make new NAME=xxx              Create new experiment
#   make track FILE=xxx            Track existing kernel file
#   make track-add FILE=xxx        Track new file to add
#   make apply                     Apply patches to kernel
#   make revert                    Revert kernel to original
#   make status                    Show current status
#   make diff                      Show all diffs
#
# See README.md for full documentation

SCRIPT := ./patch.sh
LINUX ?= $(realpath ../../linux)

new:
	@$(SCRIPT) new $(NAME)

list:
	@$(SCRIPT) list

delete:
	@$(SCRIPT) delete $(NAME)

activate:
	@$(SCRIPT) activate $(NAME)

track:
ifdef FILES
	@LINUX=$(LINUX) $(SCRIPT) track $(FILES)
else ifdef FILE
	@LINUX=$(LINUX) $(SCRIPT) track $(FILE)
else
	@echo "Usage: make track FILE=<path> or FILES=\"<path1> <path2>\""
	@exit 1
endif

track-add:
ifdef FILES
	@LINUX=$(LINUX) $(SCRIPT) track-add $(FILES)
else ifdef FILE
	@LINUX=$(LINUX) $(SCRIPT) track-add $(FILE)
else
	@echo "Usage: make track-add FILE=<path> or FILES=\"<path1> <path2>\""
	@exit 1
endif

untrack:
ifdef FILES
	@LINUX=$(LINUX) $(SCRIPT) untrack $(FILES)
else ifdef FILE
	@LINUX=$(LINUX) $(SCRIPT) untrack $(FILE)
else
	@echo "Usage: make untrack FILE=<path> or FILES=\"<path1> <path2>\""
	@exit 1
endif

apply:
	@LINUX=$(LINUX) $(SCRIPT) apply

revert:
	@LINUX=$(LINUX) $(SCRIPT) revert

status:
	@LINUX=$(LINUX) $(SCRIPT) status

diff:
ifdef FILE
	@LINUX=$(LINUX) $(SCRIPT) diff $(FILE)
else
	@LINUX=$(LINUX) $(SCRIPT) diff
endif

help:
	@echo "BPF Kernel Patch - Track kernel modifications across experiments"
	@echo ""
	@echo "Usage: make <target> [OPTIONS]"
	@echo ""
	@echo "Targets:"
	@echo "  new NAME=xxx            Create new experiment and set as active"
	@echo "  list                    List all experiments"
	@echo "  delete NAME=xxx         Delete an experiment"
	@echo "  activate NAME=xxx       Set experiment as active"
	@echo "  track FILE=xxx          Track existing kernel file for replacement"
	@echo "  track-add FILE=xxx      Track new file to be added"
	@echo "  untrack FILE=xxx        Stop tracking file"
	@echo "  apply                   Apply patches to kernel"
	@echo "  revert                  Revert kernel to original state"
	@echo "  status                  Show current experiment status"
	@echo "  diff [FILE=xxx]         Show diff between backup and patch"
	@echo ""
	@echo "Options:"
	@echo "  LINUX=/path/to/linux    Override kernel source path (default: ../../linux)"
	@echo "  FILES=\"a b c\"           Track multiple files at once"

.PHONY: new list delete activate track track-add untrack apply revert status diff help
