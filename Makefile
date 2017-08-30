BUILDDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/build
SRCDIR := $(BUILDDIR)/src
LIBDIR := $(BUILDDIR)/lib
BINDIR := $(BUILDDIR)/bin

ifeq ($(OS),Windows_NT)
SHLIB_EXT := dll
SUFFIX := -3
else
SUFFIX := _threads
ifeq ($(shell uname),Darwin)
SHLIB_EXT := dylib
else
SHLIB_EXT := so
endif
endif

BASE_single := libfftw3f
BASE_double := libfftw3
TARGET_single := libfftw3f$(SUFFIX).$(SHLIB_EXT)
TARGET_double := libfftw3$(SUFFIX).$(SHLIB_EXT)

default: $(LIBDIR)/$(TARGET_single) $(LIBDIR)/$(TARGET_double)

# Define directory-creation rule for many directories we'll need
define dir_rule
$(1):
	@mkdir -p $(1)
endef
$(foreach d,$(SRCDIR) $(LIBDIR) $(BINDIR),$(eval $(call dir_rule,$(d))))

TAR := $(shell which gtar 2>/dev/null || which tar 2>/dev/null)

FFTW_VERS := $(shell cat VERSION)

CONFIG := --prefix=$(BUILDDIR) --libdir=$(LIBDIR) --bindir=$(BINDIR)
FFTW_CONFIG := --enable-shared --disable-fortran --disable-mpi --enable-threads

ifeq ($(ARCH),x86_64)
FFTW_CONFIG += --enable-sse2 --enable-fma
endif

ifeq ($(OS),Windows_NT)
CONFIG += --host=$(ARCH)-w64-mingw32
FFTW_CONFIG += --with-our-malloc --with-combined-threads
ifneq ($(ARCH),x86_64)
FFTW_CONFIG += --with-incoming-stack-boundary=2
endif
endif

ifneq ($(OS),Windows_NT)
ifeq ($(shell uname),Darwin)
CONFIG += LDFLAGS="-Wl,-rpath,'@loader_path/'"
else
CONFIG += LDFLAGS="-Wl,-rpath,'\$$\$$ORIGIN' -Wl,-z,origin"
endif
endif

FFTW_ENABLE_single := --enable-single
FFTW_ENABLE_double :=

.PHONY: default

$(SRCDIR)/fftw-$(FFTW_VERS).tar.gz: | $(SRCDIR)
	curl -fkL --connect-timeout 15 -y 15 http://www.fftw.org/$(notdir $@) -o $@

$(SRCDIR)/configure: $(SRCDIR)/fftw-$(FFTW_VERS).tar.gz
	$(TAR) -C $(dir $@) --strip-components 1 -xf $<

define FFTW_BUILD
$$(LIBDIR)/$$(TARGET_$1): $$(SRCDIR)/configure | $$(LIBDIR) $$(BINDIR)
	(cd $$(dir $$<) && \
	    ./configure $$(CONFIG) $$(FFTW_CONFIG) $$(FFTW_ENABLE_$1) --enable-avx || \
	    ./configure $$(CONFIG) $$(FFTW_CONFIG) $$(FFTW_ENABLE_$1))
	$(MAKE) -C $$(dir $$<)
	$(MAKE) -C $$(dir $$<) install
ifeq ($(OS),Windows_NT)
	mv "$$(BINDIR)/$$(TARGET_$1)" "$$(LIBDIR)/$$(TARGET_$1)"
else
ifeq ($(shell uname),Darwin)
	install_name_tool -id @rpath/$$(BASE_$1).$$(SHLIB_EXT) \
	    $$(LIBDIR)/$$(BASE_$1).$$(SHLIB_EXT)
	install_name_tool -id @rpath/$$(TARGET_$1) $$(LIBDIR)/$$(TARGET_$1)
	install_name_tool -change $$(LIBDIR)/$$(BASE_$1).3.$$(SHLIB_EXT) \
	    @rpath/$$(BASE_$1).$$(SHLIB_EXT) $$(LIBDIR)/$$(TARGET_$1)
endif
endif
endef

$(foreach prec,single double,$(eval $(call FFTW_BUILD,$(prec))))
