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
import OpenGLPacked, OpenGLMonochrome, OpenGLBgr, OpenGLBgra, OpenGLUv, OpenGLFence, OpenGLMesh, OpenGLCanvas, RecycleBin
import Map/OpenGLMap, Map/OpenGLMapPack
import backend/[GLContext, GLRenderer]

version(!gpuOff) {
OpenGLContext: class extends GpuContext {
	_backend: GLContext
	backend ::= this _backend
	_transformTextureMap: OpenGLMapTransformTexture
	_packMonochrome: OpenGLMapPackMonochrome
	_packUv: OpenGLMapPackUv
	_linesShader: OpenGLMapLines
	_pointsShader: OpenGLMapPoints
	_meshShader: OpenGLMapMesh
	meshShader ::= this _meshShader
	_renderer: GLRenderer
	defaultMap: GpuMap { get { this _transformTextureMap } }
	_recycleBin := RecycleBin new()

	init: func ~backend (=_backend) {
		super()
		this _packMonochrome = OpenGLMapPackMonochrome new(this)
		this _packUv = OpenGLMapPackUv new(this)
		this _linesShader = OpenGLMapLines new(this)
		this _pointsShader = OpenGLMapPoints new(this)
		this _transformTextureMap = OpenGLMapTransformTexture new(this)
		this _renderer = _backend createRenderer()
		this _meshShader = OpenGLMapMesh new(this)
	}
	init: func { this init(GLContext createContext()) }
	init: func ~shared (other: This) { this init(GLContext createContext(other _backend)) }
	init: func ~window (nativeWindow: NativeWindow) { this init(GLContext createContext(nativeWindow)) }
	free: override func {
		this _backend makeCurrent()
		this _transformTextureMap free()
		this _packMonochrome free()
		this _packUv free()
		this _linesShader free()
		this _pointsShader free()
		this _meshShader free()
		this _backend free()
		this _renderer free()
		this _recycleBin free()
		super()
	}
	getMaxContexts: func -> Int { 1 }
	getCurrentIndex: func -> Int { 0 }
	drawQuad: func { this _renderer drawQuad() }
	drawLines: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D, pen: Pen) {
		positions := pointList pointer as Float*
		this _linesShader projection = projection
		this _linesShader add("color", pen color normalized)
		this _linesShader use()
		this _renderer drawLines(positions, pointList count, 2, pen width)
	}
	drawPoints: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D, pen: Pen) {
		positions := pointList pointer
		this _pointsShader add("color", pen color normalized)
		this _pointsShader add("pointSize", pen width)
		this _pointsShader projection = projection
		this _pointsShader use()
		this _renderer drawPoints(positions, pointList count, 2)
	}
	recycle: virtual func (image: OpenGLPacked) {
		(image canvas as OpenGLCanvas) onRecycle()
		this _recycleBin add(image)
	}
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
	createImage: virtual override func (rasterImage: RasterImage) -> GpuImage {
		match (rasterImage) {
			case image: RasterMonochrome => this _createMonochrome(image)
			case image: RasterBgr => this _createBgr(image)
			case image: RasterBgra => this _createBgra(image)
			case image: RasterUv => this _createUv(image)
			case image: RasterYuv420Semiplanar => this createYuv420Semiplanar(image)
			case => Debug raise("Unknown input format in OpenGLContext createImage"); null
		}
	}
	update: func { this _backend swapBuffers() }
	packToRgba: func (source: GpuImage, target: GpuImage, viewport: IntBox2D) {
		channels := 1
		map := match (source) {
			case sourceImage: OpenGLMonochrome => this _packMonochrome
			case sourceImage: OpenGLUv => channels = 2; this _packUv
		}
		map add("texture0", source)
		map add("texelOffset", 1.0f / source size width)
		map add("xOffset", (2.0f / channels - 0.5f) / source size width)
		map add("transform", FloatTransform3D createScaling(1.0f, -1.0f, 1.0f))
		target canvas viewport = viewport
		target canvas draw(source, map)
	}
	createFence: func -> GpuFence { OpenGLFence new(this) }
	toRasterAsync: override func (gpuImage: GpuImage) -> (RasterImage, GpuFence) {
		result := this toRaster(gpuImage, true)
		fence := this createFence()
		fence sync()
		(result, fence)
	}
	createMesh: override func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) {
		toGL := FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
		for (i in 0 .. vertices length)
			vertices[i] = toGL * vertices[i]
		OpenGLMesh new(vertices, textureCoordinates, this)
	}
}
}
