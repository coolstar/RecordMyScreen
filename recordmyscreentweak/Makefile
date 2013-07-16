TARGET=:clang
include theos/makefiles/common.mk

TWEAK_NAME = RecordMyScreenTweak
RecordMyScreenTweak_FILES = ActivatorListener.mm ../RecordMyScreen/CSScreenRecorder.m CSWindow.m CSRecordQueryWindow.m CSRecordCompletionAlert.m
RecordMyScreenTweak_FRAMEWORKS = CoreGraphics QuartzCore UIKit AVFoundation CoreVideo CoreMedia
RecordMyScreenTweak_PRIVATE_FRAMEWORKS = IOSurface
RecordMyScreenTweak_CFLAGS = -I../RecordMyScreen/headers/ -I../RecordMyScreen/headers/IOSurface
RecordMyScreenTweak_LDFLAGS = -lactivator
include $(THEOS_MAKE_PATH)/tweak.mk
