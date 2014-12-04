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
use ooc-collections

import structs/LinkedList
import OpenGLES3Map, OpenGLES3/Lines

OverlayDrawer: class {
	linesShader: OpenGLES3MapLines
	pointsShader: OpenGLES3MapPoints
	boxPositions: Float*
	init: func {
		this linesShader = OpenGLES3MapLines new()
		this pointsShader = OpenGLES3MapPoints new()
		pointsShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		pointsShader pointSize = 5.0f
		this boxPositions = gc_malloc(Float size  * 10) as Float*
	}
	__destroy__: func {
		this linesShader dispose()
		this pointsShader dispose()
	}
	drawLines: func (pointList: VectorList<FloatPoint2D>) {
		positions := pointList pointer as Float*
		this linesShader color = FloatPoint3D new(0.0f, 0.0f, 0.0f)
		this linesShader use()
		Lines draw(positions, pointList count, 2, 3.5f)
		this linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this linesShader use()
		Lines draw(positions, pointList count, 2, 1.5f)
	}

	drawBox: func (box: IntBox2D, size: IntSize2D) {
		this boxPositions[0] =  2.0f * (box leftTop x as Float / size width as Float)
		this boxPositions[1] =  2.0f * (box leftTop y as Float / size height as Float)
		this boxPositions[2] =  2.0f * (box rightTop x as Float / size width as Float)
		this boxPositions[3] =  2.0f * (box rightTop y as Float / size height as Float)
		this boxPositions[4] =  2.0f * (box rightBottom x as Float / size width as Float)
		this boxPositions[5] =  2.0f * (box rightBottom y as Float / size height as Float)
		this boxPositions[6] =  2.0f * (box leftBottom x as Float / size width as Float)
		this boxPositions[7] =  2.0f * (box leftBottom y as Float / size height as Float)
		this boxPositions[8] =  2.0f * (box leftTop x as Float / size width as Float)
		this boxPositions[9] =  2.0f * (box leftTop y as Float / size height as Float)
		this linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this linesShader use()
		Lines draw(this boxPositions, 5, 2, 1.5f)
	}

	drawPoints: func (pointList: VectorList<FloatPoint2D>, size: IntSize2D) {
		positions: Float*
		positions = gc_malloc(Float size  * pointList count * 2) as Float*
		for(i in 0..pointList count) {
			positions[2 * i] = 2.0f * pointList[i] x / (size width as Float)
			positions[2 * i + 1] = 2.0f * pointList[i] y / (size height as Float)
		}
		pointsShader use()
		Points draw(positions, pointList count, 2)
		gc_free(positions)
	}
}
