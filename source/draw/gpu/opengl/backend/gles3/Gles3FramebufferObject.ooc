/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use draw
import external/gles3
import ../GLFramebufferObject
import Gles3Texture, Gles3Debug

version(!gpuOff) {
Gles3FramebufferObject: class extends GLFramebufferObject {
	init: func (._size) { super(_size) }
	free: override func {
		version(debugGL) { validateStart("FramebufferObject free") }
		glDeleteFramebuffers(1, this _backend&)
		version(debugGL) { validateEnd("FramebufferObject free") }
		super()
	}
	bind: override func {
		version(debugGL) { validateStart("FramebufferObject bind") }
		glBindFramebuffer(GL_FRAMEBUFFER, this _backend)
		version(debugGL) { validateEnd("FramebufferObject bind") }
	}
	unbind: override func {
		version(debugGL) { validateStart("FramebufferObject unbind") }
		glBindFramebuffer(GL_FRAMEBUFFER, 0)
		version(debugGL) { validateEnd("FramebufferObject unbind") }
	}
	setClearColor: override func (color: ColorRgba) {
		version(debugGL) { validateStart("FramebufferObject setClearColor") }
		tuple := color normalized
		glClearColor(tuple a, tuple b, tuple c, tuple d)
		version(debugGL) { validateEnd("FramebufferObject setClearColor") }
	}
	readPixels: override func (buffer: ByteBuffer) {
		version(debugGL) { validateStart("FramebufferObject readPixels") }
		pointer := buffer pointer
		this bind()
		glPixelStorei(GL_PACK_ALIGNMENT, 1)
		glReadBuffer(GL_COLOR_ATTACHMENT0)
		glReadPixels(0, 0, this size x, this size y, GL_RGBA, GL_UNSIGNED_BYTE, pointer)
		this unbind()
		version(debugGL) { validateEnd("FramebufferObject readPixels") }
	}
	setTarget: func (texture: Gles3Texture) {
		version(debugGL) { validateStart("FramebufferObject setTarget") }
		glBindFramebuffer(GL_FRAMEBUFFER, this _backend)
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture _backend, 0)
		glBindFramebuffer(GL_FRAMEBUFFER, 0)
		version(debugGL) { validateEnd("FramebufferObject setTarget") }
	}
	_generate: func ~fromTextures (texture: Gles3Texture) -> Bool {
		version(debugGL) { validateStart("FramebufferObject _generate") }
		glGenFramebuffers(1, this _backend&)
		this bind()
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture _backend, 0)
		status: UInt = glCheckFramebufferStatus(GL_FRAMEBUFFER)
		if (status != GL_FRAMEBUFFER_COMPLETE) {
			statusMessage := getErrorMessage(status)
			errorMessage := "glCheckFramebufferStatus failed with status: " + statusMessage + " for texture of size " +
			texture size x toString() + " x " + texture size y toString()
			Debug error(errorMessage)
		}
		this unbind()
		version(debugGL) { validateEnd("FramebufferObject _generate") }
		true
	}
	invalidate: override func {
		version(debugGL) { validateStart("FramebufferObject invalidate") }
		this bind()
		att: UInt = GL_COLOR_ATTACHMENT0
		glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, att&)
		this unbind()
		version(debugGL) { validateEnd("FramebufferObject invalidate") }
	}
	scissor: static func (x, y, width, height: Int) {
		version(debugGL) { validateStart("FramebufferObject scissor") }
		glScissor(x, y, width, height)
		version(debugGL) { validateEnd("FramebufferObject scissor") }
	}
	clear: static final override func {
		version(debugGL) { validateStart("FramebufferObject clear") }
		glClear(GL_COLOR_BUFFER_BIT)
		version(debugGL) { validateEnd("FramebufferObject clear") }
	}
	finish: static func {
		version(debugGL) { validateStart("FramebufferObject finish") }
		glFinish()
		version(debugGL) { validateEnd("FramebufferObject finish") }
	}
	flush: static func {
		version(debugGL) { validateStart("FramebufferObject flush") }
		glFlush()
		version(debugGL) { validateEnd("FramebufferObject flush") }
	}
}
}
