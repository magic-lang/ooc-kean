//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

//use ooc-opengl
use ooc-draw-gpu
use ooc-draw
use ooc-math
import GpuPacker, GpuMapAndroid

DummyWindow: class {
	_context: Context
	_yPacker: GpuPackerY
	_uvPacker: GpuPackerUv
	_uPacker: GpuPackerU
	init: /* internal */ func
	_generate: /* private */ func (other: Context) -> Bool {
		this _context = Context create(other)
		result: UInt = this _context makeCurrent()
		setShaderSources()
		result == 1
	}
	create: static func (other: DummyWindow)-> This {
		result := This new()
		success := false
		if(other != null)
			success = result _generate(other _context)
		else
			success = result _generate(null)

		if(success) {
			result _yPacker = GpuPackerY create(result _context)
			result _uvPacker = GpuPackerUv create(result _context)
			result _uPacker = GpuPackerU create(result _context)
		}
		success ? result : null
	}
	dispose: func {
		this _yPacker dispose()
		this _uvPacker dispose()
		this _uPacker dispose()
		this _context dispose()
	}
	packPyramid: func ~monochrome (image: RasterMonochrome, count: Int) -> Pointer {
		result := this _yPacker packPyramid(image, count)
		result
	}
	copyPixels: func ~Yuv420Semiplanar(image: GpuYuv420Semiplanar, destination: RasterYuv420Semiplanar) {
		yPixels := this _yPacker pack(image y)
		destinationPointer := destination y pointer
		destinationStride := destination y stride
		paddedBytes := 640 + 1920 - image size width;
		for(row in 0..image size height) {
			sourceRow := yPixels + row * (image size width + paddedBytes)
			destinationRow := destinationPointer + row * destinationStride
			memcpy(destinationRow, sourceRow, image size width)
		}
		this _yPacker unlock()

		uvPixels := this _uvPacker pack(image uv)
		uvOffset := destination y stride * destination y size height + (Int align(destination y size height, destination byteAlignment height) - destination y size height) * destination y stride
		uvDestination := destinationPointer + uvOffset
		for(row in 0..image size height / 2) {
			sourceRow := uvPixels + row * (image size width + paddedBytes)
			destinationRow := uvDestination + row * destinationStride
			memcpy(destinationRow, sourceRow, image size width)
		}
		this _uvPacker unlock()
	}
	_clear: func
	_bind: func
}
