export THEOS_PACKAGE_SCHEME = rootless
export TARGET = iphone:clang:16.5:15.0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

# Moves the PreferenceLoader entry under "Display & Brightness". The name sorts after
# PreferenceLoader so this hook wraps PreferenceLoader's -specifiers.
TWEAK_NAME = zzMaterialYouSettings
zzMaterialYouSettings_FILES = Settings/Tweak.x
zzMaterialYouSettings_CFLAGS = -fobjc-arc
zzMaterialYouSettings_PRIVATE_FRAMEWORKS = Preferences

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
