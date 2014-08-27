use ooc-unit
use ooc-draw
import math
import lang/IO
import io/File

ImageFileTest: class extends Fixture {
	init: func () {
		super("ImageFile")
		this add("First", func() {
			expect(1, is equal to(1))
		})
		this add("open PNG", func() {
			source := "test/input/Space.png"
			destination := "test/output/outputPNG.png"
			requiredComponents := 4
			x, y, n: Int
			data := StbImage load(source, x&, y&, n&, requiredComponents)
			failureReason := StbImage failureReason()
			println()
			failureReason toString() println()
			x toString() println()
			y toString() println()
			n toString() println()

			StbImage writePng(destination, x, y, 4, data, x * 4)
			failureReason = StbImage failureReason()
			failureReason toString() println()
		})
		this add("open JPEG", func() {
			source := "test/input/Flower.jpg"
			destination := "test/output/outputJPEG.png"
			requiredComponents := 4
			x, y, n: Int
			data := StbImage load(source, x&, y&, n&, requiredComponents)
			failureReason := StbImage failureReason()
			println()
			failureReason toString() println()
			x toString() println()
			y toString() println()
			n toString() println()

			StbImage writePng(destination, x, y, 4, data, x * 4)
			failureReason = StbImage failureReason()
			failureReason toString() println()
		})
		this add("open RasterBgra", func() {
			source := "test/input/Space.png"
			destination := "test/output/outputRasterBgra.png"
			image := RasterBgra open(source)
			image save(destination)
		})
		this add("open RasterBgr", func() {
			source := "test/input/Space.png"
			destination := "test/output/outputRasterBgr.png"
			image := RasterBgr open(source)
			image save(destination)
		})
		this add("open RasterMonochrome", func() {
			source := "test/input/Barn.png"
			destination := "test/output/outputRasterMonochrome.png"
			image := RasterMonochrome open(source)
			image save(destination)
		})
		this add("convert RasterBgra to RasterMonochrome", func() {
			source := "test/input/Barn.png"
			destination := "test/output/outputRasterBgraToRasterMonochrome.png"
			bgra := RasterBgra open(source)
			monochrome := RasterMonochrome new(bgra)
			monochrome save(destination)
		})
		this add("convert RasterBgr to RasterMonochrome", func() {
			source := "test/input/Barn.png"
			destination := "test/output/outputRasterBgrToRasterMonochrome.png"
			bgr := RasterBgr open(source)
			monochrome := RasterMonochrome new(bgr)
			monochrome save(destination)
		})
		this add("convert RasterBgra to RasterYuv420Planar", func() {
			source := "test/input/Barn.png"
			destination := "test/output/outputRasterBgraToYuv420PlanarToRasterMonochrome.png"
			bgra := RasterBgra open(source)
			yuv420 := RasterYuv420Planar new(bgra)
			monochrome := RasterMonochrome new(yuv420)
			monochrome save(destination)
		})
		this add("convert RasterBgra to RasterYuv420Semiplanar", func() {
			source := "test/input/Barn.png"
			destination := "test/output/outputRasterBgraToYuv420SemiplanarToRasterMonochrome.png"
			bgra := RasterBgra open(source)
			yuv420 := RasterYuv420Semiplanar new(bgra)
			monochrome := RasterMonochrome new(yuv420)
			monochrome save(destination)
		})
		this add("convert RasterBgr to RasterYuv420Planar to RasterMonochrome", func() {
			source := "test/input/Barn.png"
			destination := "test/output/outputRasterBgrToYuv420PlanarToRasterMonochrome.png"
			bgr := RasterBgr open(source)
			yuv420 := RasterYuv420Planar new(bgr)
			monochrome := RasterMonochrome new(yuv420)
			monochrome save(destination)
		})
		this add("convert RasterBgr to RasterYuv420Planar and back again", func() {
			source := "test/input/Barn.png"
			destination := "test/output/outputRasterBgrToYuv420PlanarAndBack.png"
			bgr := RasterBgr open(source)
			yuv420 := RasterYuv420Planar new(bgr)
			bgr2 := RasterBgr new(yuv420)
			bgr2 save(destination)
		})
		this add("Last", func() {
			expect(1, is equal to(1))
		})
	}
}
ImageFileTest new() run()
