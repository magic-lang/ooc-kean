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
import include/egl
import include/gles
import Texture
EGLImage: class extends Texture {
	_eglBackend: Pointer
	_eglDisplay: Pointer
	_nativeBuffer: Pointer
	/* PRIVATE CONSTRUCTOR, USE STATIC CREATE FUNCTION!!! */
	init: func (type: TextureType, width: Int, height: Int, =_nativeBuffer, =_eglDisplay) {
		super(type, width, height)
		this _genTexture()
		this bindSibling()
		/*textureUnitCount: Int
		glGetTexParameteriv(GL_TEXTURE_EXTERNAL_OES, GL_REQUIRED_TEXTURE_IMAGE_UNITS_OES, textureUnitCount&)
		DebugPrint print("Texture units needed: " + textureUnitCount toString())
		glIsEnabled(GL_TEXTURE_EXTERNAL_OES)
		*/
	}
	free: func {
		This _eglDestroyImageKHR(this _eglDisplay, this _eglBackend)
		super()
	}
	bindSibling: func {
		eglImageAttributes := [EGL_IMAGE_PRESERVED_KHR, EGL_FALSE, EGL_NONE] as Int*
		this _eglBackend = This _eglCreateImageKHR(this _eglDisplay, EGL_NO_CONTEXT, EGL_NATIVE_BUFFER_ANDROID, this _nativeBuffer, eglImageAttributes)
		This _glEGLImageTargetTexture2DOES(this _target, this _eglBackend)
	}

	_eglCreateImageKHR: static Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
	_eglDestroyImageKHR: static Func(Pointer, Pointer)
	_glEGLImageTargetTexture2DOES: static Func(UInt, Pointer)
	_initialized: static Bool = false
	initialize: static func {
		if (!This _initialized) {
			This _eglCreateImageKHR = (eglGetProcAddress("eglCreateImageKHR" toCString()), null) as Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
			This _eglDestroyImageKHR = (eglGetProcAddress("eglDestroyImageKHR" toCString()), null) as Func(Pointer, Pointer)
			This _glEGLImageTargetTexture2DOES = (eglGetProcAddress("glEGLImageTargetTexture2DOES" toCString()), null) as Func(UInt, Pointer)
			This _initialized = true
		}
	}
	create: static func(type: TextureType, width: Int, height: Int, nativeBuffer: Pointer, display: Pointer) -> This {
		This initialize()
		result: This = null
		if (type == TextureType rgba || type == TextureType rgb || type == TextureType bgr || type == TextureType rgb || type == TextureType yv12) {
			result = This new(type, width, height, nativeBuffer, display)
		}
		result
	}
}
