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
		this add("open png RasterBgra", func() {
			source := "test/input/Space.png"
			destination := "test/output/pngRasterBgra.png"
			image := RasterBgra open(source)
			image save(destination)
		})
		this add("open png RasterBgr", func() {
			source := "test/input/Space.png"
			destination := "test/output/pngRasterBgr.png"
			image := RasterBgr open(source)
			image save(destination)
		})
		this add("open png RasterMonochrome", func() {
			source := "test/input/Barn.png"
			destination := "test/output/pngRasterMonochrome.png"
			image := RasterMonochrome open(source)
			image save(destination)
		})
		this add("open jpg RasterBgra", func() {
			source := "test/input/Hercules.jpg"
			destination := "test/output/jpgRasterBgra.png"
			image := RasterBgra open(source)
			image save(destination)
		})
		this add("open jpg RasterBgr", func() {
			source := "test/input/Hercules.jpg"
			destination := "test/output/jpgRasterBgr.png"
			image := RasterBgr open(source)
			image save(destination)
		})
		this add("open jpg RasterMonochrome", func() {
			source := "test/input/Hercules.jpg"
			destination := "test/output/jpgRasterMonochrome.png"
			image := RasterMonochrome open(source)
			image save(destination)
		})
		this add("open jpg RasterMonochrome to RasterBgra", func() {
			source := "test/input/Space.jpg"
			destination := "test/output/jpgRasterMonochrome-RasterBgra.png"
			image := RasterMonochrome open(source)
			bgra := RasterBgra new(image)
			bgra save(destination)
		})
		this add("convert RasterBgra to RasterMonochrome", func() {
			source := "test/input/Space.png"
			destination := "test/output/RasterBgra-RasterMonochrome.png"
			bgra := RasterBgra open(source)
			monochrome := RasterMonochrome new(bgra)
			monochrome save(destination)
		})
		this add("convert RasterMonochrome to RasterBgra", func() {
			source := "test/input/Space.png"
			destination := "test/output/RasterMonochrome-RasterBgra.png"
			monochrome := RasterMonochrome open(source)
			bgra := RasterBgra new(monochrome)
			bgra save(destination)
		})
		this add("convert RasterBgr to RasterMonochrome", func() {
			source := "test/input/Hercules.png"
			destination := "test/output/RasterBgr-RasterMonochrome.png"
			bgr := RasterBgr open(source)
			monochrome := RasterMonochrome new(bgr)
			monochrome save(destination)
		})
		this add("convert RasterMonochrome to RasterBgr", func() {
			source := "test/input/Hercules.png"
			destination := "test/output/RasterMonochrome-RasterBgr.png"
			monochrome := RasterMonochrome open(source)
			bgr := RasterBgra new(monochrome)
			bgr save(destination)
		})
		this add("convert RasterBgra to RasterYuv420Planar to RasterMonochrome", func() {
			source := "test/input/Barn.png"
			destination := "test/output/RasterBgra-RasterYuv420Planar-RasterMonochrome.png"
			bgra := RasterBgra open(source)
			yuv420 := RasterYuv420Planar new(bgra)
			monochrome := RasterMonochrome new(yuv420)
			monochrome save(destination)
		})
		this add("convert RasterBgra to RasterYuv420Semiplanar", func() {
			source := "test/input/Barn.png"
			destination := "test/output/RasterBgra-RasterYuv420Semiplanar-RasterMonochrome.png"
			bgra := RasterBgra open(source)
			yuv420 := RasterYuv420Semiplanar new(bgra)
			monochrome := RasterMonochrome new(yuv420)
			monochrome save(destination)
		})
		this add("convert RasterBgr to RasterYuv420Planar to RasterMonochrome", func() {
			source := "test/input/Barn.png"
			destination := "test/output/RasterBgr-RasterYuv420Planar-RasterMonochrome.png"
			bgr := RasterBgr open(source)
			yuv420 := RasterYuv420Planar new(bgr)
			monochrome := RasterMonochrome new(yuv420)
			monochrome save(destination)
		})
		this add("convert RasterBgr to RasterYuv420Planar and back again", func() {
			source := "test/input/Barn.png"
			destination := "test/output/RasterBgr-RasterYuv420Planar-RasterBgr.png"
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
