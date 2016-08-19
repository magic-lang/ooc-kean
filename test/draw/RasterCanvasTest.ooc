/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use geometry
use draw
use draw-gpu
use opengl

RasterCanvasTest: class extends Fixture {
	inputFlower := "test/draw/input/Flower.png"
	inputSpace := "test/draw/input/Space.png"
	init: func {
		super("RasterCanvas")
		this add("rgb", func {
			image := RasterRgb open(this inputFlower)
			correctImage := RasterRgb open("test/draw/correct/RasterCanvas_Rgb.png")
			halfSize := image size / 2
			image drawLine(FloatPoint2D new(-halfSize x, -halfSize y), FloatPoint2D new(halfSize x, halfSize y), Pen new(ColorRgb new(0, 255, 0)))
			image drawLine(FloatPoint2D new(halfSize x, -halfSize y), FloatPoint2D new(-halfSize x, halfSize y), Pen new(ColorRgb new(0, 255, 0)))
			expect(image distance(correctImage), is less than(0.01f))
			(image, correctImage) free()
		})
		this add("rgba", func {
			image := RasterRgba open(this inputFlower)
			correctImage := RasterRgb open("test/draw/correct/RasterCanvas_Rgba.png")
			for (row in 0 .. image size y / 3)
				for (column in 0 .. image size x / 3)
					image drawPoint(FloatPoint2D new(column * 3 - image size x / 2, row * 3 - image size y / 2), Pen new(ColorRgb new(128, 0, 128)))
			expect(image distance(correctImage), is less than(0.01f))
			(image, correctImage) free()
		})
		this add("yuv420", func {
			yuvImage := RasterYuv420Semiplanar open(this inputFlower)
			for (i in 0 .. 30) {
				pen := Pen new(ColorRgb new(255, 0, 0))
				box := IntBox2D createAround(IntPoint2D new(0, 0), IntVector2D new(10 * i, 10 * i))
				yuvImage drawBox(FloatBox2D new(box), pen)
			}
			rgbImage := RasterRgb convertFrom(yuvImage)
			correctImage := RasterRgb open("test/draw/correct/RasterCanvas_Yuv420.png")
			expect(rgbImage distance(correctImage), is less than(0.01f))
			(yuvImage, rgbImage, correctImage) free()
		})
		this add("monochrome", func {
			image := RasterMonochrome open(this inputFlower)
			correctImage := RasterMonochrome open("test/draw/correct/RasterCanvas_Monochrome.png")
			pen := Pen new(ColorRgb new(255, 255, 255))
			shiftX := image size x / 2
			shiftY := image size y / 2
			for (i in 0 .. image size x / 10)
				image drawLine(FloatPoint2D new(i * 10 - shiftX, -shiftY), FloatPoint2D new(i * 10 - shiftX, shiftY), pen)
			for (i in 0 .. image size y / 10)
				image drawLine(FloatPoint2D new(-shiftX, i * 10 - shiftY), FloatPoint2D new(shiftX, i * 10 - shiftY), pen)
			expect(image distance(correctImage), is less than(0.01f))
			(image, correctImage) free()
		})
		this add("monochrome with alpha", func {
			image := RasterMonochrome open(this inputFlower)
			correctImage := RasterMonochrome open("test/draw/correct/RasterCanvas_MonochromeWithAlpha.png")
			pen := Pen new(ColorRgba new(255, 255, 255, 100))
			shiftX := image size x / 2
			shiftY := image size y / 2
			factor := 2
			for (i in 0 .. image size x / factor)
				image drawLine(FloatPoint2D new(i * factor - shiftX, -shiftY), FloatPoint2D new(i * factor - shiftX, shiftY), pen)
			for (i in 0 .. image size y / factor)
				image drawLine(FloatPoint2D new(-shiftX, i * factor - shiftY), FloatPoint2D new(shiftX, i * factor - shiftY), pen)
			expect(image distance(correctImage), is less than(0.01f))
			(image, correctImage) free()
		})
		this add("draw rgb image", func {
			outputImage := RasterRgb open("test/draw/input/Space.png")
			correctImage := RasterRgb open("test/draw/correct/RasterCanvas_drawYUVonRGB.png")
			imageFlower := RasterYuv420Semiplanar open(this inputFlower)
			DrawState new(outputImage) setInputImage(imageFlower) setViewport(IntBox2D new(20, 30, 100, 250)) setInterpolate(true) draw()
			imageFlowerYUpward := RasterYuv420Semiplanar open(this inputFlower)
			DrawState new(outputImage) setInputImage(imageFlowerYUpward) setFlipSourceY(true) setViewport(IntBox2D new(130, 30, 100, 250)) setInterpolate(true) draw()
			imageFlowerXLeftward := RasterYuv420Semiplanar open(this inputFlower)
			DrawState new(outputImage) setInputImage(imageFlowerXLeftward) setFlipSourceX(true) setViewport(IntBox2D new(240, 30, 100, 250)) setInterpolate(false) draw()
			imageFlowerXLeftwardYUpward := RasterYuv420Semiplanar open(this inputFlower)
			DrawState new(outputImage) setInputImage(imageFlowerXLeftwardYUpward) setFlipSourceX(true) setFlipSourceY(true) setViewport(IntBox2D new(350, 30, 100, 250)) setInterpolate(false) draw()
			expect(outputImage distance(correctImage), is less than(0.04f))
			(outputImage, correctImage, imageFlower, imageFlowerYUpward, imageFlowerXLeftward, imageFlowerXLeftwardYUpward) free()
		})
		this add("draw uv image", func {
			inputImage := RasterRgb open(this inputFlower)
			correctImage := RasterRgb open("test/draw/correct/RasterCanvas_drawRGBonUV.png")
			uvResult := RasterUv open(inputSpace)
			DrawState new(uvResult) setInputImage(inputImage) setViewport(IntBox2D new(130, 30, 100, 250)) setInterpolate(true) draw()
			rgbResult := RasterRgb convertFrom(uvResult)
			expect(rgbResult distance(correctImage), is less than(0.01f))
			(inputImage, rgbResult, uvResult, correctImage) free()
		})
	}
	free: override func {
		this inputFlower free()
		this inputSpace free()
		super()
	}
}

RasterCanvasTest new() run() . free()
