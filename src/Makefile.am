# -- src/Makefile.am --

# The final binary is named dzen2
bin_PROGRAMS = dzen2

# Source files for building dzen2
dzen2_SOURCES = \
  action.c \
  action.h \
  caches.c \
  draw.c \
  dzen.h \
  kvstore.c \
  kvstore.h \
  main.c \
  util.c

# Add macOS-specific source when building on Apple platforms
if MACOS_BUILD
dzen2_SOURCES += macos.m
endif

# We can add extra CFLAGS or LIBS if needed, e.g.

dzen2_CPPFLAGS = $(CPPFLAGS)
dzen2_LDADD    = $(LIBS)

# macOS-specific flags
if MACOS_BUILD
dzen2_LDFLAGS = -framework Cocoa -framework CoreGraphics -framework CoreText
dzen2_CPPFLAGS += -D__APPLE__
endif
