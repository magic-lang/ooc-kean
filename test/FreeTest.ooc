use ooc-unit
use ooc-draw
use ooc-base
import math
import lang/IO
import io/File
import StbImage

source := "../ooc-vidproc-run-input/Yuv420Semiplanar/bird/frame00001.png.bin"
image := RasterYuv420Semiplanar openBin(source, 720, 576)
for (i in 0..20) {
	copy := image copy()
	copy free()
}
image free()

