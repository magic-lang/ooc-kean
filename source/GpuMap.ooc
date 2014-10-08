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
use ooc-base
use ooc-math
import OpenGLES3/ShaderProgram

GpuMap: abstract class {
	_program: ShaderProgram
	_onUse: Func

	init: func (vertexSource: String, fragmentSource: String, onUse: Func) {
		this _onUse = onUse;
		this _program = ShaderProgram create(vertexSource, fragmentSource)
	}
	dispose: func {
		if(this _program != null)
			this _program dispose()
	}
	use: func {
		if(this _program != null) {
			this _program use()
			this _onUse()
		}
	}
}
