/*use ooc-math
use ooc-draw-gpu
use ooc-draw-gpu-pc
use ooc-draw
use ooc-opengl

screenSize := IntSize2D new (1680.0f, 1050.0f)
window := Window create(screenSize, "GL Test")
rasterImageMonochrome := RasterMonochrome open("../test/draw/gpu/pc/input/Space.png")
rasterBgra := RasterBgra open("../test/draw/gpu/pc/input/Space.png")
rasterYuvSemiplanar := RasterYuv420Semiplanar open("../test/draw/gpu/pc/input/Space.png")
//gpuImage := window createGpuImage(rasterYuvSemiplanar)
*/
/*
packed := window createBgra(IntSize2D new(gpuImage size width / 4, gpuImage size height))
packMap := window getMap(gpuImage, GpuMapType pack) as OpenGLES3MapPackMonochrome
packMap transform = FloatTransform2D identity
packMap imageSize = gpuImage size
packMap screenSize = gpuImage size
packed canvas draw(gpuImage, packMap, Viewport new(packed size))
buffer := packed canvas readPixels(4)
result := RasterMonochrome new(buffer, rasterImageMonochrome size)
*/
/*raster := gpuImage toRaster()
for (i in 0..500) {
	window draw(raster)
	window refresh()
}*/
