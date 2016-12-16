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
use concurrent
import DrawContext
import GpuImage, Map, GpuYuv420Semiplanar, Mesh

ToRasterFuture: class extends Future<RasterImage> {
	_result: RasterImage
	init: func (=_result) {
		super()
		this _result referenceCount increase()
	}
	free: override func {
		this _result referenceCount decrease()
		super()
	}
	wait: override func (time: TimeSpan) -> Bool { true }
	getResult: override final func (defaultValue: RasterImage) -> RasterImage {
		this _result referenceCount increase()
		this _result
	}
}

GpuContext: abstract class extends DrawContext {
	defaultMap ::= null as Map
	init: func {
		version(gpuOff)
			Debug error("Creating GpuContext without GPU")
	}
	createMonochrome: abstract func (size: IntVector2D) -> GpuImage
	createRgb: abstract func (size: IntVector2D) -> GpuImage
	createRgba: abstract func (size: IntVector2D) -> GpuImage
	createUv: abstract func (size: IntVector2D) -> GpuImage
	createImage: abstract func (rasterImage: RasterImage) -> GpuImage
	createYuv420Semiplanar: override func (size: IntVector2D) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(size, this) }
	createYuv420Semiplanar: override func ~fromImages (y, uv: Image) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(y as GpuImage, uv as GpuImage, this) }
	createYuv420Semiplanar: override func ~fromRaster (raster: RasterYuv420Semiplanar) -> GpuYuv420Semiplanar { GpuYuv420Semiplanar new(raster, this) }
	createMesh: abstract func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> Mesh
	createGrid: abstract func (size: IntVector2D, vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> Mesh
	getYuvToRgba: abstract func -> Map
	getRgbaToY: abstract func -> Map
	getRgbaToUv: abstract func -> Map
	toRaster: virtual func (source: GpuImage) -> RasterImage { source toRasterDefault() }
	toRaster: virtual func ~target (source: GpuImage, target: RasterImage) -> Promise {
		source toRasterDefault(target)
		Promise empty
	}
	toRasterAsync: virtual func (source: GpuImage) -> ToRasterFuture { Debug error("toRasterAsync unimplemented"); null }
}
