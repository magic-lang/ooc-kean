/*
 * EGLImageImport.cpp
 *
 *  Created on: 10 sep 2014
 *      Author: ewestergren
 */
#include "EGLImage.h"

extern "C" int createEGLImage(int width, int height, EGLDisplay display, int write);
extern "C" void destroyEGLImage(int index);
extern "C" void unlockPixels(int index);
extern "C" int getStride(int index);
extern "C" void destroyAll();
extern "C" void* readPixels(int index);
extern "C" void* writePixels(int index);
int createEGLImage(int width, int height, EGLDisplay display, int write) {
	return android::_createEGLImage(width, height, display, write);
}
void destroyEGLImage(int index) {
	android::_destroyEGLImage(index);
}
void unlockPixels(int index) {
	android::_unlockPixels(index);
}
int getStride(int index) {
	return android::_getStride(index);
}
void destroyAll() {
	android::_destroyAll();
}
void* readPixels(int index) {
	return android::_readPixels(index);
}
void* writePixels(int index) {
	return android::_writePixels(index);
}

