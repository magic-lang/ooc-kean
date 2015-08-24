use ooc-base
use ooc-math
use ooc-draw-gpu
use ooc-draw-gpu-pc
use ooc-draw
use ooc-opengl
use ooc-unit
import math
import lang/IO
import os/Time

GpuImageTranslationTest: class extends Fixture {
	window := Window new(IntSize2D new(800, 800))
	gpuContext := window context
	init: func {
		super("GpuImageTranslationTest")

		sourceImage := RasterYuv420Semiplanar open("test/draw/gpu/pc/input/Flower.png")
		xTranslation := sourceImage size width / 2.0f
		yTranslation := sourceImage size height / 2.0f
		zTranslation := 1500.0f
		focalLength := zTranslation

		this add("GPU translate X", func {
			correctImage := RasterYuv420Semiplanar open("test/draw/gpu/pc/output/correct/yuv420Semiplanar_translation_X.png")
			gpuImage := gpuContext createYuv420Semiplanar(sourceImage size)
			this transformGpuImage(gpuImage, xTranslation, 0.0f, 0.0f)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU translate Y", func {
			correctImage := RasterYuv420Semiplanar open("test/draw/gpu/pc/output/correct/yuv420Semiplanar_translation_Y.png")
			gpuImage := gpuContext createYuv420Semiplanar(sourceImage size)
			this transformGpuImage(gpuImage, 0.0f, yTranslation, 0.0f)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			result := rasterFromGpu distance(correctImage) == 0.0f
			expect(result)
		})
		this add("GPU translate Z", func {
			correctImage := RasterYuv420Semiplanar open("test/draw/gpu/pc/output/correct/yuv420Semiplanar_translation_Z.png")
			gpuImage := gpuContext createYuv420Semiplanar(sourceImage size)
			gpuImage canvas focalLength = focalLength
			this transformGpuImage(gpuImage, 0.0f, 0.0f, zTranslation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
	}
	transformGpuImage: func (image: GpuImage, x, y, z: Float) {
		image canvas clear()
		image canvas transform = FloatTransform3D createTranslation(x, y, z)
	}
	showImageInWindow: func (image: Image) {
		window clear()
		window draw(image)
		window refresh()
		Time sleepMilli(5000)
	}
}

GpuImageTranslationTest new() run()