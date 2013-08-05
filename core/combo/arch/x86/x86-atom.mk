# This file contains feature macro definitions specific to the
# 'x86-atom' arch variant. This is an extension of the 'x86' base variant
# that adds Atom-specific features.
#
# See build/core/combo/arch/x86/x86.mk for differences.
#
ARCH_X86_HAVE_MMX   := true
ARCH_X86_HAVE_SSE   := true
ARCH_X86_HAVE_SSE2  := true
ARCH_X86_HAVE_SSE3  := true

ARCH_X86_HAVE_SSSE3 := true

ifeq ($(TARGET_BOARD_PLATFORM),bigcore)
ARCH_X86_HAVE_MOVBE := false
else
ARCH_X86_HAVE_MOVBE := true
endif

ARCH_X86_HAVE_POPCNT := false   # popcnt is not supported by current Atom CPUs

# This flag is used to enabled Atom-specific optimizations with our toolchain
#
ifeq ($(TARGET_BOARD_PLATFORM),bigcore)
TARGET_GLOBAL_CFLAGS += -march=corei7 -mssse3
else
TARGET_GLOBAL_CFLAGS += -march=atom
endif
