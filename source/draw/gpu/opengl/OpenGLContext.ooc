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
import OpenGLPacked, OpenGLMonochrome, OpenGLRgb, OpenGLRgba, OpenGLUv, OpenGLMesh, OpenGLPromise, GraphicBufferYuv420Semiplanar, GraphicBuffer
import OpenGLMap
import backend/[GLContext, GLRenderer, GLExtensions]

version(!gpuOff) {
_FenceToRasterFuture: class extends ToRasterFuture {
	_promise: OpenGLPromise
	init: func (result: RasterImage, =_promise) { super(result) }
	free: override func {
		this _promise free()
		super()
	}
	wait: override func (time: TimeSpan) -> Bool { this _promise wait(time) }
}

OpenGLContext: class extends GpuContext {
	_backend: GLContext
	_transformTextureMap: OpenGLMapTransform
	_packMonochrome: OpenGLMap
	_packUv: OpenGLMap
	_packUvPadded: OpenGLMap
	_linesShader: OpenGLMap
	_pointsShader: OpenGLMap
	_monochromeToRgba: OpenGLMapTransform
	_yuvSemiplanarToRgba: OpenGLMapTransform
	_rgbaToYuva: OpenGLMapTransform
	_rgbaToUvaa: OpenGLMapTransform
	_renderer: GLRenderer
	_recycleBin := RecycleBin<OpenGLPacked> new(60, |image| image _recyclable = false; image free())
	backend ::= this _backend
	defaultMap ::= this _transformTextureMap as Map
	_defaultFontGpu: GpuImage = null
	defaultFontGpu: GpuImage { get {
		if (this _defaultFontGpu == null)
			this _defaultFontGpu = this createImage(this defaultFontRaster)
		this _defaultFontGpu
	}}
	init: func ~backend (=_backend) {
		super()
		if (this _backend == null)
			Debug error("Failed to create OpenGLContext backend!")
		this _packMonochrome = OpenGLMap new(slurp("shaders/packMonochrome.vert"), slurp("shaders/packMonochrome.frag"), this)
		this _packUv = OpenGLMap new(slurp("shaders/packUv.vert"), slurp("shaders/packUv.frag"), this)
		this _packUvPadded = OpenGLMap new(slurp("shaders/packUvPadded.vert"), slurp("shaders/packUvPadded.frag"), this)
		this _linesShader = OpenGLMapTransform new(slurp("shaders/color.frag"), this)
		this _pointsShader = OpenGLMap new(slurp("shaders/points.vert"), slurp("shaders/color.frag"), this)
		this _transformTextureMap = OpenGLMapTransform new(slurp("shaders/texture.frag"), this)
		this _monochromeToRgba = OpenGLMapTransform new(slurp("shaders/monochromeToRgba.frag"), this)
		this _yuvSemiplanarToRgba = OpenGLMapTransform new(slurp("shaders/yuvSemiplanarToRgba.frag"), this)
		this _rgbaToYuva = OpenGLMapTransform new(slurp("shaders/rgbaToYuva.frag"), this)
		this _rgbaToUvaa = OpenGLMapTransform new(slurp("shaders/rgbaToUvaa.frag"), this)
		this _renderer = this _backend createRenderer()
	}
	init: func ~shared (other: This = null) {
		if (other != null)
			this init(GLContext createContext(other _backend))
		else
			this init(GLContext createContext())
	}
	init: func ~window (display: Pointer, nativeBackend: Long) { this init(GLContext createContext(display, nativeBackend)) }
	free: override func {
		if (this _defaultFontGpu != null)
			this _defaultFontGpu free()
		(this _transformTextureMap, this _packMonochrome, this _packUv, this _packUvPadded, this _linesShader) free()
		(this _monochromeToRgba, this _yuvSemiplanarToRgba, this _rgbaToYuva, this _rgbaToUvaa) free()
		(this _pointsShader, this _renderer, this _recycleBin, this _backend) free()
		super()
	}
	getDefaultShader: virtual func (input, output: Image) -> OpenGLMap { this _transformTextureMap }
	getLineShader: virtual func -> OpenGLMap { this _linesShader }
	drawQuad: func { this _renderer drawQuad() }
	drawLines: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D, pen: Pen) {
		positions := pointList pointer as Float*
		shader := this getLineShader()
		shader add("color", pen color normalized)
		shader useProgram(null, projection, FloatTransform3D identity)
		this _renderer drawLines(positions, pointList count, 2, pen width)
	}
	drawPoints: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D, pen: Pen) {
		positions := pointList pointer
		this _pointsShader add("color", pen color normalized)
		this _pointsShader add("pointSize", pen width)
		this _pointsShader useProgram(null, projection, FloatTransform3D identity)
		this _renderer drawPoints(positions, pointList count, 2)
	}
	recycle: virtual func (image: OpenGLPacked) {
		image onRecycle()
		this _recycleBin add(image)
	}
	_searchImageBin: func (type: Class, size: IntVector2D) -> GpuImage {
		this _recycleBin search(|image| image instanceOf(type) && image size == size)
	}
	createFence: override func -> Promise {
		result: OpenGLPromise
		if (GLExtensions nativeFenceSupported)
			result = OpenGLNativeFencePromise new(this)
		else
			result = OpenGLPromise new(this)
		result sync()
		result
	}
	createMonochrome: override func (size: IntVector2D) -> GpuImage {
		result := this _searchImageBin(OpenGLMonochrome, size)
		result == null ? OpenGLMonochrome new(size, this) as GpuImage : result
	}
	_createMonochrome: func (raster: RasterMonochrome) -> GpuImage {
		result := this _searchImageBin(OpenGLMonochrome, raster size)
		if (result == null)
			result = OpenGLMonochrome new(raster, this)
		else
			result upload(raster)
		result
	}
	createUv: override func (size: IntVector2D) -> GpuImage {
		result := this _searchImageBin(OpenGLUv, size)
		result == null ? OpenGLUv new(size, this) as GpuImage : result
	}
	_createUv: func (raster: RasterUv) -> GpuImage {
		result := this _searchImageBin(OpenGLUv, raster size)
		if (result == null)
			result = OpenGLUv new(raster, this)
		else
			result upload(raster)
		result
	}
	createRgb: override func (size: IntVector2D) -> GpuImage {
		result := this _searchImageBin(OpenGLRgb, size)
		result == null ? OpenGLRgb new(size, this) as GpuImage : result
	}
	_createRgb: func (raster: RasterRgb) -> GpuImage {
		result := this _searchImageBin(OpenGLRgb, raster size)
		if (result == null)
			result = OpenGLRgb new(raster, this)
		else
			result upload(raster)
		result
	}
	createRgba: override func (size: IntVector2D) -> GpuImage {
		result := this _searchImageBin(OpenGLRgba, size)
		result == null ? OpenGLRgba new(size, this) as GpuImage : result
	}
	_createRgba: func (raster: RasterRgba) -> GpuImage {
		result := this _searchImageBin(OpenGLRgba, raster size)
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
			Debug error("invalid type of GpuImage in packToRgba")
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
	createGrid: override func (size: IntVector2D, vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> Mesh {
		toGL := FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
		for (i in 0 .. vertices length)
			vertices[i] = toGL * vertices[i]
		triangles := IntPoint3D[2 * size area] new()
		gridSize := size
		nodeSize := gridSize + IntVector2D new(1, 1)
		for (y in 0 .. size y) {
			for (x in 0 .. size x) {
				base := y * nodeSize x + x
				evenTriangle := IntPoint3D new(base, base + 1, base + nodeSize x)
				oddTriangle := IntPoint3D new(base + 1, base + 1 + nodeSize x, base + nodeSize x)
				index := 2 * (y * size x + x)
				triangles[index] = evenTriangle
				triangles[index + 1] = oddTriangle
			}
		}
		result := OpenGLMesh new(vertices, textureCoordinates, triangles, this)
		triangles free()
		result
	}
	getDefaultFont: override func -> Image { this defaultFontGpu }
	getYuvToRgba: override func -> Map { this _yuvSemiplanarToRgba }
	getRgbaToY: override func -> Map { this _rgbaToYuva }
	getRgbaToUv: override func -> Map { this _rgbaToUvaa }
	toRaster: override func ~target (source: GpuImage, target: RasterImage) -> Promise {
		if (target instanceOf(GraphicBufferYuv420Semiplanar))
			target as GraphicBufferYuv420Semiplanar buffer lock(GraphicBufferUsage WriteOften)
		result := super(source, target)
		if (target instanceOf(GraphicBufferYuv420Semiplanar))
			target as GraphicBufferYuv420Semiplanar buffer unlock()
		result
	}
}
}
