use ooc-base
use ooc-draw

//path := "test/draw/input/ElephantSeal.jpg"
path := "../../ooc-vidproc-run-input/Yuv420Semiplanar/bird/frame00001.png.bin"
for (i in 0..1) {
	image := RasterYuv420Semiplanar openBin(path, 720, 576)
	y := image y
	uv := image uv
	b := image buffer
	r := image _referenceCount
	br := b _referenceCount
	yb := ((y buffer) as ByteBufferSlice)
	yr := y _referenceCount
	ybr := yb _referenceCount
	ybbr := yb _byteBuffer _referenceCount
	uvb := ((uv buffer) as ByteBufferSlice)
	uvr := uv _referenceCount
	uvbr := uvb _referenceCount
	uvbbr := uvb _byteBuffer _referenceCount
	
	"image RC: #{r _count}" println()
	"image buffer RC: #{br _count}" println()
	"y RC: #{yr _count}" println()
	"y buffer RC: #{ybr _count}" println()
	"y buffer buffer RC: #{ybbr _count}" println()
	"uv RC: #{uvr _count}" println()
	"uv buffer RC: #{uvbr _count}" println()
	"uv buffer buffer RC: #{uvbbr _count}" println()
	
	y increaseReferenceCount()
	"\nINCREASE Y" println()
	
	"image RC: #{r _count}" println()
	"image buffer RC: #{br _count}" println()
	"y RC: #{yr _count}" println()
	"y buffer RC: #{ybr _count}" println()
	"y buffer buffer RC: #{ybbr _count}" println()
	"uv RC: #{uvr _count}" println()
	"uv buffer RC: #{uvbr _count}" println()
	"uv buffer buffer RC: #{uvbbr _count}" println()
	
	image decreaseReferenceCount()
	"\nDECREASE IMAGE" println()
	
	"image RC: #{r _count}" println()
	"image buffer RC: #{br _count}" println()
	"y RC: #{yr _count}" println()
	"y buffer RC: #{ybr _count}" println()
	"y buffer buffer RC: #{ybbr _count}" println()
	"uv RC: #{uvr _count}" println()
	"uv buffer RC: #{uvbr _count}" println()
	"uv buffer buffer RC: #{uvbbr _count}" println()
	
	y decreaseReferenceCount()
	"\nDECREASE Y" println()
	
	"image RC: #{r _count}" println()
	"image buffer RC: #{br _count}" println()
	"y RC: #{yr _count}" println()
	"y buffer RC: #{ybr _count}" println()
	"y buffer buffer RC: #{ybbr _count}" println()
	"uv RC: #{uvr _count}" println()
	"uv buffer RC: #{uvbr _count}" println()
	"uv buffer buffer RC: #{uvbbr _count}" println()
}
ByteBuffer clean()
