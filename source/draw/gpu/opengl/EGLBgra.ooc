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

use geometry
import GraphicBuffer, AndroidContext, OpenGLBgra
import backend/[GLTexture, GLContext, EGLImage]

version(!gpuOff) {
EGLBgra: class extends OpenGLBgra {
	_buffer: GraphicBuffer
	buffer ::= this _buffer
	init: func ~fromGraphicBuffer (=_buffer, context: AndroidContext) {
		super(EGLImage create(TextureType Rgba, this _buffer size, this _buffer nativeBuffer, context backend), context)
	}
	init: func ~fromSize (size: IntVector2D, context: AndroidContext) {
		this init(GraphicBuffer new(size, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage RenderTarget), context)
	}
	free: override func {
		this _recyclable = false
		this _buffer free()
		super()
	}
}
}
