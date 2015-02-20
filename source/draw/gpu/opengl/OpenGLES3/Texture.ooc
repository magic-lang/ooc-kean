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
import include/gles, Debug
import Context

TextureType: enum {
	monochrome
	rgba
	rgb
	bgr
	bgra
	uv
	yv12
}

InterpolationType: enum {
	Nearest
	Linear
	LinearMipmapNearest
	LinearMipmapLinear
	NearestMipmapNearest
	NearestMipmapLinear
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
	_target: UInt = GL_TEXTURE_2D

	init: func (type: TextureType, width: UInt, height: UInt) {
		version(debugGL) { validateStart() }
		this width = width
		this height = height
		this type = type
		this _setInternalFormats(type)
		version(debugGL) { validateEnd("Texture init") }
	}
	free: func {
		version(debugGL) { validateStart() }
		glDeleteTextures(1, _backend&)
		version(debugGL) { validateEnd("Texture dispose") }
		super()
	}
	generateMipmap: func {
		version(debugGL) { validateStart() }
		this bind(0)
		glGenerateMipmap(GL_TEXTURE_2D)
		version(debugGL) { validateEnd("Texture generateMipmap") }
	}
	bind: func (unit: UInt) {
		version(debugGL) { validateStart() }
		glActiveTexture(GL_TEXTURE0 + unit)
		glBindTexture(GL_TEXTURE_2D, this _backend)
		version(debugGL) { validateEnd("Texture bind") }
	}
	unbind: func {
		version(debugGL) { validateStart() }
		glBindTexture(GL_TEXTURE_2D, 0)
		version(debugGL) { validateEnd("Texture unbind") }
	}
	upload: func (pixels: Pointer, stride: Int) {
		version(debugGL) { validateStart() }
		pixelStride := stride / this _bytesPerPixel
		glBindTexture(this _target, this _backend)
		if (pixelStride != this width) {
			glPixelStorei(GL_UNPACK_ROW_LENGTH, pixelStride)
		}
		glTexSubImage2D(this _target, 0, 0, 0, this width, this height, this format, GL_UNSIGNED_BYTE, pixels)
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		unbind()
		version(debugGL) { validateEnd("Texture upload") }
	}
	_setInternalFormats: func (type: TextureType) {
		version(debugGL) { validateStart() }
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
			case TextureType yv12 =>
				this internalFormat = GL_R8
				this format = GL_RED
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
	}
	_generate: func (pixels: Pointer, stride: Int, allocate := true) -> Bool {
		this _genTexture()
		if (allocate)
			this _allocate(pixels, stride)
		true
	}
	_allocate: func (pixels: Pointer, stride: Int) {
		pixelStride := stride / this _bytesPerPixel
		if (pixelStride != this width) {
			glPixelStorei(GL_UNPACK_ROW_LENGTH, pixelStride)
		}
		glTexImage2D(this _target, 0, this internalFormat, this width, this height, 0, this format, GL_UNSIGNED_BYTE, pixels)
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		version(debugGL) { validateEnd("Texture _allocate") }
		true
	}
	create: static func (type: TextureType, width: UInt, height: UInt, stride: UInt, pixels := null, allocate : Bool = true) -> This {
		version(debugGL) { validateStart() }
		result := Texture new(type, width, height)
		success := result _generate(pixels, stride, allocate)
		result = success ? result : null
		version(debugGL) { validateEnd("Texture create") }
		result
	}

}
