/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-base
use ooc-geometry
import egl/egl
import GLTexture, GLContext

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
		This _eglDestroyImageKHR(this _eglDisplay, this _eglBackend)
		this _backendTexture free()
		super()
	}
	bindSibling: func {
		eglImageAttributes := [EGL_IMAGE_PRESERVED_KHR, EGL_FALSE, EGL_NONE] as Int*
		this _eglBackend = This _eglCreateImageKHR(this _eglDisplay, EGL_NO_CONTEXT, EGL_NATIVE_BUFFER_ANDROID, this _nativeBuffer, eglImageAttributes)
		This _glEGLImageTargetTexture2DOES(this _backendTexture _target, this _eglBackend)
	}
	generateMipmap: override func { this _backendTexture generateMipmap() }
	bind: override func (unit: UInt) { this _backendTexture bind(unit) }
	unbind: override func { this _backendTexture unbind() }
	upload: override func (pixels: Pointer, stride: Int) { this _backendTexture upload(pixels, stride) }
	setMagFilter: override func (interpolation: InterpolationType) { this _backendTexture setMagFilter(interpolation) }
	setMinFilter: override func (interpolation: InterpolationType) { this _backendTexture setMinFilter(interpolation) }

	_eglCreateImageKHR: static Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
	_eglDestroyImageKHR: static Func(Pointer, Pointer)
	_glEGLImageTargetTexture2DOES: static Func(UInt, Pointer)
	_initialized: static Bool = false
	initialize: static func {
		This _eglCreateImageKHR = (eglGetProcAddress("eglCreateImageKHR" toCString()), null) as Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
		This _eglDestroyImageKHR = (eglGetProcAddress("eglDestroyImageKHR" toCString()), null) as Func(Pointer, Pointer)
		This _glEGLImageTargetTexture2DOES = (eglGetProcAddress("glEGLImageTargetTexture2DOES" toCString()), null) as Func(UInt, Pointer)
		This _initialized = true
	}
	create: static func (type: TextureType, size: IntVector2D, nativeBuffer: Pointer, context: GLContext) -> This {
		if (!This _initialized)
			This initialize()
		(type == TextureType Rgba || type == TextureType Rgb || type == TextureType Bgr || type == TextureType Yv12) ?
		This new(type, size, nativeBuffer, context) : null
	}
}
}
