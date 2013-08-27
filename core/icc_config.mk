DEFAULT_COMPILER:=gcc
# Forces the following modules to be compiled with Intel* compiler independent of DEFAULT_COMPILER
ICC_MODULES     :=
# The modules linked  statically against compiler libraries if configured to be compiled with Intel compiler
ICC_STATIC_MODULES :=
# Modules from droidboot and recovery images
ICC_STATIC_MODULES += \
	libcutils liblog libstdc++ \
	mksh systembinsh toolbox libdiskconfig \
	libsparse libusbhost libz resize2fs tune2fs e2fsck gzip kexec droidboot \
	strace charger proxy-recovery partlink logcat
# Forces the following modules to be compiled with GNU* compiler independent of DEFAULT_COMPILER
GCC_MODULES     := libwidimedia
# Modules that are compiled with -ipo if configured to be compiled with Intel compiler
ICC_IPO_MODULES := libc_nomalloc libc liblog
ICC_IPO_MODULES += libdvm dexdump dvz dalvikvm
ICC_IPO_MODULES += libxslt libxml2 libskia libskiagpu
ICC_IPO_MODULES += libwebcore libv8 libhyphenation
ICC_IPO_MODULES += libva_videoencoder libva_videodecoder libmixvideo libmixcommon libmfldadvci
ICC_IPO_MODULES += libSh3a libmixvbp libasfparser libft2 libicui18n libicuuc
ICC_IPO_MODULES += libfdlibm libdex
#ICC_IPO_MODULES += IMG_graphics
# Enable source-code modifications for improved vectorization in libskia and libskiagpu
# Set ENABLE_ICC_MOD to empty string to disable modifications
ENABLE_ICC_MOD  := true

# Modules that require -ffreestanding to avoid dependence on libintlc
# Applies only to modules that are configured to be built with icc
ICC_FREESTANDING_MODULES := libc_common libc_nomalloc libc libc_malloc_debug_leak libc_malloc_debug_qemu libbionic_ssp libc_netbsd
ICC_FREESTANDING_MODULES += libdl libm linker update_osip libosip
# Modules from droidboot and recovery images
ICC_FREESTANDING_MODULES += libext4_utils libext2fs libext2_com_err libext2_e2p
ICC_FREESTANDING_MODULES += libext2_blkid libext2_uuid libext2_profile

TARGET_ICC_TOOLS_PREFIX := \
	prebuilts/PRIVATE/icc/linux-x86/x86/x86-android-linux-13.0/bin/

TARGET_ICC     := $(abspath $(TARGET_ICC_TOOLS_PREFIX)icc)
TARGET_ICPC    := $(abspath $(TARGET_ICC_TOOLS_PREFIX)icpc)
TARGET_XIAR    := $(abspath $(TARGET_ICC_TOOLS_PREFIX)xiar)
TARGET_XILD    := $(abspath $(TARGET_ICC_TOOLS_PREFIX)xild)

export ANDROID_GNU_X86_TOOLCHAIN:=$(abspath $(dir $(TARGET_TOOLS_PREFIX)))/../
export ANDROID_SYSROOT:=

ifeq ($(strip $(DEFAULT_COMPILER)),gcc)
  do-intel-target-need-intel-libraries:=$(if $(strip $(ICC_MODULES)),true)
  define do-intel-target-use-icc
    $(if $(filter $(strip $1),$(ICC_MODULES)),true)
  endef
else
  do-intel-target-need-intel-libraries:=true
  define do-intel-target-use-icc
    $(if $(filter $(strip $1),$(GCC_MODULES)),,$(if $(strip $(LOCAL_CLANG)),,true))
  endef
endif

define intel-target-use-icc
$(strip \
  $(call do-intel-target-use-icc,$1))
endef

define intel-target-need-intel-libraries
$(strip \
  $(call do-intel-target-need-intel-libraries))
endef

define intel-target-cc
$(strip \
  $(if $(call intel-target-use-icc,$1),$(TARGET_ICC),$(abspath $(TARGET_CC))))
endef

define intel-target-cxx
$(strip \
  $(if $(call intel-target-use-icc,$1),$(TARGET_ICPC),$(abspath $(TARGET_CXX))))
endef

define intel-target-ipo-enable
$(strip \
  $(and $(call intel-target-use-icc,$1),$(filter $(strip $1),$(ICC_IPO_MODULES))))
endef

define intel-target-freestanding-enable
$(strip \
  $(and $(call intel-target-use-icc,$1),$(filter $(strip $1),$(ICC_FREESTANDING_MODULES))))
endef

# If module is compiled by ICC then respect ICC_STATIC_MODULES variable
# otherwise satisfy potential dependence on ICC libs statically
define intel-target-static-intel
$(strip \
  $(if $(call intel-target-use-icc,$1),
    $(strip $(filter $(1),$(ICC_STATIC_MODULES))),\
    $(call intel-target-need-intel-libraries)))
