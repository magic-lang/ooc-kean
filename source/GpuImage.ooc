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
use ooc-draw
use ooc-math
use ooc-base
use ooc-opengl
import GpuBgra, GpuBgr, GpuMonochrome, GpuYuv420Planar, GpuYuv420Semiplanar, GpuCanvas

GpuImage: abstract class extends Image implements IDisposable {
	_texture: Texture
	texture: /* internal */ Texture { get { _texture } }
	ratio: Float { get {this size width as Float / this size height as Float } }

	init: func (=size)
	_bind: abstract func
	create: static func ~Monochrome (image: RasterMonochrome) -> GpuMonochrome {
		GpuMonochrome _create(image size, image pointer)
	}
	create: static func ~Bgr (image: RasterBgr) -> GpuBgr {
		GpuBgr _create(image size, image pointer)
	}
	create: static func ~Bgra (image: RasterBgra) -> GpuBgra {
		GpuBgra _create(image size, image pointer)
	}
	create: static func ~Yuv420Planar (image: RasterYuv420Planar) -> GpuYuv420Planar {
		GpuYuv420Planar _create(image size, image y pointer, image u pointer, image v pointer)
	}
	create: static func ~Yuv420Semiplanar (image: RasterYuv420Semiplanar) -> GpuYuv420Semiplanar {
		GpuYuv420Semiplanar _create(image size, image y pointer, image uv pointer)
	}

	recycle: abstract func
	generateMipmap: func

	//TODO: Implement abstract functions
	resizeTo: func (size: IntSize2D) -> This {
		raise("Using unimplemented function reSizeTo in GpuImage class")
	}
	copy: func -> This {
		raise("Using unimplemented function copy in GpuImage class")
	}
	copy: func ~fromParams (size: IntSize2D, transform: FloatTransform2D) -> This {
		raise("Using unimplemented function copy ~fromParams in GpuImage class")
	}
	shift: func (offset: IntSize2D) -> This {
		raise("Using unimplemented function shift in GpuImage class")
	}
	distance: func (other: This) -> Float {
		raise("Using unimplemented function distance in GpuImage class")
	}

}
