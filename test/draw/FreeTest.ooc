use ooc-unit
use ooc-draw
use ooc-base
use ooc-math
import math
import lang/IO
import io/File
import StbImage

version(debugTests) {
  //source := "../ooc-vidproc-run-input/Yuv420Semiplanar/bird/frame00001.png.bin"
  //image := RasterYuv420Semiplanar openBin(source, 720, 576)
  //for (i in 0..20) {
  //	copy := image copy()
  //	copy free()
  //}
  //image free()
  image := RasterYuv420Semiplanar new(IntSize2D new(20, 40))
  image size toString() println()
  //image buffer size toString() println()
  //image save("bild.png")
}
