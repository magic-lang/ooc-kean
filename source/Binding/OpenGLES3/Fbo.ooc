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
  _backend: UInt

  init: func

  dispose: func {
    glDeleteFramebuffers(1, _backend&)
  }

  bind: func {
    glBindFramebuffer(GL_FRAMEBUFFER, _backend)
  }

  unbind: func {
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
  }

  clear: func {
    glClear(GL_COLOR_BUFFER_BIT)
  }

  getResultCopy: func (outputPixels: Pointer) {
    //FIXME: Only working for RGBA
    return
    //bind()
    //glPixelStorei(GL_PACK_ALIGNMENT, 1)
    //glReadBuffer(GL_COLOR_ATTACHMENT0)
    //glReadPixels(0, 0, width, height, GL_RGBA, GL_FLOAT, outputPixels)
    //glGetError() toString() println()
    //unbind()
  }

  _generate: func ~fromTextures (textures: Texture[]) -> Bool {
    glGenFramebuffers(1, this _backend&)
    glBindFramebuffer(GL_FRAMEBUFFER, this _backend)

    for(i in 0..textures length) {
      glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + i, GL_TEXTURE_2D, textures[i] _backend, 0)
    }

    /* Check FBO status */
    status: UInt = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
      raise("Framebuffer Object creation failed")
    }

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    true
  }

  create: static func (textures: Texture[]) -> This {
    result := This new()
    result _generate(textures) ? result : null
  }


}
