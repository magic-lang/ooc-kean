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
import include/gles
import Context

TextureType: enum {
	monochrome
	rgba
	rgb
	bgr
	bgra
	uv
}

Texture: class {
	_backend: UInt
	backend: UInt { get { this _backend } }
	width: UInt
	height: UInt
	type: TextureType
	format: UInt
	internalFormat: UInt
	_bytesPerPixel: UInt

	init: func (type: TextureType, width: UInt, height: UInt) {
		this width = width
		this height = height
		this type = type
		this _setInternalFormats(type)
	}
	dispose: func {
		this internalDispose()
	}
	internalDispose: func {
		glDeleteTextures(1, _backend&)
	}
	generateMipmap: func {
		this bind(0)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST)
		glGenerateMipmap(GL_TEXTURE_2D)
	}
	bind: func (unit: UInt) {
		glActiveTexture(GL_TEXTURE0 + unit)
		glBindTexture(GL_TEXTURE_2D, this _backend)
	}
	unbind: func {
		glBindTexture(GL_TEXTURE_2D, 0)
	}
	uploadPixels: func(pixels: Pointer, stride: Int) {
		pixelStride := stride / this _bytesPerPixel
		glBindTexture(GL_TEXTURE_2D, this _backend)
		if (pixelStride != this width) {
			glPixelStorei(GL_UNPACK_ROW_LENGTH, pixelStride)
		}
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, this width, this height, this format, GL_UNSIGNED_BYTE, pixels)
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		unbind()
	}
	_setInternalFormats: func(type: TextureType) {
		match type {
			case TextureType monochrome =>
				this internalFormat = GL_R8
				this format = GL_RED
				this _bytesPerPixel = 1
			case TextureType rgba =>
				this internalFormat = GL_RGBA8
				this format = GL_RGBA
				this _bytesPerPixel = 4
			case TextureType rgb =>
				this internalFormat = GL_RGB8
				this format = GL_RGB
				this _bytesPerPixel = 3
			case TextureType bgra =>
				this internalFormat = GL_RGBA8
				this format = GL_RGBA
				this _bytesPerPixel = 4
			case TextureType bgr =>
				this internalFormat = GL_RGB8
				this format = GL_RGB
				this _bytesPerPixel = 3
			case TextureType uv =>
				this internalFormat = GL_RG8
				this format = GL_RG
				this _bytesPerPixel = 2
			case =>
				raise("Unknown texture format")
		}
	}
	_generate: func (pixels: Pointer, stride: Int, allocate := true) -> Bool {
		glGenTextures(1, _backend&)
		glBindTexture(GL_TEXTURE_2D, _backend)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
		if (allocate) {
			pixelStride := stride / this _bytesPerPixel
			if (pixelStride != this width) {
				glPixelStorei(GL_UNPACK_ROW_LENGTH, pixelStride)
			}
			glTexImage2D(GL_TEXTURE_2D, 0, this internalFormat, this width, this height, 0, this format, GL_UNSIGNED_BYTE, pixels)
			glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		}
		true
	}
	create: static func (type: TextureType, width: UInt, height: UInt, stride: UInt, pixels := null, allocate : Bool = true) -> This {
		result := Texture new(type, width, height)
		success := result _generate(pixels, stride, allocate)
		success ? result : null
	}

}
