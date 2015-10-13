use ooc-unit
use ooc-math
use ooc-draw
use ooc-draw-gpu
use ooc-opengl

PainterTest: class extends Fixture {
	init: func {
		super("Painter")
		this add("rgb", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/painter_rasterRgb.png"
			image := RasterBgr open(input)
			painter := Painter new(image)
			painter setPen(Pen new(ColorBgr new(0, 255, 0)))
			halfWidth := image size width / 2
			halfHeight := image size height / 2
			painter drawLine(-halfWidth, -halfHeight, halfWidth, halfHeight)
			painter drawLine(halfWidth, -halfHeight, -halfWidth, halfHeight)
			image save(output)
			original := RasterBgr open(input)
			expect(original distance(image) > 0.0f)
			original free()
			painter free()
			image free()
			input free()
			output free()
		})
		this add("rgba", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/painter_rasterRgba.png"
			image := RasterBgra open(input)
			painter := Painter new(image)
			painter setPen(Pen new(ColorBgr new(128, 0, 128)))
			for (row in 0 .. image size height / 3)
				for (column in 0 .. image size width / 3)
					painter drawPoint(column * 3 - image size width / 2, row * 3 - image size height / 2)
			image save(output)
			original := RasterBgra open(input)
			expect(original distance(image) > 0.0f)
			original free()
			painter free()
			image free()
			input free()
			output free()
		})
		this add("yuv420", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/painter_rasterYuv420.png"
			image := RasterYuv420Semiplanar open(input)
			painter := Painter new(image)
			for (i in 0 .. 30) {
				painter setPen(Pen new(ColorBgr new((i % 10) * 25, (i % 5) * 50, (i % 3) * 80)))
				painter drawBox(IntBox2D createAround(IntPoint2D new(0, 0), IntSize2D new(10 * i, 10 * i)))
			}
			image save(output)
			original := RasterYuv420Semiplanar open(input)
			expect(original distance(image) > 0.0f)
			original free()
			painter free()
			image free()
			input free()
			output free()
		})
		this add("monochrome", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/painter_rasterMonochrome.png"
			image := RasterMonochrome open(input)
			painter := Painter new(image)
			painter setPen(Pen new(ColorBgr new(255, 255, 255)))
			shiftX := image size width / 2
			shiftY := image size height / 2
			for (i in 0 .. image size width / 10)
				painter drawLine(IntPoint2D new(i * 10 - shiftX, -shiftY), IntPoint2D new(i * 10 - shiftX, shiftY))
			for (i in 0 .. image size height / 10)
				painter drawLine(IntPoint2D new(-shiftX, i * 10 - shiftY), IntPoint2D new(shiftX, i * 10 - shiftY))
			image save(output)
			original := RasterMonochrome open(input)
			expect(original distance(image) > 0.0f)
			original free()
			painter free()
			image free()
			input free()
			output free()
		})
		this add("monochrome with alpha", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/painter_rasterMonochromeWithAlpha.png"
			image := RasterMonochrome open(input)
			painter := Painter new(image)
			painter setPen(Pen new(ColorBgra new(255, 255, 255, 100)))
			shiftX := image size width / 2
			shiftY := image size height / 2
			factor := 2
			for (i in 0 .. image size width / factor)
				painter drawLine(IntPoint2D new(i * factor - shiftX, -shiftY), IntPoint2D new(i * factor - shiftX, shiftY))
			for (i in 0 .. image size height / factor)
				painter drawLine(IntPoint2D new(-shiftX, i * factor - shiftY), IntPoint2D new(shiftX, i * factor - shiftY))
			image save(output)
			original := RasterMonochrome open(input)
			expect(original distance(image) > 0.0f)
			original free()
			painter free()
			image free()
			input free()
			output free()
		})
		this add("gpu", func {
			version(!gpuOff) {
				input := "test/draw/input/Flower.png"
				output := "test/draw/output/painter_gpuYuv.png"
				image := RasterYuv420Semiplanar open(input)
				context := OpenGLContext new()
				gpuImage := context createGpuImage(image)
				painter := Painter new(gpuImage)
				painter setPen(Pen new(ColorBgr new(255, 255, 255)))
				shiftX := image size width / 2
				shiftY := image size height / 2
				for (i in 0 .. image size width / 10)
					painter drawLine(IntPoint2D new(i * 10 - shiftX, -shiftY), IntPoint2D new(i * 10 - shiftX, shiftY))
				for (i in 0 .. image size height / 10)
					painter drawLine(IntPoint2D new(-shiftX, i * 10 - shiftY), IntPoint2D new(shiftX, i * 10 - shiftY))
				rasterImage := gpuImage toRasterAsync()
				rasterImage save(output)
				original := RasterYuv420Semiplanar open(output)
				expect(original distance(rasterImage) > 0.0f)
				original free()
				painter free()
				rasterImage free()
				image free()
				input free()
				output free()
				context free()
			}
		})
	}
}

test := PainterTest new()
test run()
test free()
