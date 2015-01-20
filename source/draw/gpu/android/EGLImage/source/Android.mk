LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE_PATH := ./
LOCAL_C_INCLUDES := \
include \
LOCAL_SHARED_LIBRARIES:=
LOCAL_SRC_FILES := EGLImage.cpp EGLImageImport.cpp
LOCAL_LDLIBS :=
LOCAL_MODULE := libeglimage
include $(BUILD_SHARED_LIBRARY)
