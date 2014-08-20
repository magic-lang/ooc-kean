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

import lib/gles, Texture


Fbo: class {
  backend: UInt
  targetTexture: Texture
  textureType: TextureType
  width: UInt
  height: UInt

  create: static func (type: TextureType, width: UInt, height: UInt) -> This {
    result := This new(type, width, height)
    if(result _generate(width, height))
      return result

    return null
  }


  init: func (type: TextureType, width: UInt, height: UInt) {
    this width = width
    this height = height
    this textureType = type
  }


  dispose: func () {
    targetTexture dispose()
    glDeleteFramebuffers(1, backend&)
  }

  bind: func {
    glBindFramebuffer(GL_FRAMEBUFFER, backend)
  }

  unbind: func {
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
  }

  clear: func {
    bind()
    glClear(GL_COLOR_BUFFER_BIT)
    unbind()
  }

  getResultCopy: func (outputPixels: Pointer) {
    bind()
    glPixelStorei(GL_PACK_ALIGNMENT, 1)
    glReadBuffer(GL_COLOR_ATTACHMENT0)
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, outputPixels)
    unbind()
  }

  _generate: func(width: UInt, height: UInt) -> Bool {
    this targetTexture = Texture create(this textureType, width, height)
    glGenFramebuffers(1, this backend&)
    glBindFramebuffer(GL_FRAMEBUFFER, this backend)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, this targetTexture getBackend(), 0);

    /* Check FBO status */
    status: UInt = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
    	raise("Framebuffer Object creation failed")
    }

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    return true

  }


}
