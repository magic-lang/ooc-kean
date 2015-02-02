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

import include/gles
import os/Time

Fence: class {
	_backend: Pointer
	active ::= this _backend != null

	init: func
	clientWait: func (timeout: UInt) {
		glClientWaitSync(this _backend, 0, timeout)
	}
	wait: func {
		while(!this active)
			Time sleepMilli(1)
		glClientWaitSync(this _backend, 0, GL_TIMEOUT_IGNORED)
	}
	dispose: func () {
		glDeleteSync(this _backend)
	}
	sync: func {
		if(this _backend != null)
			glDeleteSync(this _backend)
		this _backend = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0)
	}

}
