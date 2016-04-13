/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use base
use collections
import GpuImage, Map, GpuCanvas, GpuContext, GpuYuv420Semiplanar, Mesh

version(!gpuOff) {
GpuCanvasYuv420Semiplanar: class extends GpuCanvas {
	_target: GpuYuv420Semiplanar
	init: func (=_target, context: GpuContext) {
		super(this _target size, context, context defaultMap, IntTransform2D identity)
	}
	draw: override func ~DrawState (drawState: DrawState) {
		drawStateY := drawState setTarget((drawState target as GpuYuv420Semiplanar) y)
		drawStateUV := drawState setTarget((drawState target as GpuYuv420Semiplanar) uv)
		drawStateUV viewport = drawState viewport / 2
		if (drawState inputImage != null && drawState inputImage class == GpuYuv420Semiplanar) {
			drawStateY inputImage = (drawState inputImage as GpuYuv420Semiplanar) y
			drawStateUV inputImage = (drawState inputImage as GpuYuv420Semiplanar) uv
		}
		drawStateY draw()
		drawStateUV draw()
	}
	drawLines: override func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		yuv := pen color toYuv()
		this _target y canvas drawLines(pointList, Pen new(ColorRgba new(yuv y, 0, 0, 255), pen width))
		uvLines := VectorList<FloatPoint2D> new()
		for (i in 0 .. pointList count)
			uvLines add(pointList[i] / 2.0f)
		this _target uv canvas drawLines(uvLines, Pen new(ColorRgba new(yuv u, yuv v, 0, 255), (pen width / 2.0f) + 0.5f))
		uvLines free()
	}
	drawPoints: override func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) { this _target y canvas drawPoints(pointList, pen) }
	fill: override func (color: ColorRgba) {
		yuv := color toYuv()
		this _target y canvas fill(ColorRgba new(yuv y, 0, 0, 255))
		this _target uv canvas fill(ColorRgba new(yuv u, yuv v, 0, 255))
	}
}
}
