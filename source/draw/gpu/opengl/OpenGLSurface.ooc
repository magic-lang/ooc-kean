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

use collections
use ooc-geometry
use draw
use draw-gpu
import OpenGLContext, OpenGLPacked
import backend/GLRenderer

version(!gpuOff) {
OpenGLSurface: abstract class extends GpuSurface {
	context ::= this _context as OpenGLContext
	init: func (size: IntVector2D, context: OpenGLContext, defaultMap: GpuMap, coordinateTransform: IntTransform2D) {
		super(size, context, defaultMap, coordinateTransform)
	}
	_bind: abstract func
	_unbind: abstract func
	draw: override func (action: Func) {
		this _bind()
		this context backend setViewport(this viewport)
		if (this opacity < 1.0f)
			this context backend blend(this opacity)
		else if (this blend)
			this context backend blend()
		else
			this context backend enableBlend(false)
		action()
		this _unbind()
	}
	draw: override func ~WithoutBind (destination: IntBox2D, map: GpuMap) {
		map model = this _createModelTransform(destination)
		map view = this _view
		map projection = this _projection
		map use()
		f := func { this context drawQuad() }
		this draw(f)
		(f as Closure) free()
	}
	draw: override func ~GpuImage (image: GpuImage, source: IntBox2D, destination: IntBox2D, map: GpuMap) {
		map textureTransform = This _createTextureTransform(image size, source)
		this draw(destination, map)
	}
	drawLines: override func (pointList: VectorList<FloatPoint2D>) {
		f := func { this context drawLines(pointList, this _projection * this _toLocal, this pen) }
		this draw(f)
		(f as Closure) free()
	}
	drawPoints: override func (pointList: VectorList<FloatPoint2D>) {
		f := func { this context drawPoints(pointList, this _projection * this _toLocal, this pen) }
		this draw(f)
		(f as Closure) free()
	}
	draw: override func ~mesh (image: GpuImage, mesh: GpuMesh) {
		f := func {
			this context meshShader add("texture0", image)
			this context meshShader projection = this _projection
			this context meshShader use()
			mesh draw()
		}
		this draw(f)
		(f as Closure) free()
	}
}
}
