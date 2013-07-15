# This file contains feature macro definitions specific to the
# silvermont (Atom) variant. This is an extension of the 'x86'
# base variant that adds Atom-specific features.
#
# See build/core/combo/arch/x86/x86.mk for differences.
#
ARCH_X86_HAVE_MMX   := true
ARCH_X86_HAVE_SSE   := true
ARCH_X86_HAVE_SSE2  := true
ARCH_X86_HAVE_SSE3  := true

ARCH_X86_HAVE_SSSE3 := true

ARCH_X86_HAVE_SSE4 := true

ARCH_X86_HAVE_MOVBE := true
ARCH_X86_HAVE_POPCNT := true
ARCH_X86_HAVE_AES-NI := true

# This flag is used to enabled Atom-specific optimizations with our toolchain
#
TARGET_GLOBAL_CFLAGS += -march=slm

