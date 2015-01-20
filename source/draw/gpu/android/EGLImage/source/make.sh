#!/bin/bash
NDK_PATH=~/android-ndk-r10d
API_LEVEL=android-21

echo 'LOCAL_PATH := $(call my-dir)' > Android.mk
echo 'include $(CLEAR_VARS)' >> Android.mk
echo 'LOCAL_MODULE_PATH := ./' >> Android.mk
echo -e 'LOCAL_C_INCLUDES := \' >> Android.mk
echo $NDK_PATH/platforms/$API_LEVEL/arch-arm/usr/include
cp $NDK_PATH/platforms/$API_LEVEL/arch-arm/usr/include ./ -rf
echo -e include '\' >> Android.mk

echo -e 'LOCAL_SHARED_LIBRARIES:=' >> Android.mk
echo -e 'LOCAL_SRC_FILES := EGLImage.cpp EGLImageImport.cpp' >> Android.mk
echo -e 'LOCAL_LDLIBS :=' >> Android.mk
echo -e 'LOCAL_MODULE := libeglimage' >> Android.mk
echo -e 'include $(BUILD_SHARED_LIBRARY)' >> Android.mk


$NDK_PATH/ndk-build NDK_TOOLCHAIN_VERSION=snapdragonclang3.5 APP_ABI="armeabi-v7a" NDK_DEBUG=0 NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=./Application.mk APP_BUILD_SCRIPT=./Android.mk
mv ./libs/armeabi-v7a/libeglimage.so ./
rm -rf ./libs
