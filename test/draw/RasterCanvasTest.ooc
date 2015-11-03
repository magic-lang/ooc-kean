use ooc-unit
use ooc-math
use ooc-draw
use ooc-draw-gpu
use ooc-opengl

RasterCanvasTest: class extends Fixture {
	init: func {
		super("RasterCanvas")
		this add("rgb", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/RasterCanvas_Bgr.png"
			image := RasterBgr open(input)
			image canvas pen = Pen new(ColorBgr new(0, 255, 0))
			halfWidth := image size width / 2
			halfHeight := image size height / 2
			start := FloatPoint2D new(-halfWidth, -halfHeight)
			end := FloatPoint2D new(halfWidth, halfHeight)
			image canvas drawLine(start, end)
			start = FloatPoint2D new(halfWidth, -halfHeight)
			end = FloatPoint2D new(-halfWidth, halfHeight)
			image canvas drawLine(start, end)
			image save(output)
			original := RasterBgr open(input)
			//FIXME: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original free()
			image free()
			input free()
			output free()
		})
		this add("rgba", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/RasterCanvas_Bgra.png"
			image := RasterBgra open(input)
			image canvas pen = Pen new(ColorBgr new(128, 0, 128))
			for (row in 0 .. image size height / 3)
				for (column in 0 .. image size width / 3)
					image canvas drawPoint(FloatPoint2D new(column * 3 - image size width / 2, row * 3 - image size height / 2))
			image save(output)
			original := RasterBgra open(input)
			//FIXME: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original free()
			image free()
			input free()
			output free()
		})
		this add("yuv420", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/RasterCanvas_Yuv420.png"
			image := RasterYuv420Semiplanar open(input)
			for (i in 0 .. 30) {
				image canvas pen = Pen new(ColorBgr new((i % 10) * 25, (i % 5) * 50, (i % 3) * 80))
				box := IntBox2D createAround(IntPoint2D new(0, 0), IntSize2D new(10 * i, 10 * i))
				image canvas drawBox(FloatBox2D new(box))
			}
			image save(output)
			original := RasterYuv420Semiplanar open(input)
			//FIXME: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original free()
			image free()
			input free()
			output free()
		})
		this add("monochrome", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/RasterCanvas_Monochrome.png"
			image := RasterMonochrome open(input)
			image canvas pen = Pen new(ColorBgr new(255, 255, 255))
			shiftX := image size width / 2
			shiftY := image size height / 2
			for (i in 0 .. image size width / 10)
				image canvas drawLine(FloatPoint2D new(i * 10 - shiftX, -shiftY), FloatPoint2D new(i * 10 - shiftX, shiftY))
			for (i in 0 .. image size height / 10)
				image canvas drawLine(FloatPoint2D new(-shiftX, i * 10 - shiftY), FloatPoint2D new(shiftX, i * 10 - shiftY))
			image save(output)
			original := RasterMonochrome open(input)
			//FIXME: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original free()
			image free()
			input free()
			output free()
		})
		this add("monochrome with alpha", func {
			input := "test/draw/input/Flower.png"
			output := "test/draw/output/RasterCanvas_MonochromeWithAlpha.png"
			image := RasterMonochrome open(input)
			image canvas pen = Pen new(ColorBgra new(255, 255, 255, 100))
			shiftX := image size width / 2
			shiftY := image size height / 2
			factor := 2
			for (i in 0 .. image size width / factor)
				image canvas drawLine(FloatPoint2D new(i * factor - shiftX, -shiftY), FloatPoint2D new(i * factor - shiftX, shiftY))
			for (i in 0 .. image size height / factor)
				image canvas drawLine(FloatPoint2D new(-shiftX, i * factor - shiftY), FloatPoint2D new(shiftX, i * factor - shiftY))
			image save(output)
			original := RasterMonochrome open(input)
			//FIXME: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original free()
			image free()
			input free()
			output free()
		})
	}
}

test := RasterCanvasTest new()
test run()
test free()
