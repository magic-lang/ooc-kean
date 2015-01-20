/*
 * EGLImage.cpp
 *
 *  Created on: 10 sep 2014
 *      Author: ewestergren
 */
#define LOG_TAG "EGLImage"
#include "EGLImage.h"

namespace android{

PFNEGLCREATEIMAGEKHRPROC _eglCreateImageKHR = NULL;
PFNEGLDESTROYIMAGEKHRPROC _eglDestroyImageKHR = NULL;
PFNGLEGLIMAGETARGETTEXTURE2DOESPROC _glEGLImageTargetTexture2DOES = NULL;

bool initialized = false;
int count = 0;
sp<GraphicBuffer> buffers[MAX_BUFFERS];
EGLImageKHR eglImages[MAX_BUFFERS];
EGLDisplay eglDisplay;
pthread_mutex_t mutex;

bool initialize() {
	if(initialized)
		return true;
	ALOGI("%s: Initializing EGLImage", __func__);
	pthread_mutex_init(&mutex, NULL);
	_eglCreateImageKHR = (PFNEGLCREATEIMAGEKHRPROC) eglGetProcAddress("eglCreateImageKHR");
	_eglDestroyImageKHR = (PFNEGLDESTROYIMAGEKHRPROC) eglGetProcAddress("eglDestroyImageKHR");
	_glEGLImageTargetTexture2DOES = (PFNGLEGLIMAGETARGETTEXTURE2DOESPROC)eglGetProcAddress("glEGLImageTargetTexture2DOES");
	initialized = _eglCreateImageKHR != NULL && _eglDestroyImageKHR != NULL && _glEGLImageTargetTexture2DOES != NULL;
	return initialized;
}
void _destroyAll() {
	for(int i = 0; i < MAX_BUFFERS; i++) {
		if(buffers[i] != NULL)
			_destroyEGLImage(i);
	}
}
void _destroyEGLImage(int index) {
	pthread_mutex_lock(&mutex);
	count--;
	ALOGI("%s: Destroying EGLImage with index: %d, count: %d", __func__, index, count);
	buffers[index] = NULL;
	if(eglImages[index] != NULL && eglDisplay != NULL)
		_eglDestroyImageKHR(eglDisplay, eglImages[index]);
	pthread_mutex_unlock(&mutex);
}
int _getStride(int index) {
	return buffers[index]->getStride();
}

void* _readPixels(int index) {
	void* pixels;
	buffers[index]->lock(GraphicBuffer::USAGE_SW_READ_OFTEN, &pixels);
	return pixels;
}

void* _writePixels(int index) {
	void* pixels;
	buffers[index]->lock(GraphicBuffer::USAGE_SW_WRITE_OFTEN, &pixels);
	return pixels;
}
void _unlockPixels(int index) {
	buffers[index]->unlock();
}
int _createEGLImage(int width, int height, EGLDisplay display, int write) {
	if(!initialize())
		return -1;

	pthread_mutex_lock(&mutex);
	int index = 0;
	for (int i = 0; i < MAX_BUFFERS; i++) {
		if(buffers[index] != NULL)
			index++;
		else
			break;
	}

	if(index >= MAX_BUFFERS) {
		ALOGI("%s: All EGLImage indices taken", __func__);
		return -1;
	}
	buffers[index] = (write == 1) ?
			new GraphicBuffer(width, height, HAL_PIXEL_FORMAT_RGBA_8888, GraphicBuffer::USAGE_SW_WRITE_OFTEN | GraphicBuffer::USAGE_HW_TEXTURE) :
    		new GraphicBuffer(width, height, HAL_PIXEL_FORMAT_RGBA_8888, GraphicBuffer::USAGE_SW_READ_OFTEN | GraphicBuffer::USAGE_HW_TEXTURE);
    count++;
	pthread_mutex_unlock(&mutex);
	ALOGI("%s: Created EGLImage with index %u", __func__, index);
    EGLint eglImageAttributes[] = {EGL_IMAGE_PRESERVED_KHR, EGL_FALSE, EGL_NONE};
    EGLClientBuffer nativeBuffer = buffers[index]->getNativeBuffer();
    eglImages[index] = _eglCreateImageKHR(display, EGL_NO_CONTEXT, EGL_NATIVE_BUFFER_ANDROID,
    		nativeBuffer, eglImageAttributes);
    _glEGLImageTargetTexture2DOES(GL_TEXTURE_2D, eglImages[index]);
    eglDisplay = display;
    //ALOGI("%s: ERROR? : %d", __func__, eglGetError());
    return index;
}



};
