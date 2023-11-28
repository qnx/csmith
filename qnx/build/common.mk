ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME=csmith

DIST_BASE=$(PRODUCT_ROOT)/../

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
CSMITH_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

CSMITH_VERSION = .0.0.0

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = csmith_all
.PHONY: csmith_all install check clean

CFLAGS += $(FLAGS) -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-parameter -Wno-unused-but-set-variable -Wno-deprecated-copy
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

# Add the line below
CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX=$(CSMITH_INSTALL_ROOT)/$(CPUVARDIR)/usr \
             -DINCLUDE_INSTALL_DIR=$(CSMITH_INSTALL_ROOT)/usr/include \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_PREFIX_PATH=$(CSMITH_INSTALL_ROOT) \
             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DCPU=$(CPU)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
csmith_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(DIST_BASE)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: csmith_all
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)

clean iclean spotless:
	@rm -rf build
endif

#everything down below deals with the generation of the PINFO
#information for shared objects that is used by the QNX build
#infrastructure to embed metadata in the .so files, for example
#data and time, version number, description, etc. Metadata can
#be retrieved on the target by typing 'use -i <path to openblas .so file>'.
#this is optional: setting GENERATE_PINFO_FILES to FALSE will disable
#the insertion of metadata in .so files.
ifeq ($(GENERATE_PINFO_FILES), TRUE)
#the following rules are called by the cmake generated makefiles,
#in order to generate the .pinfo files for the shared libraries
%.so$(CSMITH_VERSION):
	$(ADD_PINFO)
	$(ADD_USAGE)

endif
