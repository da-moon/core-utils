include build/base/base.mk
include build/string/string.mk
include build/color/color.mk
include build/functions/functions.mk

THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
BINS:=$(call get_dirs,cmd)
BUILD_TARGETS = $(BINS:%=build-%)
FLATTEN_TARGETS = $(BINS:%=flatten-%)
CLEAN_TARGETS = $(BINS:%=clean-%)

.PHONY: build clean  flatten $(BINS) $(BUILD_TARGETS) $(FLATTEN_TARGETS) $(CLEAN_TARGETS)
.SILENT: build clean flatten $(BINS) $(BUILD_TARGETS) $(FLATTEN_TARGETS) $(CLEAN_TARGETS)

build: flatten 
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(BUILD_TARGETS)
	- $(call print_completed_target)
flatten:  
	- $(call print_running_target)
	# - @$(MAKE) --no-print-directory -f $(THIS_FILE) clean
	- $(MKDIR) flattened
	- $(MKDIR) build/targets
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) flatten-get-hashi
	# - @$(MAKE) --no-print-directory -f $(THIS_FILE) flatten-gitt
	# - @$(MAKE) --no-print-directory -f $(THIS_FILE) flatten-get-vscode
	# - @$(MAKE) --no-print-directory -f $(THIS_FILE) $(FLATTEN_TARGETS)
	- $(call print_completed_target)
clean: 
	- $(call print_running_target)
	- $(RM) flattened
	- $(RM) build/targets
	- $(call print_completed_target)

$(BUILD_TARGETS):
	- $(call print_running_target)
	- $(eval name=$(@:build-%=%))
	- $(eval temp=build/targets/${name}-temp.list)
	- $(eval target=build/targets/${name}.list)
	- $(eval output_temp=$(PWD)/flattened/${name}.sh)
	- $(eval output=$(PWD)/bin/${name})
	- $(call append_to_file,$(output),#!/usr/bin/env bash)
	- $(call append_to_file,$(output),# Flattened ... do not modify )
	- $(call append_to_file,$(output),$(call read_file_content,$(output_temp)))	
	- chmod +x $(output)
	- $(RM) $(output_temp)
	- $(call print_completed_target)

$(FLATTEN_TARGETS): 
	- $(call print_running_target)
	- $(eval name=$(@:flatten-%=%))
	- $(eval temp=build/targets/${name}-temp.list)
	- $(eval target=build/targets/${name}.list)
	- $(eval output_temp=$(PWD)/flattened/${name}.sh)
	- $(eval cmd=$(PWD)/cmd/${name}/${name}.sh)

	- chmod +x ${cmd}
	- cat $(cmd) | grep -Eo 'sourced path.*' | cut -f2- -d: >> ${temp}
	- awk '!seen[$$0]++' ${temp} > ${target}
	- @echo ${cmd} >> ${target}
	- $(foreach O,\
			$(call read_file_content,${target}),\
			$(call append_to_file,\
				$(output_temp),$(call read_file_content,$O)\
			)\
		)
	- $(call print_completed_target,flattened scripts)
	- $(call remove_matching_lines,#!, $(output_temp))
	- $(call print_completed_target,removed script shebangs)
	- $(call remove_matching_lines,# shellcheck, $(output_temp))
	- $(call print_completed_target,removed script shellcheck)
	- $(call remove_matching_lines,sourced path:, $(output_temp))
	- $(call remove_matching_lines,dirname "${BASH_SOURCE[0]}" , $(output_temp))
	- $(call print_completed_target,removed individual script source)
	- $(call remove_matching_lines,export -f, $(output_temp))
	- $(call print_completed_target,removed function exports)
	- $(call remove_empty_lines, $(output_temp))
	- $(call print_completed_target,removed empty lines)
	- $(call print_completed_target)

test: 
	- $(call print_running_target)
	- $(info $(LIBS))

