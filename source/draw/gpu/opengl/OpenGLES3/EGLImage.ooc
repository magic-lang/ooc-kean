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
import include/egl
import include/gles
import Texture
EGLImage: class extends Texture {
	_eglBackend: Pointer
	_eglDisplay: Pointer
	_eglCreateImageKHR: static Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
	_eglDestroyImageKHR: static Func(Pointer, Pointer)
	_glEGLImageTargetTexture2DOES: static Func(UInt, Pointer)
	_initialized: static Bool = false
	/* PRIVATE CONSTRUCTOR, USE STATIC CREATE FUNCTION!!! */
	init: func (type: TextureType, width: Int, height: Int, nativeBuffer: Pointer, display: Pointer) {
		super(type, width, height)
		this _eglDisplay = display
		this _generate(null, width * 4, false)
		eglImageAttributes := [EGL_IMAGE_PRESERVED_KHR, EGL_FALSE, EGL_NONE] as Int*
		this _eglBackend = This _eglCreateImageKHR(display, EGL_NO_CONTEXT, EGL_NATIVE_BUFFER_ANDROID, nativeBuffer, eglImageAttributes)
		This _glEGLImageTargetTexture2DOES(GL_TEXTURE_2D, this _eglBackend)
	}
	dispose: func {
		super()
		This _eglDestroyImageKHR(this _eglDisplay, this _eglBackend)
	}
	initialize: static func -> Bool {
		This _eglCreateImageKHR = (eglGetProcAddress("eglCreateImageKHR" toCString()), null) as Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
		This _eglDestroyImageKHR = (eglGetProcAddress("eglDestroyImageKHR" toCString()), null) as Func(Pointer, Pointer)
		This _glEGLImageTargetTexture2DOES = (eglGetProcAddress("glEGLImageTargetTexture2DOES" toCString()), null) as Func(UInt, Pointer)
		This _initialized = true
	}
	create: static func(type: TextureType, width: Int, height: Int, nativeBuffer: Pointer, display: Pointer) -> This {
		result: This = null
		if (type == TextureType rgba || type == TextureType rgb || type == TextureType bgr || type == TextureType rgb) {
			if (!This _initialized)
				This initialize()
			result = This _initialized ? This new(type, width, height, nativeBuffer, display) : null
		}
		else
			raise("EGLImage only has support for RGBA and RGB")
		result
	}
}
