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

Vertex2d: class {
  positions: Float[2]
  textureCoordinates: Float[2]
}

Vao: class {
  backend: UInt

  createVao: static func (positions: Float*, textureCoordinates: Float*, vertexCount: UInt) -> This {
    result := This new()
    if (result)
      result generateVao(positions, texcoords, numVertices)
    return result
  }


  init: func () {
  }


  dispose: func () {
  }

  bind: func {
    glBindVertexArray(backend);
  }

  unBind: func {
    glBindVertexArray(0);
  }

  generateVao: func(positions: Float*, textureCoordinates: Float*, vertexCount: UInt) {


  }


}
