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
/*
Fence: class {
  _backend: Pointer

  init: func
  clientWait: func (timeout: UInt) {
    glClientWaitSync(this _backend, 0, timeout)
  }
  wait: func {
    glClientWaitSync(this _backend, 0, GL_TIMEOUT_IGNORED)
  }
  dispose: func () {
    glDeleteSync(_backend)
  }
  _generate: func -> Bool {
    this _backend = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0)
    true
  }
  create: static func -> This {
    result := This new()
    result _generate() ? result : null
  }

}
*/
