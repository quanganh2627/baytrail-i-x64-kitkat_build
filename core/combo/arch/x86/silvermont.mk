# This file contains feature macro definitions specific to the
# silvermont arch variant.
#
# See build/core/combo/arch/x86/x86-atom.mk for differences.
#
# NOTE: This is currently a copy of the x86-atom.mk and has not
# yet been populated with silvermont-specific compiler directives.

ARCH_X86_HAVE_MMX   := true
ARCH_X86_HAVE_SSE   := true
ARCH_X86_HAVE_SSE2  := true
ARCH_X86_HAVE_SSE3  := true
ARCH_X86_HAVE_SSSE3 := true
ARCH_X86_HAVE_SSE4   := true
ARCH_X86_HAVE_SSE4_1 := true
ARCH_X86_HAVE_SSE4_2 := true
ARCH_X86_HAVE_AES_NI := true
ARCH_X86_HAVE_POPCNT := true
ARCH_X86_HAVE_MOVBE  := true

# CFLAGS for this arch
arch_variant_cflags := \
	-march=atom \
	-mstackrealign \
	-mfpmath=sse \
