export THEOS_PACKAGE_SCHEME = rootless
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk
BUNDLE_NAME = MaterialYouPrefs
S = ..
MaterialYouPrefs_FILES = MYColorsController.m $(addprefix $(S)/Shared/,LQSTheme.m LQSVectorIcon.m LQSStrings.m LQSMonet.m LQSWallpaper.m LQSColorsViewController.m) $(wildcard $(S)/Monet/*.m)
MaterialYouPrefs_FRAMEWORKS = UIKit CoreText CoreImage
MaterialYouPrefs_PRIVATE_FRAMEWORKS = Preferences
MaterialYouPrefs_INSTALL_PATH = /Library/PreferenceBundles
MaterialYouPrefs_CFLAGS = -fobjc-arc -I$(S)/Shared -I$(S)/Monet
include $(THEOS_MAKE_PATH)/bundle.mk
