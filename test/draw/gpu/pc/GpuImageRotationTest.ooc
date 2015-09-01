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

GpuImageRotationTest: class extends Fixture {
	init: func {
		super("GpuImageRotationTest")
		sourceImage := RasterBgra open("test/draw/gpu/pc/input/Flower.png")
		focalLength := 500.0f
		smallRotation := Float toRadians(10.0f)
		flipRotation := Float toRadians(180.0f)
		this add("GPU rotation flip X (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/rotation_flip_bgra_X.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createRotationX(flipRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU rotation flip Y (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/rotation_flip_bgra_Y.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createRotationY(flipRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU rotation flip Z (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/rotation_flip_bgra_Z.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createRotationZ(flipRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU rotation small X (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/rotation_small_bgra_X.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas focalLength = focalLength
			gpuImage canvas transform = FloatTransform3D createRotationX(smallRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU rotation small Y (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/rotation_small_bgra_Y.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas focalLength = focalLength
			gpuImage canvas transform = FloatTransform3D createRotationY(smallRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU rotation small Z (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/pc/correct/rotation_small_bgra_Z.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas focalLength = focalLength
			gpuImage canvas transform = FloatTransform3D createRotationZ(smallRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
	}
}
window := Window new(IntSize2D new(800, 800))
gpuContext := window context
GpuImageRotationTest new() run()
window free()
