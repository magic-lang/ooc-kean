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

use geometry
use base
use collections
use draw
use draw-gpu
import backend/[GLFramebufferObject, GLTexture]
import OpenGLBgr, OpenGLMap, OpenGLBgra, OpenGLUv, OpenGLMonochrome, OpenGLContext, OpenGLPacked, OpenGLSurface

version(!gpuOff) {
OpenGLCanvas: class extends OpenGLSurface {
	_target: OpenGLPacked
	_renderTarget: GLFramebufferObject
	context ::= this _context as OpenGLContext
	draw: override func ~DrawState (drawState: DrawState) {
		gpuMap: GpuMap = drawState map as GpuMap ?? this context defaultMap
		viewport := (drawState viewport hasZeroArea) ? IntBox2D new(this size) : drawState viewport
		this context backend setViewport(viewport)
		gpuMap model = FloatTransform3D identity // TODO: set using a destination argument in drawState
		gpuMap view = _toLocal * drawState getTransformNormalized() * _toLocal
		gpuMap projection = FloatTransform3D createProjection(this _focalLength, this _nearPlane, this _farPlane, this _coordinateTransform)
		// Set opacity
		if (drawState opacity < 1.0f)
			this context backend blend(drawState opacity)
		else
			this context backend enableBlend(false)
		if (drawState inputImage)
			gpuMap add("texture0", drawState inputImage)
		gpuMap use()
		this _bind()
		this context drawQuad()
		this _unbind()
	}
	init: func (=_target, context: OpenGLContext) {
		super(this _target size, context, context defaultMap, IntTransform2D identity)
		this _renderTarget = context _backend createFramebufferObject(this _target _backend as GLTexture, this _target size)
	}
	free: override func {
		this _renderTarget free()
		super()
	}
	_bind: override func { this _renderTarget bind() }
	_unbind: override func { this _renderTarget unbind() }
	onRecycle: func { this _renderTarget invalidate() }
	fill: override func {
		this _bind()
		this _renderTarget setClearColor(this pen color)
		this _renderTarget clear()
		this _unbind()
	}
	readPixels: override func -> ByteBuffer { this _renderTarget readPixels() }
}
}
