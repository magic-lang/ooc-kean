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
	transform: FloatTransform3D {
		get { this _view }
		set(value) {
			this _view = this _toLocal * value * this _toLocal
			this _target y canvas _view = this _view
			this _target uv canvas _view = FloatTransform3D createTranslation(-this _view m / 2.0f, -this _view n / 2.0f, -this _view o / 2.0f) * this _view
		}
	}
	focalLength: Float {
		get { this _focalLength }
		set(value) {
			this _focalLength = value
			this _target y canvas focalLength = value
			this _target uv canvas focalLength = value / 2
		}
	}
	pen: Pen {
		get { this _pen }
		set(value) {
			this _pen = value
			yuv := value color toYuv()
			this _target y canvas pen = Pen new(ColorRgba new(yuv y, 0, 0, 255), value width)
			this _target uv canvas pen = Pen new(ColorRgba new(yuv u, yuv v, 0, 255), value width)
		}
	}

	init: func (=_target, context: GpuContext) {
		super(this _target size, context, context defaultMap, IntTransform2D identity)
		this _target uv canvas pen = Pen new(ColorRgba new(128, 128, 128, 128))
	}
	draw: override func ~DrawState (drawState: DrawState) {
		drawStateY := drawState setTarget((drawState target as GpuYuv420Semiplanar) y)
		drawStateUV := drawState setTarget((drawState target as GpuYuv420Semiplanar) uv)
		if (!drawState viewport hasZeroArea)
			drawStateUV viewport = drawState viewport / 2
		if (drawState inputImage != null && drawState inputImage class == GpuYuv420Semiplanar) {
			drawStateY inputImage = (drawState inputImage as GpuYuv420Semiplanar) y
			drawStateUV inputImage = (drawState inputImage as GpuYuv420Semiplanar) uv
		}
		drawStateY draw()
		drawStateUV draw()
	}
	draw: override func ~GpuImage (image: GpuImage, source: IntBox2D, destination: IntBox2D, map: Map) {
		gpuImage := image as GpuYuv420Semiplanar
		this _target y canvas draw(gpuImage y, source, destination, map)
		this _target uv canvas draw(gpuImage uv, IntBox2D new(source leftTop / 2, source size / 2), IntBox2D new(destination leftTop / 2, destination size / 2), map)
	}
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) {
		gpuImage := image as GpuYuv420Semiplanar
		this _target y canvas draw(gpuImage y, source, destination)
		this _target uv canvas draw(gpuImage uv, IntBox2D new(source leftTop / 2, source size / 2), IntBox2D new(destination leftTop / 2, destination size / 2))
	}
	drawLines: override func (pointList: VectorList<FloatPoint2D>) {
		this _target y canvas drawLines(pointList)
		uvLines := VectorList<FloatPoint2D> new()
		for (i in 0 .. pointList count)
			uvLines add(pointList[i] / 2.0f)
		this _target uv canvas drawLines(uvLines)
		uvLines free()
	}
	drawPoints: override func (pointList: VectorList<FloatPoint2D>) { this _target y canvas drawPoints(pointList) }
	fill: override func (color: ColorRgba) {
		yuv := color toYuv()
		this _target y canvas fill(ColorRgba new(yuv y, 0, 0, 255))
		this _target uv canvas fill(ColorRgba new(yuv u, yuv v, 0, 255))
	}
	draw: override func ~mesh (image: GpuImage, mesh: Mesh) {
		if (!image instanceOf(GpuYuv420Semiplanar))
			Debug error("Invalid input format in GpuYuv420SemiplanarCanvas::draw~mesh")
		yuv := image as GpuYuv420Semiplanar
		this _target y canvas draw(yuv y, mesh)
		this _target uv canvas draw(yuv uv, mesh)
	}
}
}
