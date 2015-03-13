
use ooc-draw
import GraphicBuffer
GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	init: func (=_buffer) {
		(buffer: ByteBuffer, size: IntSize2D, align := 0, verticalAlign := 0)
		ptr := _buffer lock()
		buffer unlock()
		bytebuffer := ByteBuffer new(ptr, _buffer length, func (buffer: ByteBuffer) {} )
		super(byteBuffer, _buffer size)
	}
}
