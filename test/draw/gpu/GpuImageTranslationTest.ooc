use ooc-base
use ooc-math
use ooc-draw-gpu
use ooc-draw
use ooc-opengl
use ooc-unit
import math
import lang/IO
import os/Time

GpuImageTranslationTest: class extends Fixture {
	init: func {
		super("GpuImageTranslationTest")
		sourceImage := RasterBgra open("test/draw/gpu/input/Flower.png")
		xTranslation := sourceImage size width / 2.0f
		yTranslation := sourceImage size height / 2.0f
		zTranslation := 1500.0f
		focalLength := zTranslation
		this add("GPU translate X (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/translation_bgra_X.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas pen = Pen new(ColorBgra new())
			gpuImage canvas focalLength = focalLength
			this translateGpuImage(gpuImage, xTranslation, 0.0f, 0.0f)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU translate Y (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/translation_bgra_Y.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas pen = Pen new(ColorBgra new())
			gpuImage canvas focalLength = focalLength
			this translateGpuImage(gpuImage, 0.0f, yTranslation, 0.0f)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU translate Z (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/translation_bgra_Z.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas pen = Pen new(ColorBgra new())
			gpuImage canvas focalLength = focalLength
			this translateGpuImage(gpuImage, 0.0f, 0.0f, zTranslation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(3.0f))
		})
	}
	translateGpuImage: func (image: GpuImage, x, y, z: Float) {
		image canvas clear()
		image canvas transform = FloatTransform3D createTranslation(x, y, z)
	}
}
gpuContext := OpenGLContext new()
GpuImageTranslationTest new() run()
gpuContext free()
