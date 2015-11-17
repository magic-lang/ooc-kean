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

use ooc-math
use ooc-base
use ooc-draw-gpu
import OpenGLMap
import OpenGLContext

version(!gpuOff) {
OpenGLMapPackMonochrome: class extends OpenGLMap {
	init: func (context: OpenGLContext) { super(This vertexSource, This fragmentSource, context) }
	vertexSource: static String = slurp("shaders/packMonochrome.vert")
	fragmentSource: static String = slurp("shaders/packMonochrome.frag")
}
OpenGLMapPackUv: class extends OpenGLMap {
	init: func (context: OpenGLContext) { super(This vertexSource, This fragmentSource, context) }
	vertexSource: static String = slurp("shaders/packUv.vert")
	fragmentSource: static String = slurp("shaders/packUv.frag")
}
OpenGLMapPackUvPadded: class extends OpenGLMap {
	init: func (context: OpenGLContext) { super(This vertexSource, This fragmentSource, context) }
	vertexSource: static String = slurp("shaders/packUvPadded.vert")
	fragmentSource: static String = slurp("shaders/packUvPadded.frag")
}
OpenGLMapUnpack: abstract class extends OpenGLMap {
	init: func (fragmentSource: String, context: OpenGLContext) { super(This vertexSource, fragmentSource, context) }
	vertexSource: static String = slurp("shaders/unpack.vert")
}
OpenGLMapUnpackRgbaToMonochrome: class extends OpenGLMapUnpack {
	init: func (context: OpenGLContext) { super(This fragmentSource, context) }
	fragmentSource: static String = slurp("shaders/unpackRgbaToMonochrome.frag")
}
OpenGLMapUnpackRgbaToUv: class extends OpenGLMapUnpack {
	init: func (context: OpenGLContext) { super(This fragmentSource, context) }
	fragmentSource: static String = slurp("shaders/unpackRgbaToUv.frag")
}
OpenGLMapUnpackRgbaToUvPadded: class extends OpenGLMapUnpack {
	init: func (context: OpenGLContext) { super(This fragmentSource, context) }
	fragmentSource: static String = slurp("shaders/unpackRgbaToUvPadded.frag")
}
}
