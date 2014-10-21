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

use ooc-base
use ooc-math
use ooc-draw-gpu

import OpenGLES3/ShaderProgram

OpenGLES3Map: abstract class extends GpuMap {
	_program: ShaderProgram
	_onUse: Func
	init: func (vertexSource: String, fragmentSource: String, onUse: Func) {
		this _onUse = onUse
		this _program = ShaderProgram create(vertexSource, fragmentSource)
	}
	dispose: func {
		if (this _program != null)
			this _program dispose()
	}
	use: func {
		if (this _program != null) {
			this _program use()
			this _onUse()
		}
	}
}

OpenGLES3MapDefault: abstract class extends OpenGLES3Map {
	transform: FloatTransform2D { get set }
	imageSize: IntSize2D { get set }
	screenSize: IntSize2D { get set }
	init: func (fragmentSource: String, onUse: Func) {
		super(This defaultVertexSource, fragmentSource, func {
			onUse()
			this _program setUniform("imageWidth", this imageSize width)
			this _program setUniform("imageHeight", this imageSize height)
			this _program setUniform("screenWidth", this screenSize width)
			this _program setUniform("screenHeight", this screenSize height)
			this _program setUniform("transform", transform)})
	}
	defaultVertexSource: static String
}

OpenGLES3MapOverlay: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}
OpenGLES3MapLines: class extends OpenGLES3Map {
	color: FloatPoint3D { get set }
	init: func {
		super(This vertexSource, This fragmentSource,
			func {
				this _program setUniform("color", this color)
		})
	}
	vertexSource: static String
	fragmentSource: static String
}

OpenGLES3MapBgr: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapBgrToBgra: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapBgra: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapMonochrome: class extends OpenGLES3MapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
				})
	}
	fragmentSource: static String
}

OpenGLES3MapUv: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapMonochromeToBgra: class extends OpenGLES3MapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
				})
	}
	fragmentSource: static String
}

OpenGLES3MapYuvPlanarToBgra: class extends OpenGLES3MapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
					this _program setUniform("texture1", 1)
					this _program setUniform("texture2", 2)
				})
	}
	fragmentSource: static String
}

OpenGLES3MapYuvSemiplanarToBgra: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
				this _program setUniform("texture1", 1)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapPackMonochrome: class extends OpenGLES3MapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
					this _program setUniform("pixelWidth", this imageSize width)
				})
	}

	fragmentSource: static String
}

OpenGLES3MapPackUv: class extends OpenGLES3MapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
					this _program setUniform("pixelWidth", this imageSize width)
				})
	}
	fragmentSource: static String
}
