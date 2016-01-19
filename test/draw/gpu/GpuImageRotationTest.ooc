use base
use geometry
use draw-gpu
use draw
use opengl
use ooc-unit

GpuImageRotationTest: class extends Fixture {
	init: func {
		super("GpuImageRotationTest")
		sourceImage := RasterBgra open("test/draw/gpu/input/Flower.png")
		focalLength := 500.0f
		smallRotation := 10.0f toRadians()
		flipRotation := 180.0f toRadians()
		this add("GPU rotation flip X (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/rotation_flip_bgra_X.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createRotationX(flipRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU rotation flip Y (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/rotation_flip_bgra_Y.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createRotationY(flipRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU rotation flip Z (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/rotation_flip_bgra_Z.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas clear()
			gpuImage canvas transform = FloatTransform3D createRotationZ(flipRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
		this add("GPU rotation small X (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/rotation_small_bgra_X.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas pen = Pen new(ColorBgra new())
			gpuImage canvas clear()
			gpuImage canvas focalLength = focalLength
			gpuImage canvas transform = FloatTransform3D createRotationX(smallRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(0.005f))
		})
		this add("GPU rotation small Y (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/rotation_small_bgra_Y.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas pen = Pen new(ColorBgra new())
			gpuImage canvas clear()
			gpuImage canvas focalLength = focalLength
			gpuImage canvas transform = FloatTransform3D createRotationY(smallRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(0.05f))
		})
		this add("GPU rotation small Z (BGRA)", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/rotation_small_bgra_Z.png")
			gpuImage := gpuContext createBgra(sourceImage size)
			gpuImage canvas pen = Pen new(ColorBgra new())
			gpuImage canvas clear()
			gpuImage canvas focalLength = focalLength
			gpuImage canvas transform = FloatTransform3D createRotationZ(smallRotation)
			gpuImage canvas draw(sourceImage)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
	}
}
gpuContext := OpenGLContext new()
GpuImageRotationTest new() run() . free()
gpuContext free()
