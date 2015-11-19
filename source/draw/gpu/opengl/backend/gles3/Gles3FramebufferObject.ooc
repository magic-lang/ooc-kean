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
use ooc-math
use ooc-draw
import include/gles3
import ../GLFramebufferObject
import Gles3Texture, Gles3Debug

version(!gpuOff) {
Gles3FramebufferObject: class extends GLFramebufferObject {
	init: func (=_size) { super() }
	free: override func {
		version(debugGL) { validateStart("FramebufferObject free") }
		glDeleteFramebuffers(1, _backend&)
		version(debugGL) { validateEnd("FramebufferObject free") }
		super()
	}
	bind: func {
		version(debugGL) { validateStart("FramebufferObject bind") }
		glBindFramebuffer(GL_FRAMEBUFFER, this _backend)
		version(debugGL) { validateEnd("FramebufferObject bind") }
	}
	unbind: func {
		version(debugGL) { validateStart("FramebufferObject unbind") }
		glBindFramebuffer(GL_FRAMEBUFFER, 0)
		version(debugGL) { validateEnd("FramebufferObject unbind") }
	}
	scissor: static func (x, y, width, height: Int) {
		version(debugGL) { validateStart("FramebufferObject scissor") }
		glScissor(x, y, width, height)
		version(debugGL) { validateEnd("FramebufferObject scissor") }
	}
	clear: static func {
		version(debugGL) { validateStart("FramebufferObject clear") }
		glClear(GL_COLOR_BUFFER_BIT)
		version(debugGL) { validateEnd("FramebufferObject clear") }
	}
	setClearColor: func (color: ColorBgra) {
		version(debugGL) { validateStart("FramebufferObject setClearColor") }
		tuple := color normalized
		glClearColor(tuple c, tuple b, tuple a, tuple d)
		version(debugGL) { validateEnd("FramebufferObject setClearColor") }
	}
	readPixels: func -> ByteBuffer {
		version(debugGL) { validateStart("FramebufferObject readPixels") }
		width := this size width
		height := this size height
		buffer := ByteBuffer new(width * height * 4)
		ptr := buffer pointer
		this bind()
		glPixelStorei(GL_PACK_ALIGNMENT, 1)
		glReadBuffer(GL_COLOR_ATTACHMENT0)
		glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, ptr)
		this unbind()
		version(debugGL) { validateEnd("FramebufferObject readPixels") }
		buffer
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
			texture size width toString() + " x " + texture size height toString()
			Debug raise(errorMessage)
		}
		this unbind()
		version(debugGL) { validateEnd("FramebufferObject _generate") }
		true
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
	invalidate: func {
		version(debugGL) { validateStart("FramebufferObject invalidate") }
		this bind()
		att: UInt = GL_COLOR_ATTACHMENT0
		glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, att&)
		this unbind()
		version(debugGL) { validateEnd("FramebufferObject invalidate") }
	}
}
}
