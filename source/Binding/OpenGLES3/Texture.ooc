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

import gles

TextureType: enum {
  monochrome
  rgba
  rgb
}

Texture: class {
  backend: UInt
  width: UInt
  height: UInt
  type: TextureType
  format: UInt
  internalFormat: UInt

  createTexture: static func (type: TextureType, width: UInt, height: UInt) -> This {
    result := Texture new(type, width, height)
    if(result)
      result generateTexture(null)
    return result
  }

  loadTexture: static func (type: TextureType, width: UInt, height: UInt, pixels: Pointer) -> This {
    texture := Texture new(type, width, height)
    if(texture)
      texture generateTexture(pixels)
    return texture
  }

  init: func~nullTexture (type: TextureType, width: UInt, height: UInt) {
    this width = width
    this height = height
    this type = type

    this setInternalFormat(type)
  }

  init: func~Texture (type: TextureType, width: UInt, height: UInt, pixels: Pointer) {
    this width = width
    this height = height
    this type = type

    setInternalFormat(type)
  }

  dispose: func () {
    glDeleteTextures(1, backend&)
  }

  setInternalFormat: func(type: TextureType) {
    match type {
      case TextureType monochrome =>
        this internalFormat = GL_R8
        this format = GL_RED
      case TextureType rgba =>
        this internalFormat = GL_RGBA8
        this format = GL_RGBA
      case TextureType rgba =>
        this internalFormat = GL_RGB8
        this format = GL_RGB
      case =>
        raise("Unknown texture format")
    }
  }
  bind: func {
    glBindTexture(GL_TEXTURE_2D, backend)
  }

  unBind: func {
    glBindTexture(GL_TEXTURE_2D, 0)
  }

  generateTexture: func(pixels: Pointer) {
    glGenTextures(1, backend&)
    glBindTexture(GL_TEXTURE_2D, backend)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)

    glTexImage2D(GL_TEXTURE_2D, 0, this internalFormat, this width, this height, 0, this format, GL_UNSIGNED_BYTE, pixels)

  }

  uploadPixels: func(pixels: Pointer) {
    bind()
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, this width, this height, format, GL_UNSIGNED_BYTE, pixels)
    unBind()
  }

}
