/*
 * EGLImage.h
 *
 *  Created on: 10 sep 2014
 *      Author: ewestergren
 */

#ifndef EGLIMAGE_H_
#define EGLIMAGE_H_

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <GLES3/gl3ext.h>
#include <GLES2/gl2ext.h>
#include <stddef.h>
#include <GraphicBuffer.h>
#include <utils/Errors.h>
#include <utils/Log.h>
//using namespace android;
#define MAX_BUFFERS 64
namespace android {
extern int _createEGLImage(int width, int height, EGLDisplay display, int write);
extern void _destroyEGLImage(int index);
extern void* _readPixels(int index);
extern void* _writePixels(int index);
extern void _unlockPixels(int index);
extern int _getStride(int index);
extern void _destroyAll();
};
#endif /* EGLIMAGE_H_ */
