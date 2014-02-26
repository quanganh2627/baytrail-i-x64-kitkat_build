###########################################################
# Flags dependency
###########################################################

ifeq (true,$(ENABLE_DEPFLAGS))
ifeq (,$(LOCAL_IS_HOST_MODULE))

dep_flags := \
  $(LOCAL_CFLAGS) \
  $(LOCAL_CONLYFLAGS) \
  $(LOCAL_CPPFLAGS) \
  $(PRIVATE_ARM_CFLAGS) \
  $(PRIVATE_CFLAGS) \
  $(PRIVATE_CPPFLAGS) \
  $(PRIVATE_C_INCLUDES) \
  $(PRIVATE_CONLYFLAGS) \
  $(PRIVATE_DEBUG_CFLAGS) \
  $(PRIVATE_TARGET_GLOBAL_CFLAGS) \
  $(PRIVATE_TARGET_GLOBAL_CPPFLAGS)

dep_flags_md5 := $(firstword $(shell echo $(strip $(sort $(dep_flags))) | $(MD5SUM)))
flags_dep_file := $(intermediates)/$(dep_flags_md5).flags.dep

$(all_objects) : $(flags_dep_file)
$(import_includes) : $(flags_dep_file)
$(export_includes) : $(flags_dep_file)

$(flags_dep_file) : PRIVATE_LOCAL_MODULE := $(LOCAL_MODULE)
$(flags_dep_file) :
	$(hide) if [ -r $(dir $@)*.flags.dep ]; then \
			rm -f $(dir $@)*.flags.dep; \
			echo "Warning: compilation flags have changed for module \"$(PRIVATE_LOCAL_MODULE)\", recompiling ..."; \
		fi
	$(hide) mkdir -p $(dir $@) && touch $@

endif # LOCAL_IS_HOST_MODULE
endif # ENABLE_DEPFLAGS

