use ooc-base
use ooc-math
use ooc-draw-gpu
use ooc-draw
use ooc-opengl
use ooc-unit
import math
import lang/IO
import os/Time

ImageCoordinateSystemTest: class extends Fixture {
	tolerance := 1.0e-5f
	init: func {
		super("ImageCoordinateSystemTest")
		sourceImage := RasterBgra open("test/draw/gpu/input/Hercules.png")
		this add("change Raster coordinateSystem XLeftward", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/XLeftward.png")
			sourceImage coordinateSystem = CoordinateSystem XLeftward
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(tolerance))
		})
		this add("change Raster coordinateSystem YUpward", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/YUpward.png")
			sourceImage coordinateSystem = CoordinateSystem YUpward
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(tolerance))
		})
		this add("change Raster coordinateSystem YDownward + XRightward + Default", func {
			correctImage := RasterBgra open("test/draw/gpu/input/Hercules.png")
			sourceImage coordinateSystem = CoordinateSystem YDownward
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(tolerance))
		})
		this add("change GpuImage coordinateSystem XLeftward", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/XLeftward.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuSourceImage := gpuContext createImage(sourceImage) as OpenGLBgra
			gpuSourceImage coordinateSystem = CoordinateSystem XLeftward
			gpuImage canvas clear()
			gpuImage canvas draw(gpuSourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(tolerance))
		})
		this add("change GpuImage coordinateSystem YUpward", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/YUpward.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuSourceImage := gpuContext createImage(sourceImage) as OpenGLBgra
			gpuSourceImage coordinateSystem = CoordinateSystem YUpward
			gpuImage canvas clear()
			gpuImage canvas draw(gpuSourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(tolerance))
		})
		this add("change GpuImage coordinateSystem YDownward + XRightward + Default", func {
			correctImage := RasterBgra open("test/draw/gpu/input/Hercules.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuSourceImage := gpuContext createImage(sourceImage) as OpenGLBgra
			gpuSourceImage coordinateSystem = CoordinateSystem XRightward
			gpuImage canvas clear()
			gpuImage canvas draw(gpuSourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(tolerance))
		})
	}
}
gpuContext := OpenGLContext new()
ImageCoordinateSystemTest new() run() . free()
gpuContext free()
