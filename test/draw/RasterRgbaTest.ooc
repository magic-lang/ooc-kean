/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use draw
use geometry
use unit

RasterRgbaTest: class extends Fixture {
	sourceSpace := "test/draw/input/Space.png"
	sourceFlower := "test/draw/input/Flower.png"
	init: func {
		super("RasterRgbaTest")
		this add("equals 1", func {
			image1 := RasterRgba open(this sourceFlower)
			image2 := RasterRgba open(this sourceSpace)
			expect(image1 equals(image1))
			expect(image1 equals(image2), is false)
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("equals 2", func {
			output := "test/draw/output/RasterRgba_test.png"
			image1 := RasterRgba open(this sourceFlower)
			image1 save(output)
			image2 := RasterRgba open(output)
			expect(image1 equals(image2))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("distance, same image", func {
			image1 := RasterRgba open(this sourceSpace)
			image2 := RasterRgba open(this sourceSpace)
			expect(image1 distance(image1), is equal to(0.0f))
			expect(image1 distance(image2), is equal to(0.0f))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("distance, convertFrom self", func {
			image1 := RasterRgba open(this sourceFlower)
			image2 := RasterRgba convertFrom(image1)
			expect(image1 distance(image2), is equal to(0.0f))
			expect(image1 equals(image2))
			image1 referenceCount decrease(); image2 referenceCount decrease()
		})
		this add("RGBA to Monochrome", func {
			image1 := RasterRgba open(this sourceSpace)
			image2 := RasterMonochrome convertFrom(image1)
			image3 := RasterMonochrome open("test/draw/input/correct/Bgra-Monochrome-Space.png")
			expect(image2 distance(image3), is equal to(0.0f))
			image1 referenceCount decrease(); image2 referenceCount decrease(); image3 referenceCount decrease()
		})
		this add("swapped RB", func {
			output := "test/draw/output/rbswapped_rgba.png"
			image := RasterRgba open(this sourceFlower)
			image2 := RasterRgba open(this sourceFlower)
			image swapRedBlue()
			image save(output)
			for (row in 0 .. image height)
				for (column in 0 .. image width) {
					pixel1 := image[column, row]
					pixel2 := image2[column, row]
					expect(pixel1 red, is equal to(pixel2 blue))
					expect(pixel1 green, is equal to(pixel2 green))
					expect(pixel1 blue, is equal to(pixel2 red))
					expect(pixel1 alpha, is equal to(pixel2 alpha))
				}
			image referenceCount decrease()
			image2 referenceCount decrease()
			output free()
		})
	}
}

RasterRgbaTest new() run() . free()
