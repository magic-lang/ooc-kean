/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
import GpuContext, GpuImage

GpuYuv420Semiplanar: class extends GpuImage {
	_y: GpuImage
	_uv: GpuImage
	y ::= this _y
	uv ::= this _uv
	filter: Bool {
		get { this _y filter }
		set(value) {
			this _y filter = value
			this _uv filter = value
		}
	}
	init: func ~basic (=_y, =_uv, context: GpuContext) {
		super(this _y size, context)
		(this _y, this _uv) referenceCount increase()
	}
	init: func ~fromRaster (rasterImage: RasterYuv420Semiplanar, context: GpuContext) {
		y := context createImage(rasterImage y)
		uv := context createImage(rasterImage uv)
		this init(y, uv, context)
	}
	init: func ~empty (size: IntVector2D, context: GpuContext) {
		y := context createMonochrome(size)
		uv := context createUv(size / 2)
		this init(y, uv, context)
	}
	free: override func {
		(this y, this uv) referenceCount decrease()
		super()
	}
	toRasterDefault: override func -> RasterImage {
		y := this _y toRaster() as RasterMonochrome
		uv := this _uv toRaster() as RasterUv
		RasterYuv420Semiplanar new(y, uv)
	}
	toRasterDefault: override func ~target (target: RasterImage) {
		yuv := target as RasterYuv420Semiplanar
		this _y toRaster(yuv y) wait() . free()
		this _uv toRaster(yuv uv) wait() . free()
	}
	create: override func (size: IntVector2D) -> This { this _context createYuv420Semiplanar(size) }
	upload: override func (image: RasterImage) {
		if (image instanceOf(RasterYuv420Semiplanar)) {
			raster := image as RasterYuv420Semiplanar
			this _y upload(raster y)
			this _uv upload(raster uv)
		}
	}
	draw: override func ~DrawState (drawState: DrawState) {
		drawStateY := drawState setTarget((drawState target as This) y)
		drawStateUV := drawState setTarget((drawState target as This) uv)
		drawStateUV viewport = drawState viewport / 2
		if (drawState inputImage != null && drawState inputImage class == This) {
			drawStateY inputImage = (drawState inputImage as This) y
			drawStateUV inputImage = (drawState inputImage as This) uv
		}
		drawStateY draw()
		drawStateUV draw()
	}
	drawLines: override func (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		yuv := pen color toYuv()
		this y drawLines(pointList, Pen new(ColorRgba new(yuv y, 0, 0, 255), pen width))
		uvLines := VectorList<FloatPoint2D> new()
		for (i in 0 .. pointList count)
			uvLines add(pointList[i] / 2.0f)
		this uv drawLines(uvLines, Pen new(ColorRgba new(yuv u, yuv v, 0, 255), (pen width / 2.0f) + 0.5f))
		uvLines free()
	}
	drawPoints: override func (pointList: VectorList<FloatPoint2D>, pen: Pen) { this y drawPoints(pointList, pen) }
	fill: override func (color: ColorRgba) {
		yuv := color toYuv()
		this y fill(ColorRgba new(yuv y, 0, 0, 255))
		this uv fill(ColorRgba new(yuv u, yuv v, 0, 255))
	}
	_toRgbaAuxiliary: func (target: GpuImage) {
		shader := this _context getYuvToRgba()
		shader add("texture0", this y)
		shader add("texture1", this uv)
		DrawState new(target) setMap(shader) draw()
	}
	toRgb: func -> GpuImage {
		target := this _context createRgb(this size)
		this _toRgbaAuxiliary(target)
		target
	}
	toRgba: func -> GpuImage {
		target := this _context createRgba(this size)
		this _toRgbaAuxiliary(target)
		target
	}
}
