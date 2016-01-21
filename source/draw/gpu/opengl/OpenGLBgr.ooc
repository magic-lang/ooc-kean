/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with This software. If not, see <http://www.gnu.org/licenses/>.
*/

use base
use geometry
use draw
use draw-gpu
import backend/GLTexture
import OpenGLCanvas, OpenGLPacked, OpenGLContext

version(!gpuOff) {
OpenGLBgr: class extends OpenGLPacked {
	init: func (size: IntVector2D, stride: UInt, data: Pointer, coordinateSystem: CoordinateSystem, context: OpenGLContext) {
		super(context _backend createTexture(TextureType Bgr, size, stride, data, true), This channelCount, context)
		this _coordinateSystem = coordinateSystem
	}
	init: func ~empty (size: IntVector2D, context: OpenGLContext) {
		this init(size, size x * This channelCount, null, CoordinateSystem YUpward, context)
	}
	init: func ~fromRaster (rasterImage: RasterBgr, context: OpenGLContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, rasterImage coordinateSystem, context)
	}
	toRasterDefault: override func -> RasterImage { Debug raise("toRaster not implemented for BGR"); null }
	create: override func (size: IntVector2D) -> This { this context createBgr(size) as This }
	channelCount: static Int = 3
}
}
