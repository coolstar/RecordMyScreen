TARGET=:clang
include theos/makefiles/common.mk

TWEAK_NAME = RecordMyScreenTweak
RecordMyScreenTweak_FILES = Tweak.xm ../RecordMyScreen/CSScreenRecorder.m
RecordMyScreenTweak_FRAMEWORKS = CoreGraphics QuartzCore UIKit AVFoundation CoreVideo CoreMedia
RecordMyScreenTweak_PRIVATE_FRAMEWORKS = IOSurface
RecordMyScreenTweak_CFLAGS = -I../RecordMyScreen/headers/ -I../RecordMyScreen/headers/Headers
include $(THEOS_MAKE_PATH)/tweak.mk
