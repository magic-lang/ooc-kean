//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This _program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This _program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this _program. If not, see <http://www.gnu.org/licenses/>.
use ooc-math

GpuMapType: enum {
	defaultmap
	transform
	pack
	blendMap
}

GpuMap: abstract class {
	model: FloatTransform3D { get set }
	view: FloatTransform3D { get set }
	projection: FloatTransform3D { get set }
	use: virtual func
	init: func {
		this model = FloatTransform3D identity
		this view = FloatTransform3D identity
		this projection = FloatTransform3D identity
	}
}
