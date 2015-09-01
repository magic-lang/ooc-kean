use ooc-unit
use ooc-draw
use ooc-base
use ooc-math
import math
import lang/IO
import io/File
import StbImage

ImageFileTest: class extends Fixture {
	init: func {
		super("ImageFile")
		File new("test/draw/output") mkdir()
		this add("First", func {
			expect(1, is equal to(1))
		})
		this add("open PNG", func {
			source := "test/draw/input/Space.png"
			destination := "test/draw/output/outputPNG.png"
			requiredComponents := 4
			x, y, n: Int
			data := StbImage load(source, x&, y&, n&, requiredComponents)
			version(debugTests) {
				failureReason := StbImage failureReason()
				println()
				failureReason toString() println()
				x toString() println()
				y toString() println()
				n toString() println()
			}
			StbImage writePng(destination, x, y, 4, data, x * 4)
			version(debugTests) {
				failureReason = StbImage failureReason()
				failureReason toString() println()
			}
		})
		this add("open JPEG", func {
			source := "test/draw/input/Flower.jpg"
			destination := "test/draw/output/outputJPEG.png"
			requiredComponents := 4
			x, y, n: Int
			data := StbImage load(source, x&, y&, n&, requiredComponents)
			version(debugTests) {
				failureReason := StbImage failureReason()
				println()
				failureReason toString() println()
				x toString() println()
				y toString() println()
				n toString() println()
			}
			StbImage writePng(destination, x, y, 4, data, x * 4)
			version(debugTests) {
				failureReason = StbImage failureReason()
				failureReason toString() println()
			}
		})
		this add("open png RasterBgra", func {
			source := "test/draw/input/Space.png"
			destination := "test/draw/output/pngRasterBgra.png"
			image := RasterBgra open(source)
			image save(destination)
		})
		this add("open png RasterBgr", func {
			source := "test/draw/input/Space.png"
			destination := "test/draw/output/pngRasterBgr.png"
			image := RasterBgr open(source)
			image save(destination)
		})
		this add("open png RasterMonochrome", func {
			source := "test/draw/input/Barn.png"
			destination := "test/draw/output/pngRasterMonochrome.png"
			image := RasterMonochrome open(source)
			image save(destination)
		})
		this add("open jpg RasterBgra", func {
			source := "test/draw/input/Hercules.jpg"
			destination := "test/draw/output/jpgRasterBgra.png"
			image := RasterBgra open(source)
			image save(destination)
		})
		this add("open jpg RasterBgr", func {
			source := "test/draw/input/Hercules.jpg"
			destination := "test/draw/output/jpgRasterBgr.png"
			image := RasterBgr open(source)
			image save(destination)
		})
		this add("open jpg RasterMonochrome", func {
			source := "test/draw/input/Hercules.jpg"
			destination := "test/draw/output/jpgRasterMonochrome.png"
			image := RasterMonochrome open(source)
			image save(destination)
		})
		//TODO: Make these work
		this add("convert RasterMonochrome to RasterBgra", func {
			source := "test/draw/input/Space.jpg"
			destination := "test/draw/output/RasterMonochrome-RasterBgra.png"
			monochrome := RasterMonochrome open(source)
			bgra := RasterBgra convertFrom(monochrome)
			bgra save(destination)
		})
		this add("convert RasterBgra to RasterMonochrome", func {
			source := "test/draw/input/Space.png"
			destination := "test/draw/output/RasterBgra-RasterMonochrome.png"
			bgra := RasterBgra open(source)
			monochrome := RasterMonochrome convertFrom(bgra)
			monochrome save(destination)
		})
		this add("convert RasterBgr to RasterMonochrome", func {
			source := "test/draw/input/Hercules.png"
			destination := "test/draw/output/RasterBgr-RasterMonochrome.png"
			bgr := RasterBgr open(source)
			monochrome := RasterMonochrome convertFrom(bgr)
			monochrome save(destination)
		})
		this add("convert RasterMonochrome to RasterBgr", func {
			source := "test/draw/input/Hercules.png"
			destination := "test/draw/output/RasterMonochrome-RasterBgr.png"
			monochrome := RasterMonochrome open(source)
			bgr := RasterBgr convertFrom(monochrome)
			bgr save(destination)
		})
		this add("convert RasterBgr to RasterBgra", func {
			source := "test/draw/input/Hercules.png"
			destination := "test/draw/output/RasterBgr-RasterBgra.png"
			bgr := RasterBgr open(source)
			bgra := RasterBgra convertFrom(bgr)
			bgra save(destination)
		})
		this add("convert RasterBgra to RasterBgr", func {
			source := "test/draw/input/Hercules.png"
			destination := "test/draw/output/RasterBgra-RasterBgr.png"
			bgra := RasterBgra open(source)
			bgr := RasterBgr convertFrom(bgra)
			bgr save(destination)
		})
/*		this add("convert RasterBgra to RasterYuv420Planar to RasterMonochrome", func {
			source := "test/draw/input/Barn.png"
			destination := "test/draw/output/RasterBgra-RasterYuv420Planar-RasterMonochrome.png"
			bgra := RasterBgra open(source)
			yuv420 := RasterYuv420Planar new(bgra)
			monochrome := RasterMonochrome new(yuv420)
			monochrome save(destination)
		})
*/		this add("convert RasterBgra to RasterYuv420Semiplanar", func {
			source := "test/draw/input/Barn.png"
			destination := "test/draw/output/RasterBgra-RasterYuv420Semiplanar-RasterMonochrome.png"
			bgra := RasterBgra open(source)
			yuv420 := RasterYuv420Semiplanar convertFrom(bgra)
			monochrome := RasterMonochrome convertFrom(yuv420)
			monochrome save(destination)
		})
/*		this add("convert RasterBgr to RasterYuv420Planar to RasterMonochrome", func {
			source := "test/draw/input/Barn.png"
			destination := "test/draw/output/RasterBgr-RasterYuv420Planar-RasterMonochrome.png"
			bgr := RasterBgr open(source)
			yuv420 := RasterYuv420Planar new(bgr)
			monochrome := RasterMonochrome new(yuv420)
			monochrome save(destination)
		})
		this add("convert RasterBgr to RasterYuv420Planar and back again", func {
			source := "test/draw/input/Barn.png"
			destination := "test/draw/output/RasterBgr-RasterYuv420Planar-RasterBgr.png"
			bgr := RasterBgr open(source)
			yuv420 := RasterYuv420Planar new(bgr)
			bgr2 := RasterBgr new(yuv420)
			bgr2 save(destination)
		})
*/		this add("convert RasterBgra to RasterYuv420Semiplanar and back again", func {
			source := "test/draw/input/Flower.png"
			destination := "test/draw/output/RasterBgr-RasterYuv420Semiplanar-RasterBgr.png"
			bgr := RasterBgr open(source)
			semiplanar := RasterYuv420Semiplanar convertFrom(bgr)
			bgr2 := RasterBgr convertFrom(semiplanar)
			bgr2 save(destination)
		})
		this add("Open and save RasterYuv420Semiplanar", func {
			source := "test/draw/input/Flower.png"
			destination := "test/draw/output/RasterYuv420Semiplanar.png"
			semiplanar := RasterYuv420Semiplanar open(source)
			semiplanar save(destination)
		})
		this add("save to bin", func {
			source := "test/draw/input/Flower.png"
			destination := "test/draw/output/Flower.bin"
			semiplanar := RasterYuv420Semiplanar open(source)
			semiplanar saveRaw(destination)
		})
		this add("load from bin", func {
			source := "test/draw/output/Flower.bin"
			destination := "test/draw/output/FromBinary.png"
			semiplanar := RasterYuv420Semiplanar openRaw(source, IntSize2D new(636, 424))
			semiplanar save(destination)
		})
	}
}
ImageFileTest new() run()
