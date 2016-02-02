use geometry
use unit
use draw
use draw-gpu
use base
use opengl

ToRasterTest: class extends Fixture {
	init: func {
		super("ToRaster")
		this add("toRaster bgra", func {
			sourceImage := RasterBgra open("test/draw/gpu/input/Flower.png")
			gpuImage := context createImage(sourceImage)
			raster := gpuImage toRaster()
			expect(raster distance(sourceImage), is equal to(0.0f))
			sourceImage free()
			gpuImage free()
			raster free()
		})
		this add("toRaster monochrome", func {
			sourceImage := RasterMonochrome open("test/draw/gpu/input/Flower.png")
			gpuImage := context createImage(sourceImage)
			raster := gpuImage toRaster()
			expect(raster distance(sourceImage), is equal to(0.0f))
			sourceImage free()
			gpuImage free()
			raster free()
		})
		this add("toRaster yuv", func {
			sourceImage := RasterYuv420Semiplanar open("test/draw/gpu/input/Flower.png")
			gpuImage := context createImage(sourceImage)
			raster := gpuImage toRaster()
			expect(raster distance(sourceImage), is equal to(0.0f))
			sourceImage free()
			gpuImage free()
			raster free()
		})
	}
}

context := OpenGLContext new()
ToRasterTest new() run() . free()
context free()
