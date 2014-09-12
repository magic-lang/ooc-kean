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

import lib/gles
import TextureBin
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
  _eglImage: Int

  _textureBin: static TextureBin
  textureBin: static TextureBin { get { if(This _textureBin == null) { This _textureBin = TextureBin new() } This _textureBin } }
  init: func~nullTexture (type: TextureType, width: UInt, height: UInt) {
    this width = width
    this height = height
    this type = type
    this _setInternalFormats(type)
  }
  dispose: func {
    //glDeleteTextures(1, _backend&)
    This textureBin add(this)
  }
  bind: func (unit: UInt) {
    glActiveTexture(GL_TEXTURE0 + unit)
    glBindTexture(GL_TEXTURE_2D, _backend)
  }
  unbind: func {
    glBindTexture(GL_TEXTURE_2D, 0)
  }
  uploadPixels: func(pixels: Pointer) {
    glBindTexture(GL_TEXTURE_2D, _backend)
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, this width, this height, this format, GL_UNSIGNED_BYTE, pixels)
    unbind()
  }
  _setInternalFormats: func(type: TextureType) {
    match type {
      case TextureType monochrome =>
        this internalFormat = GL_R8
        this format = GL_RED
      case TextureType rgba =>
        this internalFormat = GL_RGBA8
        this format = GL_RGBA
      case TextureType rgb =>
        this internalFormat = GL_RGB8
        this format = GL_RGB
      case TextureType bgra =>
        this internalFormat = GL_RGBA8
        this format = GL_RGBA
      case TextureType bgr =>
        this internalFormat = GL_RGB8
        this format = GL_RGB
      case TextureType uv =>
        this internalFormat = GL_RG8
        this format = GL_RG
      case =>
        raise("Unknown texture format")
    }
  }
  _generate: func (pixels: Pointer) -> Bool {
    glGenTextures(1, _backend&)
    glBindTexture(GL_TEXTURE_2D, _backend)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
    glTexImage2D(GL_TEXTURE_2D, 0, this internalFormat, this width, this height, 0, this format, GL_UNSIGNED_BYTE, pixels)
    true
  }
  _generateEGL: func (context: Context) -> Bool {
    glGenTextures(1, _backend&)
    glBindTexture(GL_TEXTURE_2D, _backend)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
    this _eglImage = context generateEGLImage()
    this _eglImage != -1
  }
  createEGL: static func (width: UInt, height: UInt, context: Context) -> This {
    result := Texture new(TextureType rgba, width, height)
    success := result _generateEGL(context)
    success ? result : null
  }
  create: static func (type: TextureType, width: UInt, height: UInt, pixels := null) -> This {
    result := This textureBin find(type, width, height)
    success := true
    if (result == null) {
      result = Texture new(type, width, height)
      success = result _generate(pixels)
    }
    else if(pixels != null)
      result uploadPixels(pixels)
    success ? result : null
  }

}
