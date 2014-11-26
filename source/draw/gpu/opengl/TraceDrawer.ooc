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

TraceDrawer: class {
	linesShader: OpenGLES3MapLines
	pointsShader: OpenGLES3MapPoints
	scale: Float = 1.0f
	init: func () {
		this linesShader = OpenGLES3MapLines new()
		this pointsShader = OpenGLES3MapPoints new()
		pointsShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		pointsShader pointSize = 5.0f
	}
	__destroy__: func {
		this linesShader dispose()
		this pointsShader dispose()
	}
	drawTrace: func (pointList: LinkedList<FloatPoint2D>, positions: Float*, screenSize: IntSize2D) {
		//Go from screen coordinates to normalized coordinates [-1, 1] [-1, 1]
		for(i in 0..pointList size) {
			positions[2 * i] = 2.0f * pointList[i] x / screenSize width - 1.0f
			positions[2 * i + 1] = 2.0f * pointList[i] y / screenSize height - 1.0f
		}
		crosshairStart := pointList size * 2
		crosshairSize := FloatPoint2D new(0.05f, 0.05f * screenSize width as Float / screenSize height as Float)
		currentPoint := FloatPoint2D new(positions[2 * pointList size - 2], positions[2 * pointList size - 1])

		positions[crosshairStart] = currentPoint x
		positions[crosshairStart + 1] = currentPoint y + crosshairSize y

		positions[crosshairStart + 2] = currentPoint x
		positions[crosshairStart + 3] = currentPoint y - crosshairSize y

		positions[crosshairStart + 4] = currentPoint x
		positions[crosshairStart + 5] = currentPoint y

		positions[crosshairStart + 6] = currentPoint x + crosshairSize x
		positions[crosshairStart + 7] = currentPoint y

		positions[crosshairStart + 8] = currentPoint x - crosshairSize x
		positions[crosshairStart + 9] = currentPoint y

		this linesShader color = FloatPoint3D new(0.0f, 0.0f, 0.0f)
		this linesShader use()
		Lines draw(positions, pointList size + 5, 2, 3.5f)
		this linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this linesShader use()
		Lines draw(positions, pointList size + 5, 2, 1.5f)
		gc_free(positions)
	}

	drawBox: func (box: IntBox2D, size: IntSize2D) {
		positions: Float*
		positions = gc_malloc(Float size  * 10) as Float*
		positions[0] = 2.0f * (box leftTop x as Float / size width as Float)
		positions[1] =  2.0f * (box leftTop y as Float / size height as Float)
		positions[2] =  2.0f * (box rightTop x as Float / size width as Float)
		positions[3] =  2.0f * (box rightTop y as Float / size height as Float)
		positions[4] =  2.0f * (box rightBottom x as Float / size width as Float)
		positions[5] =  2.0f * (box rightBottom y as Float / size height as Float)
		positions[6] =  2.0f * (box leftBottom x as Float / size width as Float)
		positions[7] =  2.0f * (box leftBottom y as Float / size height as Float)
		positions[8] =  2.0f * (box leftTop x as Float / size width as Float)
		positions[9] =  2.0f * (box leftTop y as Float / size height as Float)
		this linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this linesShader use()
		Lines draw(positions, 5, 2, 1.5f)
		gc_free(positions)
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
