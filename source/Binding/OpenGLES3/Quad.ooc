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

import gles, Vao


Quad: class {
  vao: Vao

  positions := static [-1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0] as Float[]
  textureCoordinates := static [0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0] as Float[]

  create: static func () -> This {
    result := This new()
    if (result)
      result generateQuad()
    if(result vao)
      return result
    return null
  }


  init: func () {
  }


  dispose: func () {
    this vao dispose()
  }

  draw: func {
    vao bind()
  	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    vao unbind()
  }


  generateQuad: func() {
    vao = Vao create(Quad positions, Quad textureCoordinates, 4)
  }


}
