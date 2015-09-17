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
import include/gles3
import ../GLFramebufferObject
import Gles3Texture, Gles3Debug

Gles3FramebufferObject: class extends GLFramebufferObject {
	_size: IntSize2D
	size ::= this _size
	_backend: UInt

	init: func (=_size)
	free: func {
		glDeleteFramebuffers(1, _backend&)
	}
	bind: func { glBindFramebuffer(GL_FRAMEBUFFER, this _backend) }
	unbind: func { glBindFramebuffer(GL_FRAMEBUFFER, 0) }
	scissor: static func (x, y, width, height: Int) { glScissor(x, y, width, height) }
	clear: static func { glClear(GL_COLOR_BUFFER_BIT) }
	setClearColor: func (color: Float) { glClearColor(color, color, color, color) }
	readPixels: func -> ByteBuffer {
		version(debugGL) { validateStart() }
		width := this size width
		height := this size height
		buffer := ByteBuffer new(width * height * 4)
		ptr := buffer pointer
		this bind()
		glPixelStorei(GL_PACK_ALIGNMENT, 1)
		glReadBuffer(GL_COLOR_ATTACHMENT0)
		glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, ptr)
		this unbind()
		version(debugGL) { validateEnd("fbo readPixels") }
		buffer
	}
	setTarget: func (texture: Gles3Texture) {
		version(debugGL) { validateStart() }
		glBindFramebuffer(GL_FRAMEBUFFER, this _backend)
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture _backend, 0)
		glBindFramebuffer(GL_FRAMEBUFFER, 0)
		version(debugGL) { validateEnd("fbo setTarget") }
	}
	_generate: func ~fromTextures (texture: Gles3Texture) -> Bool {
		version(debugGL) { validateStart() }
		glGenFramebuffers(1, this _backend&)
		this bind()
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture _backend, 0)
		status: UInt = glCheckFramebufferStatus(GL_FRAMEBUFFER)
		if (status != GL_FRAMEBUFFER_COMPLETE) {
			statusMessage := getErrorMessage(status)
			errorMessage := "Framebuffer Object creation failed with status: " + statusMessage + " for texture of size " +
			texture size width toString() + " x " + texture size height toString()
			Debug print(errorMessage)
			raise(errorMessage)
		}
		this unbind()
		version(debugGL) { validateEnd("fbo _generate") }
		true
	}
	finish: static func {
		version(debugGL) { validateStart() }
		glFinish()
		version(debugGL) { validateEnd("fbo finish") }
	}
	flush: static func {
		version(debugGL) { validateStart() }
		glFlush()
		version(debugGL) { validateEnd("fbo flush") }
	}
	invalidate: func {
		version(debugGL) { validateStart() }
		this bind()
		att: UInt = GL_COLOR_ATTACHMENT0
		glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, att&)
		this unbind()
		version(debugGL) { validateEnd("fbo invalidate") }
	}
}
