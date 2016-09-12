/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import egl/egl
import GLExtensions, GLFence, gles3/Gles3Debug

version(!gpuOff) {
EGLNativeFence: class extends GLFence {
	_display: Pointer
	init: func (=_display) { super() }
	free: override func {
		version(debugGL) { validateStart("EGLNativeFence eglDestroySyncKHR") }
		GLExtensions eglDestroySyncKHR(this _display, this _backend)
		version(debugGL) { validateEnd("EGLNativeFence eglDestroySyncKHR") }
		super()
	}
	sync: override func {
		version(debugGL) { validateStart("EGLNativeFence eglCreateSyncKHR") }
		this _backend = GLExtensions eglCreateSyncKHR(this _display, EGL_SYNC_NATIVE_FENCE_ANDROID, null as Int*)
		version(debugGL) { validateEnd("EGLNativeFence eglCreateSyncKHR") }
	}
	clientWait: override func (timeout: ULong = ULong maximumValue) -> Bool {
		version(debugGL) { validateStart("EGLNativeFence eglClientWaitSyncKHR") }
		result := GLExtensions eglClientWaitSyncKHR(this _display, this _backend, EGL_SYNC_FLUSH_COMMANDS_BIT_KHR, timeout)
		version(debugGL) { validateEnd("EGLNativeFence eglClientWaitSyncKHR") }
		result
	}
	wait: override func { Debug error("Wait unimplemented for EGLNativeFence") }
	duplicateFileDescriptor: func -> Int {
		version(debugGL) { validateStart("EGLNativeFence eglDupNativeFenceFDANDROID") }
		result := GLExtensions eglDupNativeFenceFDANDROID(this _display, this _backend)
		version(debugGL) { validateEnd("EGLNativeFence eglDupNativeFenceFDANDROID") }
		result
	}
}
}
