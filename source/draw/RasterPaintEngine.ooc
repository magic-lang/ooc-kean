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

use ooc-base
use ooc-math
import Color, RasterBgr, RasterBgra, RasterMonochrome, RasterYuv420Semiplanar, Image
import PaintEngine

RasterPaintEngine: abstract class extends PaintEngine {
	_imageSize: IntSize2D
	init: func (=_imageSize) { super() }
	_map: func (point: IntPoint2D) -> IntPoint2D {
		IntPoint2D new(point x + this _imageSize width / 2, point y + this _imageSize height / 2)
	}
}

MonochromePaintEngine: class extends RasterPaintEngine {
	_image: RasterMonochrome
	init: func (=_image) { super(this _image size) }
	drawPoint: func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this _image isValidIn(position x, position y))
			this _image[position x, position y] = this _image[position x, position y] blend(this pen alphaAsFloat, this pen color toMonochrome())
	}
}

BgrPaintEngine: class extends RasterPaintEngine {
	_image: RasterBgr
	init: func (=_image) { super(this _image size) }
	drawPoint: func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this _image isValidIn(position x, position y))
			this _image[position x, position y] = this _image[position x, position y] blend(this pen alphaAsFloat, this pen color toBgr())
	}
}

BgraPaintEngine: class extends RasterPaintEngine {
	_image: RasterBgra
	init: func (=_image) { super(this _image size) }
	drawPoint: func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this _image isValidIn(position x, position y))
			this _image[position x, position y] = this _image[position x, position y] blend(this pen alphaAsFloat, this pen color toBgra())
	}
}

Yuv420PaintEngine: class extends RasterPaintEngine {
	_image: RasterYuv420Semiplanar
	init: func (=_image) { super(this _image size) }
	drawPoint: func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this _image isValidIn(position x, position y))
			this _image[position x, position y] = this _image[position x, position y] blend(this pen alphaAsFloat, this pen color toYuv())
	}
}
