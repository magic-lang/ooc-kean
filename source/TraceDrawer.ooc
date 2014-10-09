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
use ooc-opengl
use ooc-math
import structs/LinkedList

TraceDrawer: class {
	pointList: static LinkedList<FloatPoint2D>
	shaderProgram: ShaderProgram
	positions: Float*
	pointCount: Int = 60
	screenSize: IntSize2D

	init: func (=screenSize) {
		if(This pointList == null)
			This pointList = LinkedList<FloatPoint2D> new()
		This pointList clear()
		this positions = gc_malloc(Float size * this pointCount * 2) as Float*
		for(i in 0..this pointCount) {
			this positions[2 * i] = 0
			this positions[2 * i + 1] = 0
		}
		this shaderProgram = ShaderProgram create(This vertexSource, This fragmentSource)
	}
	add: func(transform: FloatTransform2D) {
		transformedPosition := FloatPoint2D new(transform g + this screenSize width / 4, transform h + this screenSize height / 4)
		This pointList add(transformedPosition)
		if(This pointList size > this pointCount) {
			This pointList removeAt(0)
		}
	}
	clear: func {
		This pointList clear()
	}
	draw: func {
		for(i in 0..This pointList size) {
			this positions[2 * i] = This pointList[i] x / (this screenSize width / 2)
			this positions[2 * i + 1] = This pointList[i] y / (this screenSize height / 2)
		}
		this shaderProgram use()
		Lines draw(this positions, this pointList size, 2, 1.5f)
	}

	vertexSource: static String
	fragmentSource: static String
}