endef

define intel-target-freestanding-or-static
$(strip $(or $(call intel-target-freestanding-enable,$(LOCAL_MODULE)),\
             $(call intel-target-static-intel,$(LOCAL_MODULE))))
endef

ifneq ($(call intel-target-need-intel-libraries),)
  ICC_COMPILER_STATIC_LIBRARIES := libsvml libimf_s libirc libirng_s
  ICC_COMPILER_LIBRARIES        := libsvml libimf libintlc libirng
  TARGET_AR                     := $(TARGET_XIAR)
  TARGET_LD                     := $(TARGET_XILD)
endif

define do-icc-flags-subst
  $(1) := $(subst $(2),$(3),$($(1)))
endef

define icc-flags-subst
  $(eval $(call do-icc-flags-subst,$(1),$(2),$(3)))
endef

ifeq ($(strip $(TARGET_BOARD_PLATFORM)),merrifield)
TARGET_GLOBAL_ICC_XARCH := -xATOM_SSE4.2
else
TARGET_GLOBAL_ICC_XARCH := -xSSSE3_ATOM
endif
TARGET_GLOBAL_ICC_CFLAGS := $(TARGET_GLOBAL_CFLAGS)
TARGET_GLOBAL_ICC_CFLAGS += -no-prec-div
TARGET_GLOBAL_ICC_CFLAGS += -fno-builtin-memset -fno-builtin-strcmp -fno-builtin-strlen -fno-builtin-strchr
TARGET_GLOBAL_ICC_CFLAGS += -fno-builtin-cos -fno-builtin-sin -fno-builtin-tan
TARGET_GLOBAL_ICC_CFLAGS += -restrict -i_nopreempt -Bsymbolic
TARGET_GLOBAL_ICC_CFLAGS += -diag-disable 144,556,279,803,2646,589,83,290,180,1875,177,2415,869,593 #-diag-error 592,117,1101
TARGET_GLOBAL_ICC_CFLAGS += -g1
TARGET_GLOBAL_ICC_CFLAGS += -Qoption,c,--internal_linkage_for_unnamed_nsp_members
TARGET_GLOBAL_ICC_CFLAGS += $(TARGET_GLOBAL_ICC_XARCH)

$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-mstackrealign,-falign-stack=assume-4-byte)
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-O2,-O3)
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-march=atom,)
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-msse3,)
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-mfpmath=sse,)
# icc generates pic by default.
# TARGET_GLOBAL_CFLAGS are passed to linker and override -fno-pic for link-time optimization in webkit
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-fPIC,)
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-fPIE,)
# bionic is the only libc configuration of Intel* compiler for Android*
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-mbionic,)
# Unsupported options
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-fno-inline-functions-called-once,)
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-funswitch-loops,)
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CFLAGS,-funwind-tables,)

TARGET_GLOBAL_ICC_CPPFLAGS := $(TARGET_GLOBAL_CPPFLAGS)
$(call icc-flags-subst,TARGET_GLOBAL_ICC_CPPFLAGS,-fno-use-cxa-atexit,)
TARGET_GLOBAL_ICC_CPPFLAGS += -Qoption,c,--use_atexit

define icc-check-module
$(strip \
  $(filter $(strip $1),$(LOCAL_MODULE)))
endef

#Called from core/binary.mk
define icc-flags
  $(call icc-flags-subst,LOCAL_CFLAGS,-march=atom,) \
  $(call icc-flags-subst,LOCAL_CFLAGS,-mtune=atom,) \
  $(call icc-flags-subst,LOCAL_CFLAGS,-msse3,) \
  \
  $(call icc-flags-subst,LOCAL_CFLAGS,-fno-inline-functions-called-once,) \
  $(call icc-flags-subst,LOCAL_CFLAGS,-funswitch-loops,) \
  $(call icc-flags-subst,LOCAL_CFLAGS,-funwind-tables,) \
  \
  $(eval LOCAL_CFLAGS   += $(if $(call intel-target-freestanding-enable,$(LOCAL_MODULE)),-ffreestanding)) \
  $(eval LOCAL_CFLAGS   += $(if $(call intel-target-ipo-enable,$(LOCAL_MODULE)),-ipo -g0)) \
  $(eval LOCAL_LDFLAGS  += $(if $(call intel-target-ipo-enable,$(LOCAL_MODULE)),-ipo4)) \
  $(eval LOCAL_CFLAGS   += $(if $(strip $(ENABLE_ICC_MOD)),\
                             $(if $(call icc-check-module,libskia),\
                               -DICC_SKIA))) \
  $(eval LOCAL_CFLAGS   += $(if $(strip $(ENABLE_ICC_MOD)),\
                             $(if $(call icc-check-module,libskiagpu),\
                               -DICC_SKIA))) \
  $(eval LOCAL_CFLAGS   += $(if $(call icc-check-module,libwebcore),-g0)) \
  $(eval LOCAL_LDFLAGS  += $(if $(call icc-check-module,libwebcore),\
                             -mIPOPT_link_verbose=T -from_rtn 0 -to_rtn -1)) \
  $(eval LOCAL_LDFLAGS  += $(if $(call icc-check-module,libwebcore),-mIPOPT_opt_mask_clear=0x2000000)) \
  $(eval LOCAL_LDFLAGS  += $(foreach l,$(ICC_COMPILER_STATIC_LIBRARIES),-Wl,--exclude-libs=$(strip $(l)).a)) \
  $(eval LOCAL_LDFLAGS  += $(if $(call icc-check-module,libc),-Xlinker --undefined=__udivdi3)) \
  $(eval LOCAL_LDFLAGS  += $(if $(call icc-check-module,libc),-Xlinker --undefined=__divdi3)) \
  $(eval LOCAL_LDFLAGS  += $(if $(call icc-check-module,libc),-Xlinker --undefined=__popcountsi2))
