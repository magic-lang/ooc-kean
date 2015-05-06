use ooc-math
use ooc-draw
use ooc-draw-gpu-pc
use ooc-draw-gpu
use ooc-opengl
use ooc-base
import os/Time

Debug initialize(func(s: String) { println(s) })

yuvSize := IntSize2D new(1280, 720)
rgbaSize := IntSize2D new(yuvSize width / 4, 3 * yuvSize height / 2)
paddedBytes := 0

rasterRgba := RasterBgra new(rgbaSize)

rgbaPtr := rasterRgba buffer pointer

//Set Y values
for (i in 0..yuvSize area)
	rgbaPtr[i] = 2 * i % 255
rgbaPtr += yuvSize area

//Set padding
for (i in 0..paddedBytes) {
	rgbaPtr[i] = 0
}
rgbaPtr += paddedBytes

//Set UV values
for (i in 0..yuvSize width * yuvSize height / 2)
	rgbaPtr[i] = i % 255

window := Window create(yuvSize)

target := window createYuv420Semiplanar(yuvSize) as GpuYuv420Semiplanar
gpuRgba := window createGpuImage(rasterRgba)
unpackRgbaToMonochrome := OpenGLES3MapUnpackRgbaToMonochrome new(window)
unpackRgbaToUv := OpenGLES3MapUnpackRgbaToUv new(window)

unpackRgbaToMonochrome targetSize = target y size
unpackRgbaToMonochrome sourceSize = rgbaSize
target y canvas draw(gpuRgba, unpackRgbaToMonochrome, Viewport new(target y size))
unpackRgbaToUv targetSize = target uv size
unpackRgbaToUv sourceSize = rgbaSize
target uv canvas draw(gpuRgba, unpackRgbaToUv, Viewport new(target uv size))

yuvRaster := target toRaster() as RasterYuv420Semiplanar

yPtr := yuvRaster y buffer pointer
for (i in 0..1280 * 720) {
	value: UInt = yPtr[i]
	expected: UInt = 2* i % 255
	if (value != expected)
		Debug print("ERROR: %u expected: %u" format(value, expected))
}

uvPtr := yuvRaster uv buffer pointer
for (i in 0..1280 * 360) {
	value: UInt = uvPtr[i]
	expected: UInt = i % 255
	if (value != i % 255) {
		Debug print("ERROR: %u expected: %u" format(value, expected))
		break
	}
}
//yuvRaster save("test.png")

for (i in 0..100) {
	window draw(target)
	window refresh()
	Time sleepMilli(30)
}
