TARGET=:clang
include theos/makefiles/common.mk

APPLICATION_NAME = RecordMyScreen
RecordMyScreen_FILES = $(wildcard ../RecordMyScreen/*.m) $(wildcard ../InAppSettingsKit/InAppSettingsKit/*/*.m)
RecordMyScreen_OBJ_FILES = $(wildcard ../SAVideoRangeSlider/*.o)
RecordMyScreen_FRAMEWORKS = CoreGraphics QuartzCore UIKit AVFoundation CoreVideo CoreMedia MediaPlayer MessageUI
RecordMyScreen_PRIVATE_FRAMEWORKS = IOSurface
RecordMyScreen_CFLAGS = -include ../RecordMyScreen/RecordMyScreen-Prefix.pch -Winvalid-pch -I../RecordMyScreen/headers/ -I../RecordMyScreen/headers/IOSurface -I../SAVideoRangeSlider/ -I../InAppSettingsKit/InAppSettingsKit/Controllers/ -I../InAppSettingsKit/InAppSettingsKit/Models/ -I../InAppSettingsKit/InAppSettingsKit/Views/
include $(THEOS_MAKE_PATH)/application.mk