endef

# $1 lib check in LOCAL_SYSTEM_SHARED_LIBRARIES, LOCAL_SHARED_LIBRARIES and LOCAL_STATIC_LIBRARIES
# $2 lib to check in LOCAL_STATIC_LIBRARIES
# $3 libs to add to LOCAL_SHARED_LIBRARIES
define helper-shared-icc-lib
$(strip \
  $(if $(call intel-target-freestanding-or-static),\
    ,\
    $(if $(strip $(filter $1,$(LOCAL_SYSTEM_SHARED_LIBRARIES) $(LOCAL_SHARED_LIBRARIES))),\
      $(if $(strip $(filter $1 $2,$(LOCAL_STATIC_LIBRARIES))),\
      ,\
      $3))))
endef

# $1 lib to check in LOCAL_STATIC_LIBRARIES
# $2 libs to add to LOCAL_STATIC_LIBRARIES
# Modules that are forced to be linked against ICC libs statically are handled in other place
# by adding ICC_COMPILER_STATIC_LIBRARIES
define helper-static-icc-lib
$(strip \
  $(if $(call intel-target-freestanding-or-static),\
    ,\
    $(if $(strip $(filter $1,$(LOCAL_STATIC_LIBRARIES))),$2)))
endef

# Stack protector support functions live in libirc.a
# Add libirc to LOCAL_STATIC_LIBRARIES if there is no libintlc in LOCAL_SHARED_LIBRARIES
#   and no libirc in LOCAL_STATIC_LIBRARIES
define helper-libirc-lib
$(strip \
  $(if $(strip $(filter libintlc,$(LOCAL_SHARED_LIBRARIES))),\
    ,\
    $(if $(call intel-target-static-intel,$(LOCAL_MODULE)),\
      ,\
      libirc)))
endef

# Called from core/binary.mk
# Short explanation (names of the corresponding shared and static libs are separated by '/'):
#  libimf/libimf_s libs and libsvml/libsvml libs are complementary to libm library.
#  libirng/libirng_s libs and libintlc/libirc libs are complementary to libc library.
#  LOCAL_WHOLE_STATIC_LIBRARIES var is not processed for simplicity
# It is assumed that libc/libm can only be in LOCAL_SYSTEM_SHARED_LIBRARIES, LOCAL_SHARED_LIBRARIES and LOCAL_STATIC_LIBRARIES
define icc-libs
  $(if $(strip $(filter libm libc,$(LOCAL_WHOLE_STATIC_LIBRARIES))),$(error libm and/or libc are in LOCAL_WHOLE_STATIC_LIBRARIES for module $(LOCAL_MODULE))) \
  $(eval LOCAL_SHARED_LIBRARIES += $(call helper-shared-icc-lib,libc,libirc,libintlc)) \
  $(eval LOCAL_SHARED_LIBRARIES += $(call helper-shared-icc-lib,libc,libirng_s,libirng)) \
  $(eval LOCAL_SHARED_LIBRARIES += $(call helper-shared-icc-lib,libm,libimf_s,libimf)) \
  $(eval LOCAL_SHARED_LIBRARIES += $(call helper-shared-icc-lib,libm,libsvml,libsvml)) \
  $(eval LOCAL_STATIC_LIBRARIES += $(call helper-static-icc-lib,libc,libirng_s)) \
  $(eval LOCAL_STATIC_LIBRARIES += $(call helper-static-icc-lib,libm,libimf_s libsvml)) \
  $(eval LOCAL_STATIC_LIBRARIES += $(if $(call intel-target-static-intel,$(LOCAL_MODULE)),\
                                     $(ICC_COMPILER_STATIC_LIBRARIES))) \
  $(eval LOCAL_STATIC_LIBRARIES += $(helper-libirc-lib))
endef
