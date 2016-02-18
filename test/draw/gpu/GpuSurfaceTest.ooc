/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use geometry
use draw-gpu
use draw
use opengl
use unit

GpuSurfaceTest: class extends Fixture {
	init: func {
		super("GpuSurfaceTest")
		sourceImage := RasterBgra open("test/draw/gpu/input/quad1.png")
		sourceSize := sourceImage size
		this add("draw red quadrant scale 1:1", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/quadrant_red.png")
			gpuImage := gpuContext createBgra(sourceSize)
			gpuImage canvas pen = Pen new(ColorRgba new())
			viewport := gpuImage canvas viewport
			quadrantRed := IntBox2D new(viewport left, viewport top, viewport width / 2, viewport height / 2)
			gpuImage canvas clear()
			gpuImage canvas draw(sourceImage, quadrantRed, quadrantRed)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			rasterFromGpu free(); correctImage free(); gpuImage free()
		})
		this add("draw yellow quadrant scale 1:1", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/quadrant_yellow.png")
			gpuImage := gpuContext createBgra(sourceSize)
			gpuImage canvas pen = Pen new(ColorRgba new())
			viewport := gpuImage canvas viewport
			quadrantYellow := IntBox2D new(viewport width / 2, viewport top, viewport width / 2, viewport height / 2)
			gpuImage canvas clear()
			gpuImage canvas draw(sourceImage, quadrantYellow, quadrantYellow)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			rasterFromGpu free(); correctImage free(); gpuImage free()
		})
		this add("draw blue quadrant scale 1:1", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/quadrant_blue.png")
			gpuImage := gpuContext createBgra(sourceSize)
			gpuImage canvas pen = Pen new(ColorRgba new())
			viewport := gpuImage canvas viewport
			quadrantBlue := IntBox2D new(viewport left, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas clear()
			gpuImage canvas draw(sourceImage, quadrantBlue, quadrantBlue)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			rasterFromGpu free(); correctImage free(); gpuImage free()
		})
		this add("draw green quadrant scale 1:1", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/quadrant_green.png")
			gpuImage := gpuContext createBgra(sourceSize)
			viewport := gpuImage canvas viewport
			quadrantGreen := IntBox2D new(viewport width / 2, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas clear()
			gpuImage canvas draw(sourceImage, quadrantGreen, quadrantGreen)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			correctImage free(); rasterFromGpu free(); gpuImage free()
		})
		this add("draw combined quadrants", func {
			quadrantRed := RasterBgra open("test/draw/gpu/correct/quadrant_red.png")
			quadrantYellow := RasterBgra open("test/draw/gpu/correct/quadrant_yellow.png")
			quadrantBlue := RasterBgra open("test/draw/gpu/correct/quadrant_blue.png")
			quadrantGreen := RasterBgra open("test/draw/gpu/correct/quadrant_green.png")
			correctImage := RasterBgra open("test/draw/gpu/correct/quad.png")
			gpuImage := gpuContext createBgra(sourceSize)
			gpuImage canvas clear()
			viewport := gpuImage canvas viewport
			redBox := IntBox2D new(viewport left, viewport top, viewport width / 2, viewport height / 2)
			yellowBox := IntBox2D new(viewport width / 2, viewport top, viewport width / 2, viewport height / 2)
			blueBox := IntBox2D new(viewport left, viewport height / 2, viewport width / 2, viewport height / 2)
			greenBox := IntBox2D new(viewport width / 2, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas draw(quadrantRed, redBox, redBox)
			gpuImage canvas draw(quadrantYellow, yellowBox, yellowBox)
			gpuImage canvas draw(quadrantBlue, blueBox, blueBox)
			gpuImage canvas draw(quadrantGreen, greenBox, greenBox)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			quadrantRed free(); quadrantYellow free(); quadrantBlue free(); quadrantGreen free()
			correctImage free(); rasterFromGpu free(); gpuImage free()
		})
		this add("draw red quadrant zoomed", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/quadrant_red_zoom.png")
			gpuImage := gpuContext createBgra(sourceSize)
			gpuImage canvas clear()
			viewport := gpuImage canvas viewport
			redBox := IntBox2D new(viewport left, viewport top, viewport width / 2, viewport height / 2)
			gpuImage canvas draw(sourceImage, redBox, viewport)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
			correctImage free(); rasterFromGpu free(); gpuImage free()
		})
		this add("draw quad 1:4 scale top left bottom right and 180deg x rotation", func {
			correctImage := RasterBgra open("test/draw/gpu/correct/quad_scaled_top_left_bottom_right_180deg_x_rotation.png")
			gpuImage := gpuContext createBgra(sourceSize)
			gpuImage canvas clear()
			viewport := gpuImage canvas viewport
			quadrantTopLeft := IntBox2D new(viewport left, viewport top, viewport width / 2, viewport height / 2)
			quadrantBottomRight := IntBox2D new(viewport width / 2, viewport height / 2, viewport width / 2, viewport height / 2)
			gpuImage canvas transform = FloatTransform3D createRotationX(180.0f toRadians())
			gpuImage canvas draw(sourceImage, quadrantTopLeft)
			gpuImage canvas transform = FloatTransform3D createRotationX(180.0f toRadians())
			gpuImage canvas draw(sourceImage, quadrantBottomRight)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f) within(0.05f))
			correctImage free(); rasterFromGpu free(); gpuImage free()
		})
		this add("draw shapes", func {
			correctImage := RasterMonochrome open("test/draw/gpu/correct/shapes.png")
			gpuImage := gpuContext createMonochrome(sourceSize)
			gpuImage canvas clear()
			trianglePoints := VectorList<FloatPoint2D> new()
			lineLength := 200.0f
			trianglePoints add(FloatPoint2D new(-lineLength, lineLength / 2.0f))
			trianglePoints add(FloatPoint2D new (lineLength, lineLength / 2.0f))
			trianglePoints add(FloatPoint2D new(0.0f, -lineLength))
			trianglePoints add(FloatPoint2D new(-lineLength, lineLength / 2.0f))
			gpuImage canvas drawLines(trianglePoints)
			gpuImage canvas drawBox(FloatBox2D new(-lineLength, -lineLength, lineLength * 2.0f, lineLength * 2.0f))
			//
			// NOTE! The circle use a point size of 1.0f (OpenGLMapPoints in OpenGLMap.ooc)
			//
			theta := 0.0f
			step := Float pi / 20.0f
			origo_x := 0.0f
			origo_y := 0.0f
			radius := lineLength
			circlePoints := VectorList<FloatPoint2D> new()
			while (theta <= 360.0f) {
				circlePoints add(FloatPoint2D new(origo_x + radius * theta cos(), origo_y - radius * theta sin()))
				theta += step
			}
			gpuImage canvas drawPoints(circlePoints)
			rasterFromGpu := gpuImage toRaster()
			expect(rasterFromGpu distance(correctImage), is equal to(0.0f))
		})
	}
}
gpuContext := OpenGLContext new()
GpuSurfaceTest new() run() . free()
gpuContext free()
