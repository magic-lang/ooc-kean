use ooc-draw-gpu
use ooc-draw
use ooc-math
use ooc-opengl
use ooc-draw-gpu-pc
window := Window new(IntSize2D new(1280, 720), "Test")
gpuBgra := window createBgra(IntSize2D new(1920, 270))
packMonochrome := OpenGLES3MapPackMonochrome1080p new()
packMonochrome transform = FloatTransform2D identity
packMonochrome screenSize = gpuBgra size
packMonochrome imageSize = gpuBgra size
raster := RasterMonochrome open("test/draw/gpu/pc/input/test.png")
gpuBgra canvas draw(raster, packMonochrome, Viewport new(gpuBgra size))
packedRaster := gpuBgra toRaster() as RasterBgra
raster2 := RasterMonochrome new(packedRaster pointer, IntSize2D new(1920, 1080))
raster2 save("packed1080.png")

for(i in 0..0) {
	window refresh()
}
