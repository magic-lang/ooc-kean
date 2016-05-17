/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use draw
use base
use geometry
import io/File
import StbImage

ImageFileTest: class extends Fixture {
	init: func {
		super("ImageFile")
		File createDirectories("test/draw/output")
		this add("First", func {
			expect(1, is equal to(1))
		})
		this add("open PNG", func {
			source := "test/draw/input/Space.png"
			expect(This _fileExists(source))
			destination := "test/draw/output/outputPNG.png"
			requiredComponents := 4
			(buffer, size, imageComponents) := StbImage load(source, requiredComponents)
			version(debugTests) {
				failureReason := StbImage failureReason()
				println()
				failureReason toString() println()
				size x toString() println()
				size y toString() println()
				imageComponents toString() println()
			}
			StbImage writePng(destination, size x, size y, 4, buffer pointer, size x * 4)
			version(debugTests) {
				failureReason = StbImage failureReason()
				failureReason toString() println()
			}
			expect(This _fileExists(destination))
			buffer free()
		})
		this add("open JPEG", func {
			source := "test/draw/input/Flower.jpg"
			expect(This _fileExists(source))
			destination := "test/draw/output/outputJPEG.png"
			requiredComponents := 4
			(buffer, size, imageComponents) := StbImage load(source, requiredComponents)
			version(debugTests) {
				failureReason := StbImage failureReason()
				println()
				failureReason toString() println()
				size x toString() println()
				size y toString() println()
				imageComponents toString() println()
			}
			StbImage writePng(destination, size x, size y, 4, buffer pointer, size x * 4)
			version(debugTests) {
				failureReason = StbImage failureReason()
				failureReason toString() println()
			}
			expect(This _fileExists(destination))
			buffer free()
		})
		this add("open png RasterRgba", func {
			source := "test/draw/input/Space.png"
			destination := "test/draw/output/pngRasterRgba.png"
			expect(This _fileExists(source))
			image := RasterRgba open(source)
			image save(destination)
			expect(This _fileExists(destination))
			image free()
		})
		this add("open png RasterRgb", func {
			source := "test/draw/input/Space.png"
			destination := "test/draw/output/pngRasterRgb.png"
			image := RasterRgb open(source)
			image save(destination)
			expect(This _fileExists(destination))
			image free()
		})
		this add("open png RasterMonochrome", func {
			source := "test/draw/input/Barn.png"
			destination := "test/draw/output/pngRasterMonochrome.png"
			image := RasterMonochrome open(source)
			image save(destination)
			expect(This _fileExists(destination))
			image free()
		})
		this add("open jpg RasterRgba", func {
			source := "test/draw/input/Hercules.jpg"
			destination := "test/draw/output/jpgRasterRgba.png"
			image := RasterRgba open(source)
			image save(destination)
			expect(This _fileExists(destination))
			image free()
		})
		this add("open jpg RasterRgb", func {
			source := "test/draw/input/Hercules.jpg"
			destination := "test/draw/output/jpgRasterRgb.png"
			image := RasterRgb open(source)
			image save(destination)
			expect(This _fileExists(destination))
			image free()
		})
		this add("open jpg RasterMonochrome", func {
			source := "test/draw/input/Hercules.jpg"
			destination := "test/draw/output/jpgRasterMonochrome.png"
			image := RasterMonochrome open(source)
			image save(destination)
			expect(This _fileExists(destination))
			image free()
		})
		this add("convert RasterMonochrome to RasterRgba", func {
			source := "test/draw/input/Space.jpg"
			destination := "test/draw/output/RasterMonochrome-RasterRgba.png"
			monochrome := RasterMonochrome open(source)
			rgba := RasterRgba convertFrom(monochrome)
			rgba save(destination)
			expect(This _fileExists(destination))
			(monochrome, rgba) free()
		})
		this add("convert RasterRgba to RasterMonochrome", func {
			source := "test/draw/input/Space.png"
			destination := "test/draw/output/RasterRgba-RasterMonochrome.png"
			rgba := RasterRgba open(source)
			monochrome := RasterMonochrome convertFrom(rgba)
			monochrome save(destination)
			expect(This _fileExists(destination))
			(monochrome, rgba) free()
		})
		this add("convert RasterRgb to RasterMonochrome", func {
			source := "test/draw/input/Hercules.png"
			destination := "test/draw/output/RasterRgb-RasterMonochrome.png"
			rgb := RasterRgb open(source)
			monochrome := RasterMonochrome convertFrom(rgb)
			monochrome save(destination)
			expect(This _fileExists(destination))
			(rgb, monochrome) free()
		})
		this add("convert RasterMonochrome to RasterRgb", func {
			source := "test/draw/input/Hercules.png"
			destination := "test/draw/output/RasterMonochrome-RasterRgb.png"
			monochrome := RasterMonochrome open(source)
			rgb := RasterRgb convertFrom(monochrome)
			rgb save(destination)
			expect(This _fileExists(destination))
			(rgb, monochrome) free()
		})
		this add("convert RasterRgb to RasterRgba", func {
			source := "test/draw/input/Hercules.png"
			destination := "test/draw/output/RasterRgb-RasterRgba.png"
			rgb := RasterRgb open(source)
			rgba := RasterRgba convertFrom(rgb)
			rgba save(destination)
			expect(This _fileExists(destination))
			(rgb, rgba) free()
		})
		this add("convert RasterRgba to RasterRgb", func {
			source := "test/draw/input/Hercules.png"
			destination := "test/draw/output/RasterRgba-RasterRgb.png"
			rgba := RasterRgba open(source)
			rgb := RasterRgb convertFrom(rgba)
			rgb save(destination)
			expect(This _fileExists(destination))
			(rgb, rgba) free()
		})
		this add("convert RasterRgba to RasterYuv420Semiplanar", func {
			source := "test/draw/input/Barn.png"
			destination := "test/draw/output/RasterRgba-RasterYuv420Semiplanar-RasterMonochrome.png"
			rgba := RasterRgba open(source)
			yuv420 := RasterYuv420Semiplanar convertFrom(rgba)
			monochrome := RasterMonochrome convertFrom(yuv420)
			monochrome save(destination)
			expect(This _fileExists(destination))
			(monochrome, yuv420, rgba) free()
		})
		this add("convert RasterRgba to RasterYuv420Semiplanar and back again", func {
			source := "test/draw/input/Flower.png"
			destination := "test/draw/output/RasterRgb-RasterYuv420Semiplanar-RasterRgb.png"
			rgb := RasterRgb open(source)
			semiplanar := RasterYuv420Semiplanar convertFrom(rgb)
			rgb2 := RasterRgb convertFrom(semiplanar)
			rgb2 save(destination)
			expect(This _fileExists(destination))
			(rgb, rgb2, semiplanar) free()
		})
		this add("Open and save RasterYuv420Semiplanar", func {
			source := "test/draw/input/Flower.png"
			destination := "test/draw/output/RasterYuv420Semiplanar.png"
			semiplanar := RasterYuv420Semiplanar open(source)
			semiplanar save(destination)
			expect(This _fileExists(destination))
			semiplanar free()
		})
		this add("Open and save RasterUv", func {
			source := "test/draw/input/Flower.png"
			destination := "test/draw/output/RasterUv.png"
			uv := RasterUv open(source)
			uv save(destination)
			expect(This _fileExists(destination))
			(destination, source) free()
			uv referenceCount decrease()
		})
		this add("save to bin", func {
			source := "test/draw/input/Flower.png"
			destination := "test/draw/output/Flower.bin"
			semiplanar := RasterYuv420Semiplanar open(source)
			semiplanar saveRaw(destination)
			expect(This _fileExists(destination))
			semiplanar free()
		})
		this add("load from bin", func {
			source := "test/draw/output/Flower.bin"
			destination := "test/draw/output/FromBinary.png"
			semiplanar := RasterYuv420Semiplanar openRaw(source, IntVector2D new(636, 424))
			semiplanar save(destination)
			expect(This _fileExists(destination))
			semiplanar free()
		})
	}
	_fileExists: static func (path: String) -> Bool {
		file := File new(path)
		result := file exists()
		file free()
		result
	}
}

ImageFileTest new() run() . free()
