/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
import egl/egl
import GLTexture, GLContext, GLExtensions, gles3/Gles3Debug

version(!gpuOff) {
EGLImage: class extends GLTexture {
	_eglBackend: Pointer
	_eglDisplay: Pointer
	_nativeBuffer: Pointer
	_backendTexture: GLTexture
	/* PRIVATE CONSTRUCTOR, USE STATIC CREATE FUNCTION!!! */
	init: func (type: TextureType, size: IntVector2D, =_nativeBuffer, context: GLContext) {
		super(type, size)
		this _eglDisplay = context _eglDisplay
		this _backendTexture = context createTexture(type, size, size x, null, false)
		this _backend = this _backendTexture _backend
		this _target = this _backendTexture _target
		this bindSibling()
	}
	free: override func {
		GLExtensions eglDestroyImageKHR(this _eglDisplay, this _eglBackend)
		this _backendTexture free()
		super()
	}
	bindSibling: func {
		version(debugGL) { validateStart("EGLImage eglCreateImageKHR") }
		eglImageAttributes := [EGL_IMAGE_PRESERVED_KHR, EGL_FALSE, EGL_NONE] as Int*
		this _eglBackend = GLExtensions eglCreateImageKHR(this _eglDisplay, EGL_NO_CONTEXT, EGL_NATIVE_BUFFER_ANDROID, this _nativeBuffer, eglImageAttributes)
		version(debugGL) { validateEnd("EGLImage eglCreateImageKHR") }
		if (this _eglBackend == EGL_NO_IMAGE_KHR)
			Debug error("EGL_NO_IMAGE_KHR returned")
		version(debugGL) { validateStart("EGLImage glEGLImageTargetTexture2DOES") }
		GLExtensions glEGLImageTargetTexture2DOES(this _backendTexture _target, this _eglBackend)
		version(debugGL) { validateEnd("EGLImage glEGLImageTargetTexture2DOES") }
	}
	generateMipmap: override func { this _backendTexture generateMipmap() }
	bind: override func (unit: UInt) { this _backendTexture bind(unit) }
	unbind: override func { this _backendTexture unbind() }
	upload: override func (pixels: Pointer, stride: Int) { this _backendTexture upload(pixels, stride) }
	setMagFilter: override func (interpolation: InterpolationType) { this _backendTexture setMagFilter(interpolation) }
	setMinFilter: override func (interpolation: InterpolationType) { this _backendTexture setMinFilter(interpolation) }
	create: static func (type: TextureType, size: IntVector2D, nativeBuffer: Pointer, context: GLContext) -> This {
		(type == TextureType Rgba || type == TextureType Rgb || type == TextureType External) ?
		This new(type, size, nativeBuffer, context) : null
	}
}
}
