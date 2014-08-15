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


Fence: class {
  backend: Pointer

  clientWait: static func (fence: This, timeout: UInt) {
    glClientWaitSync(fence, 0, timeout)
  }

  wait: static func (fence: This) {
    glClientWaitSync(fence, 0, GL_TIMEOUT_IGNORED)
  }


  dispose: func () {
    glDeleteSync(backend)
  }

  generate: func() {
    this backend = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0)
  }

  create: static func () -> This {
    result := This new()
    if (result)
      result generate()
    return result
  }



}
