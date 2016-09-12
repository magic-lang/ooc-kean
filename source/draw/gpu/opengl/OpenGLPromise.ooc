/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use concurrent
import backend/[GLFence, GLContext, EGLNativeFence]
import OpenGLContext

version(!gpuOff) {
OpenGLPromise: class extends Promise {
	_fence: GLFence
	init: func (=_fence) { super() }
	init: func ~allocFence (context: OpenGLContext) { this init(context backend as GLContext createFence()) }
	free: override func {
		this _fence free()
		super()
	}
	sync: func { this _fence sync() }
	wait: override func (time: TimeSpan) -> Bool { this _fence clientWait(time toNanoseconds()) }
	getFileDescriptor: virtual func -> Int { -1 }
}

OpenGLNativeFencePromise: class extends OpenGLPromise {
	init: func (context: OpenGLContext) { super(EGLNativeFence new(context backend _eglDisplay)) }
	getFileDescriptor: override func -> Int { this _fence as EGLNativeFence duplicateFileDescriptor() }
}
}
