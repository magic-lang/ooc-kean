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

import DisplayWindow
use ooc-draw-gpu
use ooc-math
use ooc-draw
use ooc-opengl
use ooc-x11

version((unix || apple) && !gpuOff) {
UnixWindow: class extends DisplayWindow {
	_xWindow: X11Window
	_openGLWindow: OpenGLWindow
	context ::= this _openGLWindow context
	init: func (size: IntSize2D, title: String) {
		super()
		this _xWindow = X11Window new(size, title)
		this _openGLWindow = OpenGLWindow new(this _xWindow)
	}
	free: override func {
		this _openGLWindow free()
		this _xWindow free()
		super()
	}
	draw: override func (image: Image) {
		this _openGLWindow draw(image as GpuImage)
	}
	refresh: override func {
		this _openGLWindow refresh()
	}
}
}
