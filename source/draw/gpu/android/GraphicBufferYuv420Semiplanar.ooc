
use ooc-draw
use ooc-math
use ooc-base
use ooc-draw-gpu
import GraphicBuffer, AndroidContext
GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	buffer ::= this _buffer
	_horizontalStride: Int
	_verticalStride: Int
	init: func ~fromBuffer (=_buffer, size: IntSize2D, align: Int, verticalAlign: Int) {
		this _horizontalStride = Int align(size width, align)
		this _verticalStride = Int align(size height, verticalAlign)
		ptr := _buffer lock()
		_buffer unlock()
		byteBuffer := ByteBuffer new(ptr, _buffer length, func (buffer: ByteBuffer) {} )
		super(byteBuffer, size, align, verticalAlign)
	}
	init: func (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, format: GraphicBufferFormat, pixelStride: Int, horizontalAlign: Int, verticalAlign: Int) {
		this init(GraphicBuffer new(backend, nativeBuffer, handle, size, pixelStride, format), size, horizontalAlign, verticalAlign)
	}
	toRgba: func (context: AndroidContextManager) -> GpuBgra {
		height := this _verticalStride + this buffer size height / 2
		width := this buffer size width / 4
		rgbaBuffer := GraphicBuffer new(this buffer handle, IntSize2D new(width, height), this _horizontalStride / 4, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage Rendertarget)
		context createBgra(rgbaBuffer)
	}
	new: unmangled(kean_draw_gpu_android_graphicBufferYuv420Semiplanar_new) static func ~API (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, pixelStride: Int, format: GraphicBufferFormat, verticalAlign: Int, horizontalAlign: Int) -> This {
		This new(backend, nativeBuffer, handle, size, format, pixelStride, verticalAlign, horizontalAlign)
	}
}
