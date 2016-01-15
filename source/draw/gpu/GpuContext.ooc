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
use ooc-geometry
use ooc-draw
use ooc-base
use ooc-collections
import AbstractContext
import GpuImage, GpuSurface, GpuMap, GpuFence, GpuYuv420Semiplanar, GpuMesh

version(!gpuOff) {
GpuContext: abstract class extends AbstractContext {
	defaultMap ::= null as GpuMap
	init: func
	createMonochrome: abstract func (size: IntVector2D) -> GpuImage
	createBgr: abstract func (size: IntVector2D) -> GpuImage
	createBgra: abstract func (size: IntVector2D) -> GpuImage
	createUv: abstract func (size: IntVector2D) -> GpuImage
	createImage: abstract func (rasterImage: RasterImage) -> GpuImage
	createFence: abstract func -> GpuFence
	createYuv420Semiplanar: override func (size: IntVector2D) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(size, this) }
	createYuv420Semiplanar: override func ~fromImages (y, uv: GpuImage) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(y, uv, this) }
	createYuv420Semiplanar: override func ~fromRaster (raster: RasterYuv420Semiplanar) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(raster, this) }
	createMesh: abstract func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> GpuMesh

	update: abstract func
	packToRgba: abstract func (source: GpuImage, target: GpuImage, viewport: IntBox2D,  padding := 0)
	finish: func { this createFence() sync() . wait() . free() }

	toRaster: virtual func (gpuImage: GpuImage) -> RasterImage { gpuImage toRasterDefault() }
	toRasterAsync: virtual func (gpuImage: GpuImage) -> (RasterImage, GpuFence) { Debug raise("toRasterAsync unimplemented") }
}
}
