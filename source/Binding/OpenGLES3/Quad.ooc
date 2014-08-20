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
 * along with This software. If not, see <http://www.gnu.org/licenses/>.
 */

import lib/gles, Vao


Quad: class {
  vao: static Vao

  initialize: static func () {
    positions := [-16.0f / 9.0f, -1.0f, -16.0f / 9.0f, 1.0f, 16.0f / 9.0f, -1.0f, 16.0f / 9.0f, 1.0f] as Float*
    textureCoordinates := [0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f] as Float*
    This vao = Vao create(positions, textureCoordinates, 4, 2)
  }

  dispose: static func () {
    This vao dispose()
  }

  draw: static func {
    if(This vao == null)
      This initialize()

    This vao bind()
  	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    This vao unbind()
  }


}
