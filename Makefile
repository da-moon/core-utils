include build/base/base.mk
include build/string/string.mk
include build/color/color.mk
include build/functions/functions.mk

THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))

.PHONY:   test
.SILENT:  test

# do not change this order
LIBS = lib/env/env.sh lib/string/string.sh lib/log/log.sh 
LIBS += lib/array/array.sh lib/array/array.sh lib/file/file.sh   
LIBS += lib/os/os.sh lib/extract/extract.sh lib/git/git.sh lib/install/init.sh

EXT=sh
FLATTENED_NAME=coreutils-lib

BINS:=$(call get_dirs,cmd)
BUILD_TARGETS = $(BINS:%=build-%)
FLATTEN_TARGETS = $(BINS:%=flatten-%)
CLEAN_TARGETS = $(BINS:%=clean-%)

.PHONY: build $(BINS) $(BUILD_TARGETS) $(FLATTEN_TARGETS) $(CLEAN_TARGETS)
.SILENT: build $(BINS) $(BUILD_TARGETS) $(FLATTEN_TARGETS) $(CLEAN_TARGETS)

build: $(CLEAN_TARGETS)
	- $(MKDIR) flattened
	- $(MKDIR) bin
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(BUILD_TARGETS)
	- $(RM) flattened
	- $(call print_completed_target)

$(BUILD_TARGETS):$(FLATTEN_TARGETS)
	- $(call print_running_target)
	- $(eval name=$(@:build-%=%))
	- $(eval output=$(PWD)/bin/$(name))
	- $(call append_to_file,$(output),#!/usr/bin/env bash)
	- $(call append_to_file,$(output),# Flattened ... do not modify )
	- $(call print_completed_target,created main flattened script and added shebang)
	- $(eval base = $(PWD)/flattened/${FLATTENED_NAME}_temp.${EXT})
	- $(call append_to_file,$(output),$(call read_file_content,$(base)))	
	- $(eval output_temp=$(PWD)/flattened/$(name)_temp.${EXT})
	- $(call append_to_file,$(output),$(call read_file_content,$(output_temp)))
	- $(RM) $(output_temp)
	- $(call print_completed_target)
$(FLATTEN_TARGETS): $(CLEAN_TARGETS)
	- $(call print_running_target)
	- $(eval name=$(@:flatten-%=%))
	- $(eval output_temp=$(PWD)/flattened/$(name)_temp.${EXT})
	- $(foreach O,\
			$(PWD)/cmd/$(name)/$(name).sh,\
			$(call append_to_file,\
				$(output_temp),$(call read_file_content,$O)\
			)\
		)
	- $(call print_completed_target,flattened libraries)
	- $(call remove_matching_lines,#!, $(output_temp))
	- $(call print_completed_target,removed script shebangs)
	- $(call remove_matching_lines,# shellcheck, $(output_temp))
	- $(call print_completed_target,removed script shellcheck)
	- $(call remove_matching_lines,dirname "${BASH_SOURCE[0]}" , $(output_temp))
	- $(call print_completed_target,removed individual script source)
	- $(call remove_empty_lines, $(output_temp))
	- $(call print_completed_target,removed empty lines)
	- $(call print_completed_target)
$(CLEAN_TARGETS):
	- $(call print_running_target)
	- $(eval name=$(@:clean-%=%))
	- $(RM) bin/$(name)
	- $(call print_completed_target)

test: 
	- $(call print_running_target)
	- $(info $(LIBS))

