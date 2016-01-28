/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use base
use collections
import DrawContext
import GpuImage, GpuSurface, GpuMap, GpuFence, GpuYuv420Semiplanar, GpuMesh

version(!gpuOff) {
GpuContext: abstract class extends DrawContext {
	defaultMap ::= null as GpuMap
	init: func
	createMonochrome: abstract func (size: IntVector2D) -> GpuImage
	createBgr: abstract func (size: IntVector2D) -> GpuImage
	createBgra: abstract func (size: IntVector2D) -> GpuImage
	createUv: abstract func (size: IntVector2D) -> GpuImage
	createImage: abstract func (rasterImage: RasterImage) -> GpuImage
	createFence: abstract func -> GpuFence
	createYuv420Semiplanar: override func (size: IntVector2D) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(size, this) }
	createYuv420Semiplanar: override func ~fromImages (y, uv: Image) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(y as GpuImage, uv as GpuImage, this) }
	createYuv420Semiplanar: override func ~fromRaster (raster: RasterYuv420Semiplanar) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(raster, this) }
	createMesh: abstract func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> GpuMesh

	update: abstract func
	packToRgba: abstract func (source: GpuImage, target: GpuImage, viewport: IntBox2D, padding := 0)
	finish: func { this createFence() sync() . wait() . free() }

	toRaster: virtual func (source: GpuImage) -> RasterImage { source toRasterDefault() }
	toRasterAsync: virtual func (source: GpuImage) -> (RasterImage, GpuFence) {
		result := this toRaster(source)
		fence := this createFence()
		fence sync()
		(result, fence)
	}
}
}
