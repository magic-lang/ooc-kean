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
import lib/gles, Texture

Fbo: class {
  _backend: UInt
  _width: UInt
  _height: UInt

  init: func (=_width, =_height)
  dispose: func {
    glDeleteFramebuffers(1, _backend&)
  }
  bind: func {
    glBindFramebuffer(GL_FRAMEBUFFER, _backend)
    glViewport(0, 0, this _width, this _height)
  }
  unbind: func {
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
  }
  clear: func {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
  }
  getPixels: func (width: UInt, height: UInt, channels: UInt) -> ByteBuffer {
    buffer := ByteBuffer new(width * height * channels)
    ptr := buffer pointer
  	glBindFramebuffer(GL_FRAMEBUFFER, this _backend)
  	glPixelStorei(GL_PACK_ALIGNMENT, 1)
  	glReadBuffer(GL_COLOR_ATTACHMENT0)

    if (channels == 1)
  	  glReadPixels(0, 0, width / 4, height, GL_RGBA, GL_UNSIGNED_BYTE, ptr)
    else if (channels == 2)
  	  glReadPixels(0, 0, width / 2, height, GL_RGBA, GL_UNSIGNED_BYTE, ptr)
    else if (channels == 3)
      glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, ptr)
    else if (channels == 4)
      glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, ptr)

  	glBindFramebuffer(GL_FRAMEBUFFER, 0)
    buffer
  }
  _generate: func ~fromTextures (texture: Texture) -> Bool {
    glGenFramebuffers(1, this _backend&)
    glBindFramebuffer(GL_FRAMEBUFFER, this _backend)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture _backend, 0)

    status: UInt = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
      raise("Framebuffer Object creation failed")
    }

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    true
  }
  finish: static func {
    glFinish()
  }
  setViewport: static func (x: UInt, y: UInt, width: UInt, height: UInt) {
    glViewport(x, y, width, height)
  }
  create: static func (texture: Texture, width: UInt, height: UInt) -> This {
    result := This new(width, height)
    result _generate(texture) ? result : null
  }


}
