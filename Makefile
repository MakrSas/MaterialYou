export THEOS_PACKAGE_SCHEME = rootless
export TARGET = iphone:clang:16.5:15.0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

# Moves the PreferenceLoader entry under "Display & Brightness". The name sorts after
# PreferenceLoader so this hook wraps PreferenceLoader's -specifiers.
TWEAK_NAME = zzMaterialYouSettings MaterialYouWallpaper
zzMaterialYouSettings_FILES = Settings/Tweak.x
zzMaterialYouSettings_CFLAGS = -fobjc-arc
zzMaterialYouSettings_PRIVATE_FRAMEWORKS = Preferences

# iOS 16+: saves the Home Screen wallpaper (PosterBoard) for the wallpaper colours. SpringBoard only.
MaterialYouWallpaper_FILES = Wallpaper/Tweak.x
MaterialYouWallpaper_CFLAGS = -fobjc-arc

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
