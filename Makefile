#!/bin/env make -f
# license: ISC, see LICENSE file for details

# options, can be passed as args to override behavior
mode ?= sys

SHELL = /usr/bin/fish
makefile_path := $(abspath (lastword $(MAKEFILE_LIST)))
makefile_dir := $(dirname $(makefile_path))

# installation

# standard makefile variables
prefix ?= /usr/local
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin

# use Make's builtin variables to call install
INSTALL ?= install
INSTALL_PROGRAM ?= $(INSTALL)
INSTALL_DATA ?= $(INSTALL) -m 644
MKDIR_PARENTS ?= mkdir -p

# use fish to find target directories
FISH_USER_CONF_DIR := $(shell fish -c 'echo $$__fish_config_dir')
FISH_USER_FUNCTIONS_DIR := $(FISH_USER_CONF_DIR)/functions

# for system shared functions path, we'll use the first XDG_USER_DIRS
# that exists in $fish_function_path.
XDG_DATA_DIRS ?= "/usr/local/share:/usr/share"
SHARE_DIR := $(shell fish -c 'for path in (string split ':' $$XDG_DATA_DIRS); if contains "$$path/fish/vendor_functions.d" $$fish_function_path; echo $$path; break; end; end')
# incase there was no common path.
ifeq ($(SHARE_DIR),)
    SHARE_DIR := $(prefix)/share
endif
FISH_SHARED_FUNCTIONS_DIR := $(SHARE_DIR)/fish/vendor_functions.d

ifeq ($(mode), user)
    FISH_DEST_FUNCTIONS_DIR := $(FISH_USER_FUNCTIONS_DIR)
else
    FISH_DEST_FUNCTIONS_DIR := $(FISH_SHARED_FUNCTIONS_DIR)
endif

FISHION_DEST_PATH := $(FISH_DEST_FUNCTIONS_DIR)/fishion.fish


install:
	test -e $(FISH_DEST_FUNCTIONS_DIR); or sudo $(MKDIR_PARENTS) $(FISH_DEST_FUNCTIONS_DIR)
	sudo $(INSTALL_DATA) fishion.fish $(FISHION_DEST_PATH)


uninstall:
	test -e $(FISHION_DEST_PATH); and sudo rm $(FISHION_DEST_PATH); or true


# standard targets helpful for packaging
build:
	true


test:
	# syntax check
	fish -n fishion.fish


clean:
	true


distclean: clean


.DEFAULT_GOAL := build
.PHONY: build test clean distclean install uninstall
