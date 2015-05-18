
use ooc-draw
use ooc-math
use ooc-base
use ooc-draw-gpu
import GraphicBuffer, AndroidContext
GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	buffer ::= this _buffer
	_stride: Int
	_uvOffset: Int
	uvOffset ::= this _uvOffset
	uvPadding ::= (this _uvOffset - this _stride * this _size height)
	init: func ~fromBuffer (=_buffer, size: IntSize2D, =_stride, =_uvOffset) {
		ptr := _buffer lock()
		_buffer unlock()
		length := 3 * this _stride * size width / 2
		byteBuffer := ByteBuffer new(ptr, length, func (buffer: ByteBuffer) {} )
		super(byteBuffer, size, 1, 1)
	}
	init: func (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, format: GraphicBufferFormat, stride: Int, uvOffset: Int) {
		this init(GraphicBuffer new(backend, nativeBuffer, handle, size, stride, format), size, stride, uvOffset)
	}
	toRgba: func (context: AndroidContextManager) -> GpuBgra {
		padding := this _uvOffset - this _stride * this _size height
		extraRows := Int align(padding, this _size width) / this _size width
		height := this _size height + this _size height / 2 + extraRows
		width := this _stride / 4
		rgbaBuffer := GraphicBuffer new(this buffer handle, IntSize2D new(width, height), width, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage Rendertarget)
		context createBgra(rgbaBuffer)
	}
	new: unmangled(kean_draw_gpu_android_graphicBufferYuv420Semiplanar_new) static func ~API (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, stride: Int, format: GraphicBufferFormat, uvOffset: Int) -> This {
		This new(backend, nativeBuffer, handle, size, format, stride, uvOffset)
	}
}
