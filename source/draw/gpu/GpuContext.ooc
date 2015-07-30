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
use ooc-draw
use ooc-base
use ooc-collections
import GpuImage, GpuMonochrome, GpuUv, GpuBgr, GpuBgra, GpuYuv420Semiplanar, GpuYuv420Planar, GpuYuv422Semipacked, GpuImageBin, GpuSurface, GpuMap, GpuFence

AlignWidth: enum {
	Nearest
	Floor
	Ceiling
}

GpuContext: abstract class {
	_imageBin := GpuImageBin new()
	init: func
	free: override func {
		this _imageBin free()
		super()
	}
	clean: virtual func { this _imageBin clean() }
	createMonochrome: abstract func (size: IntSize2D) -> GpuMonochrome
	createBgr: abstract func (size: IntSize2D) -> GpuBgr
	createBgra: abstract func (size: IntSize2D) -> GpuBgra
	createUv: abstract func (size: IntSize2D) -> GpuUv
	createYuv420Semiplanar: abstract func (size: IntSize2D) -> GpuYuv420Semiplanar
	createYuv420Semiplanar: abstract func ~fromImages (y: GpuMonochrome, uv: GpuUv) -> GpuYuv420Semiplanar
	createYuv420Planar: abstract func (size: IntSize2D) -> GpuYuv420Planar
	createYuv422Semipacked: abstract func (size: IntSize2D) -> GpuYuv422Semipacked
	createGpuImage: abstract func (rasterImage: RasterImage) -> GpuImage
	createFence: abstract func -> GpuFence
	update: abstract func
	recycle: abstract func ~image (gpuImage: GpuImage)
	toRaster: virtual func (gpuImage: GpuImage, async: Bool = false) -> RasterImage { gpuImage toRasterDefault() }
	toRasterAsync: virtual func (gpuImage: GpuImage) -> (RasterImage, GpuFence) { Debug raise("toRasterAsync unimplemented") }
	getMap: abstract func (gpuImage: GpuImage, mapType := GpuMapType defaultmap) -> GpuMap
	getMaxContexts: func -> Int { 1 }
	setViewport: abstract func (viewport: IntBox2D)
	getCurrentIndex: func -> Int { 0 }
	alignWidth: virtual func (width: Int, align := AlignWidth Nearest) -> Int { width }
	isAligned: virtual func (width: Int) -> Bool { true }
	packToRgba: abstract func (source: GpuImage, target: GpuBgra, viewport: IntBox2D)
	drawLines: abstract func (pointList: VectorList<FloatPoint2D>, transform: FloatTransform3D)
	drawBox: abstract func (box: FloatBox2D, transform: FloatTransform3D)
	drawPoints: abstract func (pointList: VectorList<FloatPoint2D>, transform: FloatTransform3D)
	drawQuad: abstract func
}
