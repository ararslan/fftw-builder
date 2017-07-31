BUILDDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/build
SRCDIR := $(BUILDDIR)/src
LIBDIR := $(BUILDDIR)/lib
BINDIR := $(BUILDDIR)/bin

default: $(LIBDIR)/libfftw%

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

ifeq ($(OS),WINNT)
CONFIG += CC="$(ARCH)-w64-mingw32-gcc"
FFTW_CONFIG += --with-our-malloc --with-combined-threads
ifneq ($(ARCH),x86_64)
FFTW_CONFIG += --with-incoming-stack-boundary=2
endif
endif

FFTW_CONFIG += --enable-single

.PHONY: default

$(SRCDIR)/fftw-$(FFTW_VERS).tar.gz: | $(SRCDIR)
	curl -fkL --connect-timeout 15 -y 15 http://www.fftw.org/$(notdir $@) -o $@

$(SRCDIR)/configure: $(SRCDIR)/fftw-$(FFTW_VERS).tar.gz
	$(TAR) -C $(dir $@) --strip-components 1 -xf $<

$(LIBDIR)/libfftw%: $(SRCDIR)/configure | $(LIBDIR) $(BINDIR)
	# Try to configure with AVX support, if that fails then try again without
	(cd $(dir $<) && \
	    ./configure $(CONFIG) $(FFTW_CONFIG) --enable-avx || \
	    ./configure $(CONFIG) $(FFTW_CONFIG))
	$(MAKE) -C $(dir $<)
	$(MAKE) -C $(dir $<) install
