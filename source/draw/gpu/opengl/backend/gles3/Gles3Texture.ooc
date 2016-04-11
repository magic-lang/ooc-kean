/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
import external/gles3
import ../GLTexture
import Gles3Debug

version(!gpuOff) {
Gles3Texture: class extends GLTexture {
	_format: UInt
	_internalFormat: UInt
	_bytesPerPixel: UInt

	init: func (._type, ._size) {
		version(debugGL) { validateStart("Texture init") }
		super(_type, _size)
		this _target = GL_TEXTURE_2D
		this _setInternalFormats(this _type)
		version(debugGL) { validateEnd("Texture init") }
	}
	free: override func {
		version(debugGL) { validateStart("Texture free") }
		glDeleteTextures(1, this _backend&)
		version(debugGL) { validateEnd("Texture free") }
		super()
	}
	generateMipmap: override func {
		version(debugGL) { validateStart("Texture generateMipmap") }
		this bind(0)
		glGenerateMipmap(this _target)
		version(debugGL) { validateEnd("Texture generateMipmap") }
	}
	bind: override func (unit: UInt) {
		version(debugGL) { validateStart("Texture bind") }
		glActiveTexture(GL_TEXTURE0 + unit)
		glBindTexture(this _target, this _backend)
		version(debugGL) { validateEnd("Texture bind") }
	}
	unbind: override func {
		version(debugGL) { validateStart("Texture unbind") }
		glBindTexture(this _target, 0)
		version(debugGL) { validateEnd("Texture unbind") }
	}
	upload: override func (pixels: Pointer, stride: Int) {
		version(debugGL) { validateStart("Texture upload") }
		pixelStride := stride / this _bytesPerPixel
		glBindTexture(this _target, this _backend)
		if (pixelStride != this size x)
			glPixelStorei(GL_UNPACK_ROW_LENGTH, pixelStride)
		glTexSubImage2D(this _target, 0, 0, 0, this size x, this size y, this _format, GL_UNSIGNED_BYTE, pixels)
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		this unbind()
		version(debugGL) { validateEnd("Texture upload") }
	}
	_setInternalFormats: func (type: TextureType) {
		version(debugGL) { validateStart("Texture _setInternalFormats") }
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
	setMagFilter: override func (interpolation: InterpolationType) {
		version(debugGL) { validateStart("Texture setMagFilter") }
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
	setMinFilter: override func (interpolation: InterpolationType) {
		version(debugGL) { validateStart("Texture setMinFilter") }
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
		version(debugGL) { validateStart("Texture _genTexture") }
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
		version(debugGL) { validateStart("Texture _allocate") }
		pixelStride := stride / this _bytesPerPixel
		if (pixelStride != this size x)
			glPixelStorei(GL_UNPACK_ROW_LENGTH, pixelStride)
		glTexImage2D(this _target, 0, this _internalFormat, this size x, this size y, 0, this _format, GL_UNSIGNED_BYTE, pixels)
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		version(debugGL) { validateEnd("Texture _allocate") }
		true
	}
}
}
