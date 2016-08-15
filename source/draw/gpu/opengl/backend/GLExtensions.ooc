/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import egl/egl

version(!gpuOff) {
GLExtensions: class {
	eglCreateImageKHR: static Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
	eglDestroyImageKHR: static Func(Pointer, Pointer)
	glEGLImageTargetTexture2DOES: static Func(UInt, Pointer)
	_initialized := static false
	initialize: static func {
		if (!This _initialized) {
			This eglCreateImageKHR = This _load("eglCreateImageKHR") as Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
			This eglDestroyImageKHR = This _load("eglDestroyImageKHR") as Func(Pointer, Pointer)
			This glEGLImageTargetTexture2DOES = This _load("glEGLImageTargetTexture2DOES") as Func(UInt, Pointer)
			This _initialized = true
		}
	}
	_load: static func (name: String) -> Closure {
		result := eglGetProcAddress(name toCString())
		if (result == null)
			Debug print("Failed to load OpenGL extension function: " + name)
		(result, null) as Closure
	}
}
}
