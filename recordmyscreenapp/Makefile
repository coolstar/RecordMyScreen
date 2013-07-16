TARGET=:clang
include theos/makefiles/common.mk

APPLICATION_NAME = recordmyscreenapp
recordmyscreenapp_FILES = $(wildcard ../RecordMyScreen/*.m) $(wildcard ../InAppSettingsKit/InAppSettingsKit/*/*.m)
recordmyscreenapp_OBJ_FILES = $(wildcard ../SAVideoRangeSlider/*.o)
recordmyscreenapp_FRAMEWORKS = CoreGraphics QuartzCore UIKit AVFoundation CoreVideo CoreMedia MediaPlayer MessageUI
recordmyscreenapp_PRIVATE_FRAMEWORKS = IOSurface
recordmyscreenapp_CFLAGS = -include ../RecordMyScreen/RecordMyScreen-Prefix.pch -Winvalid-pch -I../RecordMyScreen/headers/ -I../RecordMyScreen/headers/IOSurface -I../SAVideoRangeSlider/ -I../InAppSettingsKit/InAppSettingsKit/Controllers/ -I../InAppSettingsKit/InAppSettingsKit/Models/ -I../InAppSettingsKit/InAppSettingsKit/Views/
include $(THEOS_MAKE_PATH)/application.mk
