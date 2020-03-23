include build/base/base.mk
include build/string/string.mk
include build/color/color.mk
include build/functions/functions.mk
THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
.PHONY: build process clean
.SILENT: build process clean
EXT=sh
FLATTENED_NAME=coreutils-lib
build: process
	- $(call print_running_target)
	- $(eval output=$(PWD)/flattened/${FLATTENED_NAME}.${EXT})
	- $(eval output_temp=$(PWD)/flattened/${FLATTENED_NAME}_temp.${EXT})
	- $(call append_to_file,$(output),#!/usr/bin/env bash)
	- $(call append_to_file,$(output),# Flattened ... do not modify )
	- $(call print_completed_target,created main flattened script and added shebang)
	- $(call append_to_file,$(output),$(call read_file_content,$(output_temp)))
	- $(RM) $(output_temp)
	- $(call print_completed_target)

process: clean
	- $(call print_running_target)
	- $(eval pkg_path=$(PWD)/lib)
	- $(eval TARGET = $(call rwildcard,$(pkg_path),*.${EXT}))
	- $(eval output_temp=$(PWD)/flattened/${FLATTENED_NAME}_temp.${EXT})
	- $(foreach O,\
			$(sort $(TARGET)),\
			$(call append_to_file,\
				$(output_temp),$(call read_file_content,$O)\
			)\
		)
	- $(call print_completed_target,flattened makefiles)
	- $(call remove_matching_lines,#!, $(output_temp))
	- $(call print_completed_target,removed script shebangs)
	- $(call remove_matching_lines,# shellcheck, $(output_temp))
	- $(call print_completed_target,removed script shellcheck)
	- $(call remove_matching_lines,dirname "${BASH_SOURCE[0]}" , $(output_temp))
	- $(call print_completed_target,removed individual script source)
	- $(call remove_empty_lines, $(output_temp))
	- $(call print_completed_target,removed empty lines)
	- $(call print_completed_target)
clean:
	- $(call print_running_target)
	- $(RM) flattened
	- $(MKDIR) flattened
	- $(call print_completed_target)

