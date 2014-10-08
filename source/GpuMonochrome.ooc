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

use ooc-math
use ooc-opengl
import GpuPacked

GpuMonochrome: class extends GpuPacked {
	init: func (size: IntSize2D) {
		super(size, TextureType monochrome, null)
	}
	init: func~fromPixels (data: Pointer, size: IntSize2D) {
		super(size, TextureType monochrome, data)
	}
	create: func (size: IntSize2D) -> This {
		result := This new(size)
		result _texture != null ? result : null
	}
	create2: static func ~empty (size: IntSize2D) -> This {
		result := This new(size)
		result _texture != null ? result : null
	}
	_create: static /* internal */ func ~fromPixels (size: IntSize2D, data: Pointer) -> This {
		result := This new(data, size)
		result _texture != null ? result : null
	}

}
