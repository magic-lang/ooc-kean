
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
	init: func (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, format: Int, verticalAlign: Int, horizontalAlign: Int) {
		super(GraphicBuffer new(backend, nativeBuffer, handle, size, format, verticalAlign, horizontalAlign))
	}
}
