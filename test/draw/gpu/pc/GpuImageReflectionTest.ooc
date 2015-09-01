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

GpuImageReflectionTest: class extends Fixture {
	init: func {
		super("GpuImageReflectionTest")
		sourceImage := RasterBgra open("test/draw/gpu/pc/input/Flower.png")
		this add("GPU reflection X (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/reflection_bgra_X.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createReflectionX()
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU reflection Y (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/reflection_bgra_Y.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createReflectionY()
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU reflection Z (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/reflection_bgra_Z.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createReflectionZ()
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
	}
}
window := Window new(IntSize2D new(800, 800))
gpuContext := window context
GpuImageReflectionTest new() run()
window free()
