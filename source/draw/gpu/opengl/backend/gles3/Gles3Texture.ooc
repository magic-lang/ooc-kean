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

use ooc-math
use ooc-base
import include/gles3
import ../GLTexture
import Gles3Debug

Gles3Texture: class extends GLTexture {
	_format: UInt
	_internalFormat: UInt
	_bytesPerPixel: UInt

	init: func (=_type, =_size) {
		version(debugGL) { validateStart() }
		super()
		_target = GL_TEXTURE_2D
		this _setInternalFormats(this _type)
		version(debugGL) { validateEnd("Texture init") }
	}
	free: override func {
		version(debugGL) { validateStart() }
		version(debugGL) { Debug print("Freeing OpenGL Texture") }
		glDeleteTextures(1, this _backend&)
		version(debugGL) { validateEnd("Texture free") }
		super()
	}
	generateMipmap: func {
		version(debugGL) { validateStart() }
		this bind(0)
		glGenerateMipmap(this _target)
		version(debugGL) { validateEnd("Texture generateMipmap") }
	}
	bind: func (unit: UInt) {
		version(debugGL) { validateStart() }
		glActiveTexture(GL_TEXTURE0 + unit)
		glBindTexture(this _target, this _backend)
		version(debugGL) { validateEnd("Texture bind") }
	}
	unbind: func {
		version(debugGL) { validateStart() }
		glBindTexture(this _target, 0)
		version(debugGL) { validateEnd("Texture unbind") }
	}
	upload: func (pixels: Pointer, stride: Int) {
		version(debugGL) { validateStart() }
		pixelStride := stride / this _bytesPerPixel
		glBindTexture(this _target, this _backend)
		if (pixelStride != this size width) {
			glPixelStorei(GL_UNPACK_ROW_LENGTH, pixelStride)
		}
		glTexSubImage2D(this _target, 0, 0, 0, this size width, this size height, this _format, GL_UNSIGNED_BYTE, pixels)
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		unbind()
		version(debugGL) { validateEnd("Texture upload") }
	}
	_setInternalFormats: func (type: TextureType) {
		version(debugGL) { validateStart() }
		match type {
			case TextureType Monochrome =>
				this _internalFormat = GL_R8
				this _format = GL_RED
				this _bytesPerPixel = 1
			case TextureType Rgba =>
				this _internalFormat = GL_RGBA8
				this _format = GL_RGBA
				this _bytesPerPixel = 4
			case TextureType Rgb =>
				this _internalFormat = GL_RGB8
				this _format = GL_RGB
				this _bytesPerPixel = 3
			case TextureType Bgra =>
				this _internalFormat = GL_RGBA8
				this _format = GL_RGBA
				this _bytesPerPixel = 4
			case TextureType Bgr =>
				this _internalFormat = GL_RGB8
				this _format = GL_RGB
				this _bytesPerPixel = 3
			case TextureType Uv =>
				this _internalFormat = GL_RG8
				this _format = GL_RG
				this _bytesPerPixel = 2
			case TextureType Yv12 =>
				this _internalFormat = GL_R8
				this _format = GL_RED
				this _bytesPerPixel = 1
				this _target = GL_TEXTURE_EXTERNAL_OES
			case =>
				raise("Unknown texture format")
		}
		version(debugGL) { validateEnd("Texture _setInternalFormats") }
	}
	setMagFilter: func (interpolation: InterpolationType) {
		version(debugGL) { validateStart() }
		this bind(0)
		interpolationType := match (interpolation) {
			case InterpolationType Nearest => GL_NEAREST
			case InterpolationType Linear => GL_LINEAR
			case => raise("Interpolation type not supported for MagFilter"); -1
		}
		glTexParameteri(this _target, GL_TEXTURE_MAG_FILTER, interpolationType)
		this unbind()
		version(debugGL) { validateEnd("Texture setMagFilter") }
	}
	setMinFilter: func (interpolation: InterpolationType) {
		version(debugGL) { validateStart() }
		this bind(0)
		interpolationType := match (interpolation) {
			case InterpolationType Nearest => GL_NEAREST
			case InterpolationType Linear => GL_LINEAR
			case InterpolationType LinearMipmapNearest => GL_LINEAR_MIPMAP_NEAREST
			case InterpolationType LinearMipmapLinear => GL_LINEAR_MIPMAP_LINEAR
			case InterpolationType NearestMipmapNearest => GL_NEAREST_MIPMAP_NEAREST
			case InterpolationType NearestMipmapLinear => GL_NEAREST_MIPMAP_LINEAR
			case => raise("Interpolation type not supported for MinFilter"); -1
		}
		glTexParameteri(this _target, GL_TEXTURE_MIN_FILTER, interpolationType)
		this unbind()
		version(debugGL) { validateEnd("Texture setMinFilter") }
	}
	_genTexture: func {
		version(debugGL) { validateStart() }
		glGenTextures(1, this _backend&)
		glBindTexture(this _target, this _backend)
		glTexParameteri(this _target, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
		glTexParameteri(this _target, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
		glTexParameteri(this _target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
		glTexParameteri(this _target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
		version(debugGL) { validateEnd("Texture _genTexture") }
	}
	_generate: func (pixels: Pointer, stride: Int, allocate := true) -> Bool {
		this _genTexture()
		if (allocate)
			this _allocate(pixels, stride)
		true
	}
	_allocate: func (pixels: Pointer, stride: Int) {
		version(debugGL) { Debug print("Allocating OpenGL Texture") }
		version(debugGL) { validateStart() }
		pixelStride := stride / this _bytesPerPixel
		if (pixelStride != this size width) {
			glPixelStorei(GL_UNPACK_ROW_LENGTH, pixelStride)
		}
		glTexImage2D(this _target, 0, this _internalFormat, this size width, this size height, 0, this _format, GL_UNSIGNED_BYTE, pixels)
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		version(debugGL) { validateEnd("Texture _allocate") }
		true
	}
}
