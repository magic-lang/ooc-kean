/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use unit
use draw
use draw-gpu
use base
use opengl

ToRasterTest: class extends Fixture {
	bgra := RasterBgra open("test/draw/gpu/input/Flower.png")
	monochrome := RasterMonochrome open("test/draw/gpu/input/Flower.png")
	yuv := RasterYuv420Semiplanar open("test/draw/gpu/input/Flower.png")
	context := OpenGLContext new()
	free: override func {
		this bgra free()
		this monochrome free()
		this yuv free()
		this context free()
		super()
	}
	toRaster: func (sourceImage: RasterImage) {
		gpuImage := context createImage(sourceImage)
		raster := gpuImage toRaster()
		expect(raster distance(sourceImage), is equal to(0.0f))
		gpuImage free()
		raster free()
	}
	toRasterTarget: func (sourceImage: RasterImage) {
		gpuImage := context createImage(sourceImage)
		raster := sourceImage create(sourceImage size) as RasterImage
		gpuImage toRaster(raster) wait() . free()
		expect(raster distance(sourceImage), is equal to(0.0f))
		gpuImage free()
		raster free()
	}
	toRasterAsync: func (sourceImage: RasterImage) {
		gpuImage := context createImage(sourceImage)
		future := gpuImage toRasterAsync() as ToRasterFuture
		future wait()
		raster := future getResult(null)
		expect(raster != null)
		expect(raster distance(sourceImage), is equal to(0.0f))
		future free()
		gpuImage free()
		raster referenceCount decrease()
	}
	init: func {
		super("ToRaster")
		this add("toRaster bgra", || this toRaster(bgra))
		this add("toRaster monochrome", || this toRaster(monochrome))
		this add("toRaster yuv", || this toRaster(yuv))

		this add("toRasterTarget bgra", || this toRasterTarget(bgra))
		this add("toRasterTarget monochrome", || this toRasterTarget(monochrome))
		this add("toRasterTarget yuv", || this toRasterTarget(yuv))

		this add("toRasterAsync bgra", || this toRasterAsync(bgra))
		this add("toRasterAsync monochrome", || this toRasterAsync(monochrome))
		this add("toRasterAsync yuv", || this toRasterAsync(yuv))
	}
}
ToRasterTest new() run() . free()
