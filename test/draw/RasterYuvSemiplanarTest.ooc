use ooc-base
use ooc-draw
use ooc-math

//path := "test/draw/input/ElephantSeal.jpg"
path := "../ooc-vidproc-run-input/Yuv420Semiplanar/bird/frame00001.png.bin"
for (i in 0..1) {
	image := RasterYuv420Semiplanar openRaw(path, IntSize2D new(720, 576))
	y := image y
	uv := image uv
	yBuffer := y buffer
	uvBuffer := uv buffer
	r := image referenceCount
	yb := yBuffer as _SlicedByteBuffer
	yr := y referenceCount
	ybr := yb referenceCount
	ybbr := yb _parent referenceCount
	uvb := uvBuffer as _SlicedByteBuffer
	uvr := uv referenceCount
	uvbr := uvb referenceCount
	uvbbr := uvb _parent referenceCount

	"image RC: #{r _count}" println()
	"y RC: #{yr _count}" println()
	"y buffer RC: #{ybr _count}" println()
	"y buffer buffer RC: #{ybbr _count}" println()
	"uv RC: #{uvr _count}" println()
	"uv buffer RC: #{uvbr _count}" println()
	"uv buffer buffer RC: #{uvbbr _count}" println()


	"\nINCREASE Y" println()
	y referenceCount increase()
	"image RC: #{r _count}" println()
	"y RC: #{yr _count}" println()
	"y buffer RC: #{ybr _count}" println()
	"y buffer buffer RC: #{ybbr _count}" println()
	"uv RC: #{uvr _count}" println()
	"uv buffer RC: #{uvbr _count}" println()
	"uv buffer buffer RC: #{uvbbr _count}" println()


	"\nDECREASE IMAGE" println()
	image referenceCount decrease()
	"image RC: #{r _count}" println()
	"y RC: #{yr _count}" println()
	"y buffer RC: #{ybr _count}" println()
	"y buffer buffer RC: #{ybbr _count}" println()
	"uv RC: #{uvr _count}" println()
	"uv buffer RC: #{uvbr _count}" println()
	"uv buffer buffer RC: #{uvbbr _count}" println()


	"\nDECREASE Y" println()
	y referenceCount decrease()
	"image RC: #{r _count}" println()
	"y RC: #{yr _count}" println()
	"y buffer RC: #{ybr _count}" println()
	"y buffer buffer RC: #{ybbr _count}" println()
	"uv RC: #{uvr _count}" println()
	"uv buffer RC: #{uvbr _count}" println()
	"uv buffer buffer RC: #{uvbbr _count}" println()
}
ByteBuffer clean()
