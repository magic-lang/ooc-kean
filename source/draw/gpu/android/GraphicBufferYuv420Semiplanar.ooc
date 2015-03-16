
use ooc-draw
use ooc-math
use ooc-base
import GraphicBuffer
GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	buffer ::= this _buffer
	init: func ~fromBuffer (=_buffer) {
		ptr := _buffer lock()
		_buffer unlock()
		byteBuffer := ByteBuffer new(ptr, _buffer length, func (buffer: ByteBuffer) {} )
		super(byteBuffer, _buffer size)
	}
	init: func (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, format: GraphicBufferFormat, verticalAlign: Int, horizontalAlign: Int) {
		this init(GraphicBuffer new(backend, nativeBuffer, handle, size, format, verticalAlign, horizontalAlign))
	}
	new: unmangled(kean_draw_gpu_android_graphicBufferYuv420Semiplanar_new) static func ~API (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, format: GraphicBufferFormat, verticalAlign: Int, horizontalAlign: Int) -> This {
		This new(backend, nativeBuffer, handle, size, format, verticalAlign, horizontalAlign)
	}
}
