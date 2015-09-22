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
use ooc-base
use ooc-math
use ooc-draw
use ooc-draw-gpu
use ooc-collections
use ooc-ui
import OpenGLPacked, OpenGLMonochrome, OpenGLBgr, OpenGLBgra, OpenGLUv, OpenGLFence, RecycleBin
import Map/OpenGLMap, Map/OpenGLMapPack
import backend/gles3/[Context, Renderer]

OpenGLContext: class extends GpuContext {
	_backend: Context
	_transformTextureMap: OpenGLMapTransformTexture
	_packMonochrome: OpenGLMapPackMonochrome
	_packUv: OpenGLMapPackUv
	_linesShader: OpenGLMapLines
	_pointsShader: OpenGLMapPoints
	_renderer: Renderer
	defaultMap: GpuMap { get { this _transformTextureMap } }
	_recycleBin := RecycleBin new()

	init: func ~backend (=_backend) {
		super()
		this _packMonochrome = OpenGLMapPackMonochrome new(this)
		this _packUv = OpenGLMapPackUv new(this)
		this _linesShader = OpenGLMapLines new(this)
		this _pointsShader = OpenGLMapPoints new(this)
		this _transformTextureMap = OpenGLMapTransformTexture new(this)
		this _renderer = Renderer new()
	}
	init: func { this init(Context create()) }
	init: func ~shared (other: This) { this init(Context create(other _backend)) }
	init: func ~window (nativeWindow: NativeWindow) { this init(Context create(nativeWindow)) }
	free: override func {
		this _backend makeCurrent()
		this _transformTextureMap free()
		this _packMonochrome free()
		this _packUv free()
		this _linesShader free()
		this _pointsShader free()
		this _backend free()
		this _renderer free()
		this _recycleBin free()
		super()
	}
	getMaxContexts: func -> Int { 1 }
	getCurrentIndex: func -> Int { 0 }
	drawQuad: func { this _renderer drawQuad() }
	drawLines: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D) {
		positions := pointList pointer as Float*
		this _linesShader color = FloatPoint3D new(0.0f, 0.0f, 0.0f)
		this _linesShader projection = projection
		this _linesShader use()
		this _renderer drawLines(positions, pointList count, 2, 3.5f)
		this _linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this _linesShader use()
		this _renderer drawLines(positions, pointList count, 2, 1.5f)
	}
	drawBox: func (box: FloatBox2D, projection: FloatTransform3D) {
		positions: Float[10]
		positions[0] = box leftTop x
		positions[1] = box leftTop y
		positions[2] = box rightTop x
		positions[3] = box rightTop y
		positions[4] = box rightBottom x
		positions[5] = box rightBottom y
		positions[6] = box leftBottom x
		positions[7] = box leftBottom y
		positions[8] = box leftTop x
		positions[9] = box leftTop y
		this _linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this _linesShader projection = projection
		this _linesShader use()
		this _renderer drawLines(positions[0]&, 5, 2, 1.5f)
	}
	drawPoints: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D) {
		positions := pointList pointer
		this _pointsShader projection = projection
		this _pointsShader use()
		this _renderer drawPoints(positions, pointList count, 2)
	}
	recycle: func (image: OpenGLPacked) { this _recycleBin add(image) }
	_searchImageBin: func (type: GpuImageType, size: IntSize2D) -> GpuImage { this _recycleBin find(type, size) }
	createMonochrome: func (size: IntSize2D) -> GpuImage {
		result := this _searchImageBin(GpuImageType monochrome, size)
		result == null ? OpenGLMonochrome new(size, this) as GpuImage : result
	}
	_createMonochrome: func (raster: RasterMonochrome) -> GpuImage {
		result := this _searchImageBin(GpuImageType monochrome, raster size)
		if (result == null)
			result = OpenGLMonochrome new(raster, this)
		else
			result upload(raster)
		result
	}
	createUv: func (size: IntSize2D) -> GpuImage {
		result := this _searchImageBin(GpuImageType uv, size)
		result == null ? OpenGLUv new(size, this) as GpuImage : result
	}
	_createUv: func (raster: RasterUv) -> GpuImage {
		result := this _searchImageBin(GpuImageType uv, raster size)
		if (result == null)
			result = OpenGLUv new(raster, this)
		else
			result upload(raster)
		result
	}
	createBgr: func (size: IntSize2D) -> GpuImage {
		result := this _searchImageBin(GpuImageType bgr, size)
		result == null ? OpenGLBgr new(size, this) as GpuImage : result
	}
	_createBgr: func (raster: RasterBgr) -> GpuImage {
		result := this _searchImageBin(GpuImageType bgr, raster size)
		if (result == null)
			result = OpenGLBgr new(raster, this)
		else
			result upload(raster)
		result
	}
	createBgra: func (size: IntSize2D) -> GpuImage {
		result := this _searchImageBin(GpuImageType bgra, size)
		result == null ? OpenGLBgra new(size, this) as GpuImage : result
	}
	_createBgra: func (raster: RasterBgra) -> GpuImage {
		result := this _searchImageBin(GpuImageType bgra, raster size)
		if (result == null)
			result = OpenGLBgra new(raster, this)
		else
			result upload(raster)
		result
	}
	createGpuImage: virtual override func (rasterImage: RasterImage) -> GpuImage {
		match (rasterImage) {
			case image: RasterMonochrome => this _createMonochrome(image)
			case image: RasterBgr => this _createBgr(image)
			case image: RasterBgra => this _createBgra(image)
			case image: RasterUv => this _createUv(image)
			case image: RasterYuv420Semiplanar => this createYuv420Semiplanar(image)
			case => Debug raise("Unknown input format in OpenGLContext createGpuImage"); null
		}
	}
	update: func { this _backend swapBuffers() }
	packToRgba: func (source: GpuImage, target: GpuImage, viewport: IntBox2D) {
		channels := 1
		map := match (source) {
			case sourceImage: OpenGLMonochrome => this _packMonochrome
			case sourceImage: OpenGLUv => channels = 2; this _packUv
		} as OpenGLMapPack
		map imageWidth = source size width
		map channels = channels
		target canvas viewport = viewport
		target canvas draw(source, map)
	}
	createFence: func -> GpuFence { OpenGLFence new() }
	toRasterAsync: override func (gpuImage: GpuImage) -> (RasterImage, GpuFence) {
		result := this toRaster(gpuImage, true)
		fence := this createFence()
		fence sync()
		(result, fence)
	}
}
