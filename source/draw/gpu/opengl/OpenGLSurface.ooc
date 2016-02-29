/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use geometry
use draw
use draw-gpu
import OpenGLContext, OpenGLPacked
import backend/GLRenderer

version(!gpuOff) {
OpenGLSurface: abstract class extends GpuCanvas {
	context ::= this _context as OpenGLContext
	init: func (size: IntVector2D, context: OpenGLContext, defaultMap: Map, coordinateTransform: IntTransform2D) {
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
	draw: override func ~WithoutBind (destination: IntBox2D, map: Map) {
		map model = this _createModelTransform(destination)
		map view = this _view
		map projection = this _projection
		map use(null)
		f := func { this context drawQuad() }
		this draw(f)
		(f as Closure) free()
	}
	draw: override func ~GpuImage (image: GpuImage, source: IntBox2D, destination: IntBox2D, map: Map) {
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
	draw: override func ~mesh (image: GpuImage, mesh: Mesh) {
		f := func {
			this context meshShader add("texture0", image)
			this context meshShader projection = this _projection
			this context meshShader use(null)
			mesh draw()
		}
		this draw(f)
		(f as Closure) free()
	}
}
}
