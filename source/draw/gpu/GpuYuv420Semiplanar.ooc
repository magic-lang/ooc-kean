/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
import GpuContext, GpuImage, GpuCanvas, GpuCanvasYuv420Semiplanar

version(!gpuOff) {
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
	init: func (=_y, =_uv, context: GpuContext) {
		super(this _y size, context)
		this _coordinateSystem = this _y coordinateSystem
		this _y referenceCount increase()
		this _uv referenceCount increase()
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
		this y referenceCount decrease()
		this uv referenceCount decrease()
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
	_createCanvas: override func -> GpuCanvas { GpuCanvasYuv420Semiplanar new(this, this _context) }
	upload: override func (image: RasterImage) {
		if (image instanceOf(RasterYuv420Semiplanar)) {
			raster := image as RasterYuv420Semiplanar
			this _y upload(raster y)
			this _uv upload(raster uv)
		}
	}
}
}
