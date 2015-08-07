import math
use ooc-draw
use ooc-math
use ooc-base
use ooc-draw-gpu
import GraphicBuffer, AndroidContext
GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	buffer ::= this _buffer
	_stride: Int
	stride ::= this _stride
	_uvOffset: Int
	uvOffset ::= this _uvOffset
	uvPadding ::= (this _uvOffset - this _stride * this _size height)
	init: func ~fromBuffer (=_buffer, size: IntSize2D, =_stride, =_uvOffset) {
		ptr := _buffer lock()
		_buffer unlock()
		length := 3 * this _stride * size height / 2
		byteBuffer := ByteBuffer new(ptr, length, func (buffer: ByteBuffer) {} )
		super(byteBuffer, size, 1, 1)
	}
	init: func (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, format: GraphicBufferFormat, stride: Int, uvOffset: Int) {
		this init(GraphicBuffer new(backend, nativeBuffer, handle, size, stride, format), size, stride, uvOffset)
	}
	free: override func {
		this _buffer free()
		super()
	}
	toRgba: func (context: AndroidContext) -> GpuBgra {
		padding := this _uvOffset - this _stride * this _size height
		extraRows := Int align(padding, this _stride) / this _stride
		height := this _size height + this _size height / 2 + extraRows
		width := this _stride / 4
		rgbaBuffer := GraphicBuffer new(this buffer handle, IntSize2D new(width, height), width, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage Rendertarget)
		result := context createBgra(rgbaBuffer)
		result coordinateSystem = this coordinateSystem
	}
	new: unmangled(kean_draw_gpu_android_graphicBufferYuv420Semiplanar_new) static func ~API (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntSize2D, stride: Int, format: GraphicBufferFormat, uvOffset: Int) -> This {
		This new(backend, nativeBuffer, handle, size, format, stride, uvOffset)
	}
}
