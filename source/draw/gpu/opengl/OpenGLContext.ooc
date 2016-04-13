/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use draw
use draw-gpu
use collections
use concurrent
import OpenGLPacked, OpenGLMonochrome, OpenGLRgb, OpenGLRgba, OpenGLUv, OpenGLMesh, OpenGLCanvas, OpenGLPromise
import OpenGLMap
import backend/[GLContext, GLRenderer]

version(!gpuOff) {
_FenceToRasterFuture: class extends ToRasterFuture {
	_promise: OpenGLPromise
	init: func (result: RasterImage, =_promise) { super(result) }
	free: override func {
		this _promise free()
		super()
	}
	wait: override func -> Bool { this _promise wait() }
	wait: override func ~timeout (time: TimeSpan) -> Bool { this _promise wait(time) }
}

OpenGLContext: class extends GpuContext {
	_backend: GLContext
	_transformTextureMap: OpenGLMapTransform
	_packMonochrome: OpenGLMap
	_packUv: OpenGLMap
	_packUvPadded: OpenGLMap
	_linesShader: OpenGLMap
	_pointsShader: OpenGLMap
	_meshShader: OpenGLMapMesh
	_renderer: GLRenderer
	_recycleBinMonochrome: RecycleBin<OpenGLMonochrome>
	_recycleBinRgb: RecycleBin<OpenGLRgb>
	_recycleBinRgba: RecycleBin<OpenGLRgba>
	_recycleBinUv: RecycleBin<OpenGLUv>
	backend ::= this _backend
	meshShader ::= this _meshShader
	defaultMap ::= this _transformTextureMap as Map

	init: func ~backend (=_backend) {
		super()
		this _recycleBinMonochrome = RecycleBin<OpenGLMonochrome> new(15, func (image: OpenGLMonochrome) {
			image _recyclable = false
			image free()
		})
		this _recycleBinRgb = RecycleBin<OpenGLRgb> new(15, func (image: OpenGLRgb) {
			image _recyclable = false
			image free()
		})
		this _recycleBinRgba = RecycleBin<OpenGLRgba> new(15, func (image: OpenGLRgba) {
			image _recyclable = false
			image free()
		})
		this _recycleBinUv = RecycleBin<OpenGLUv> new(15, func (image: OpenGLUv) {
			image _recyclable = false
			image free()
		})
		this _packMonochrome = OpenGLMap new(slurp("shaders/packMonochrome.vert"), slurp("shaders/packMonochrome.frag"), this)
		this _packUv = OpenGLMap new(slurp("shaders/packUv.vert"), slurp("shaders/packUv.frag"), this)
		this _packUvPadded = OpenGLMap new(slurp("shaders/packUvPadded.vert"), slurp("shaders/packUvPadded.frag"), this)
		this _linesShader = OpenGLMapTransform new(slurp("shaders/color.frag"), this)
		this _pointsShader = OpenGLMap new(slurp("shaders/points.vert"), slurp("shaders/color.frag"), this)
		this _transformTextureMap = OpenGLMapTransform new(slurp("shaders/texture.frag"), this)
		this _renderer = _backend createRenderer()
		this _meshShader = OpenGLMapMesh new(this)
	}
	init: func ~shared (other: This = null) {
		if (other != null)
			this init(GLContext createContext(other _backend))
		else
			this init(GLContext createContext())
	}
	init: func ~window (display: Pointer, nativeBackend: Long) { this init(GLContext createContext(display, nativeBackend)) }
	free: override func {
		this _backend makeCurrent()
		this _transformTextureMap free()
		this _packMonochrome free()
		this _packUv free()
		this _packUvPadded free()
		this _linesShader free()
		this _pointsShader free()
		this _meshShader free()
		this _backend free()
		this _renderer free()
		this _recycleBinMonochrome free()
		this _recycleBinRgb free()
		this _recycleBinRgba free()
		this _recycleBinUv free()
		super()
	}
	getMaxContexts: func -> Int { 1 }
	getCurrentIndex: func -> Int { 0 }
	drawQuad: func { this _renderer drawQuad() }
	drawLines: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D, pen: Pen) {
		positions := pointList pointer as Float*
		this _linesShader projection = projection
		this _linesShader add("color", pen color normalized)
		this _linesShader use(null)
		this _renderer drawLines(positions, pointList count, 2, pen width)
	}
	drawPoints: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D, pen: Pen) {
		positions := pointList pointer
		this _pointsShader add("color", pen color normalized)
		this _pointsShader add("pointSize", pen width)
		this _pointsShader projection = projection
		this _pointsShader use(null)
		this _renderer drawPoints(positions, pointList count, 2)
	}
	recycle: virtual func (image: OpenGLPacked) {
		image onRecycle()
		match (image) {
			case (i: OpenGLMonochrome) => this _recycleBinMonochrome add(i)
			case (i: OpenGLRgb) => this _recycleBinRgb add(i)
			case (i: OpenGLRgba) => this _recycleBinRgba add(i)
			case (i: OpenGLUv) => this _recycleBinUv add(i)
			case => Debug error("Unknown format in recycle add()")
		}
	}
	_searchImageBin: func (type: GpuImageType, size: IntVector2D) -> GpuImage {
		result := match (type) {
			case GpuImageType Monochrome => this _recycleBinMonochrome search(|image| image size == size)
			case GpuImageType Rgb => this _recycleBinRgb search(|image| image size == size)
			case GpuImageType Rgba => this _recycleBinRgba search(|image| image size == size)
			case GpuImageType Uv => this _recycleBinUv search(|image| image size == size)
			case => null
		}
		result
	}
	createMonochrome: override func (size: IntVector2D) -> GpuImage {
		result := this _searchImageBin(GpuImageType Monochrome, size)
		result == null ? OpenGLMonochrome new(size, this) as GpuImage : result
	}
	_createMonochrome: func (raster: RasterMonochrome) -> GpuImage {
		result := this _searchImageBin(GpuImageType Monochrome, raster size)
		if (result == null)
			result = OpenGLMonochrome new(raster, this)
		else
			result upload(raster)
		result
	}
	createUv: override func (size: IntVector2D) -> GpuImage {
		result := this _searchImageBin(GpuImageType Uv, size)
		result == null ? OpenGLUv new(size, this) as GpuImage : result
	}
	_createUv: func (raster: RasterUv) -> GpuImage {
		result := this _searchImageBin(GpuImageType Uv, raster size)
		if (result == null)
			result = OpenGLUv new(raster, this)
		else
			result upload(raster)
		result
	}
	createRgb: override func (size: IntVector2D) -> GpuImage {
		result := this _searchImageBin(GpuImageType Rgb, size)
		result == null ? OpenGLRgb new(size, this) as GpuImage : result
	}
	_createRgb: func (raster: RasterRgb) -> GpuImage {
		result := this _searchImageBin(GpuImageType Rgb, raster size)
		if (result == null)
			result = OpenGLRgb new(raster, this)
		else
			result upload(raster)
		result
	}
	createRgba: override func (size: IntVector2D) -> GpuImage {
		result := this _searchImageBin(GpuImageType Rgba, size)
		result == null ? OpenGLRgba new(size, this) as GpuImage : result
	}
	_createRgba: func (raster: RasterRgba) -> GpuImage {
		result := this _searchImageBin(GpuImageType Rgba, raster size)
		if (result == null)
			result = OpenGLRgba new(raster, this)
		else
			result upload(raster)
		result
	}
	createImage: virtual override func (rasterImage: RasterImage) -> GpuImage {
		match (rasterImage) {
			case image: RasterMonochrome => this _createMonochrome(image)
			case image: RasterRgb => this _createRgb(image)
			case image: RasterRgba => this _createRgba(image)
			case image: RasterUv => this _createUv(image)
			case image: RasterYuv420Semiplanar => this createYuv420Semiplanar(image)
			case => Debug error("Unknown input format in OpenGLContext createImage"); null
		}
	}
	update: override func { this _backend swapBuffers() }
	packToRgba: func (source: GpuImage, target: GpuImage, viewport: IntBox2D, padding := 0) {
		channels := 1
		map: Map
		if (source instanceOf(OpenGLMonochrome))
			map = this _packMonochrome
		else if (source instanceOf(OpenGLUv)) {
			channels = 2
			if (padding == 0)
				map = this _packUv
			else {
				map = this _packUvPadded
				map add("paddingOffset", padding as Float / (target size x * 4))
			}
		} else
			raise("invalid type of GpuImage in packToRgba")
		map add("texture0", source)
		map add("texelOffset", 1.0f / source size x)
		map add("xOffset", (2.0f / channels - 0.5f) / source size x)
		map add("transform", FloatTransform3D createScaling(1.0f, -1.0f, 1.0f))
		DrawState new(target) setViewport(viewport) setMap(map) draw()
	}
	toRasterAsync: override func (source: GpuImage) -> ToRasterFuture { ToRasterFuture new(this toRaster(source)) }
	createMesh: override func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> Mesh {
		toGL := FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
		for (i in 0 .. vertices length)
			vertices[i] = toGL * vertices[i]
		OpenGLMesh new(vertices, textureCoordinates, this)
	}
}
}
