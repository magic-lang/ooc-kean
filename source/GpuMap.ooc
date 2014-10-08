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
use ooc-opengl

GpuMap: abstract class {
	_program: ShaderProgram
	_onUse: Func

	init: func (vertexSource: String, fragmentSource: String, onUse: Func) {
		this _onUse = onUse;
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

GpuMapDefault: abstract class extends GpuMap {
	transform: FloatTransform2D { get set }
	imageSize: IntSize2D { get set }
	screenSize: IntSize2D { get set }
	init: func (fragmentSource: String, onUse: Func) {
			super(This defaultVertexSource, fragmentSource,
				func {
					onUse()
					this _program setUniform("imageWidth", this imageSize width)
					this _program setUniform("imageHeight", this imageSize height)
					this _program setUniform("screenWidth", this screenSize width)
					this _program setUniform("screenHeight", this screenSize height)
					this _program setUniform("transform", transform)
				})
	}
	initShaders: func {
	}
	defaultVertexSource: static String
}

GpuOverlay: class extends GpuMapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

GpuMapBgr: class extends GpuMapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

GpuMapBgrToBgra: class extends GpuMapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

GpuMapBgra: class extends GpuMapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

GpuMapMonochrome: class extends GpuMapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
				})
	}
	fragmentSource: static String
}

GpuMapUv: class extends GpuMapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

GpuMapMonochromeToBgra: class extends GpuMapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
				})
	}
	fragmentSource: static String
}

GpuMapYuvPlanarToBgra: class extends GpuMapDefault {
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

GpuMapYuvSemiplanarToBgra: class extends GpuMapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
				this _program setUniform("texture1", 1)
			})
	}
	fragmentSource: static String
}

GpuMapPackMonochrome: class extends GpuMapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
					this _program setUniform("pixelWidth", this imageSize width)
				})
	}

	fragmentSource: static String
}

GpuMapPackUv: class extends GpuMapDefault {
	init: func {
			super(This fragmentSource,
				func {
					this _program setUniform("texture0", 0)
					this _program setUniform("pixelWidth", this imageSize width)
				})
	}
	fragmentSource: static String
}
