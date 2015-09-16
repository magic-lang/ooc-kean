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

import include/gles3

NativeWindow: abstract class {
	_display: Pointer
	display: Pointer { get { _display } }
	_backend: Long
	backend: Long { get { _backend } }
	_width: UInt
	_height: UInt

	setViewport: func (x, y, width, height: UInt) { glViewport(x, y, width, height) }
	clear: func { glClear(GL_COLOR_BUFFER_BIT) }
	bind: func { glBindFramebuffer(GL_FRAMEBUFFER, 0) }
}
