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

use ooc-math
use ooc-base
use ooc-collections
use ooc-draw
use ooc-draw-gpu
import backend/gles3/[Fbo, Quad, Texture]
import OpenGLBgr, Map/OpenGLMap, OpenGLBgra, OpenGLUv, OpenGLMonochrome, OpenGLContext

OpenGLCanvas: class extends GpuCanvas {
	_renderTarget: Fbo
	context ::= this _context as OpenGLContext
	init: func (image: GpuPacked, context: GpuContext) {
		super(image, context)
		this _renderTarget = Fbo create(image texture _backend as Texture, image size)
	}
	free: override func {
		this _renderTarget free()
		super()
	}
	_bind: override func { this _renderTarget bind() }
	_unbind: override func { this _renderTarget unbind() }
	onRecycle: func { this _renderTarget invalidate() }
	clear: override func {
		this _bind()
		Fbo setClearColor(this clearColor red as Float / 255)
		this _renderTarget clear()
		this _unbind()
	}
	readPixels: override func -> ByteBuffer { this _renderTarget readPixels() }
}
