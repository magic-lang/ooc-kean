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
use ooc-opengl
use ooc-collections
import GpuImageBin, OpenGLES3Monochrome, OpenGLES3Bgr, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, OpenGLES3Yuv422Semipacked, OpenGLES3Fence
import Map/OpenGLES3Map, Map/OpenGLES3MapPack
import OpenGLES3/Context, OpenGLES3/NativeWindow, OpenGLES3/Lines

OpenGLES3Context: class extends GpuContext {
	_backend: Context
	_defaultMap: OpenGLES3MapDefaultTexture
	_transformTextureMap: OpenGLES3MapTransformTexture
	_packMonochrome: OpenGLES3MapPackMonochrome
	_packUv: OpenGLES3MapPackUv
	_linesShader: OpenGLES3MapLines
	_pointsShader: OpenGLES3MapPoints

	_quad: Quad

	init: func (context: Context) {
		super()
		this _packMonochrome = OpenGLES3MapPackMonochrome new(this)
		this _packUv = OpenGLES3MapPackUv new(this)
		this _linesShader = OpenGLES3MapLines new(this)
		this _pointsShader = OpenGLES3MapPoints new(this)
		this _backend = context
		this _quad = Quad create()
		this _defaultMap = OpenGLES3MapDefaultTexture new(this)
		this _transformTextureMap = OpenGLES3MapTransformTexture new(this)
	}
	init: func ~unshared { this init(Context create()) }
	init: func ~shared (other: This) { this init(Context create(other _backend)) }
	init: func ~window (nativeWindow: NativeWindow) { this init(Context create(nativeWindow)) }
	free: override func {
		this _backend makeCurrent()
		this _defaultMap free()
		this _transformTextureMap free()
		this _packMonochrome free()
		this _packUv free()
		this _linesShader free()
		this _pointsShader free()
		this _backend free()
		this _quad free()
		super()
	}
	recycle: func ~image (gpuImage: GpuImage) { this _imageBin add(gpuImage) }
	drawQuad: func { this _quad draw() }
	drawLines: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D) {
		positions := pointList pointer as Float*
		this _linesShader color = FloatPoint3D new(0.0f, 0.0f, 0.0f)
		this _linesShader projection = projection
		this _linesShader use()
		Lines draw(positions, pointList count, 2, 3.5f)
		this _linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this _linesShader use()
		Lines draw(positions, pointList count, 2, 1.5f)
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
		Lines draw(positions[0]&, 5, 2, 1.5f)
	}
	drawPoints: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D) {
		positions := pointList pointer
		this _pointsShader use()
		this _pointsShader projection = projection
		Points draw(positions, pointList count, 2)
	}
	getMap: func (gpuImage: GpuImage, mapType := GpuMapType defaultmap) -> GpuMap {
		result := match (mapType) {
			case GpuMapType defaultmap => this _defaultMap
			case GpuMapType transform => this _transformTextureMap
			case GpuMapType pack =>
				match (gpuImage) {
					case (image : GpuMonochrome) => this _packMonochrome
					case (image : GpuUv) => this _packUv
					case => null
				}
			case => Debug raise("Could not find Map implementation of specified type"); null
		}
		result
	}
	searchImageBin: func (type: GpuImageType, size: IntSize2D) -> GpuImage { this _imageBin find(type, size) }
	createMonochrome: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType monochrome, size)
		if (result == null)
			result = OpenGLES3Monochrome new(size, this)
		result
	}
	_createMonochrome: func (raster: RasterMonochrome) -> GpuImage {
		result := this searchImageBin(GpuImageType monochrome, raster size)
		if (result == null)
			result = OpenGLES3Monochrome new(raster, this)
		else
			result upload(raster)
		result
	}
	createUv: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType uv, size)
		if (result == null)
			result = OpenGLES3Uv new(size, this)
		result
	}
	_createUv: func (raster: RasterUv) -> GpuImage {
		result := this searchImageBin(GpuImageType uv, raster size)
		if (result == null)
			result = OpenGLES3Uv new(raster, this)
		else
			result upload(raster)
		result
	}
	createBgr: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType bgr, size)
		if (result == null)
			result = OpenGLES3Bgr new(size, this)
		result
	}
	_createBgr: func (raster: RasterBgr) -> GpuImage {
		result := this searchImageBin(GpuImageType bgr, raster size)
		if (result == null)
			result = OpenGLES3Bgr new(raster, this)
		else
			result upload(raster)
		result
	}
	createBgra: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType bgra, size)
		if (result == null)
			result = OpenGLES3Bgra new(size, this)
		result
	}
	_createBgra: func (raster: RasterBgra) -> GpuImage {
		result := this searchImageBin(GpuImageType bgra, raster size)
		if (result == null)
			result = OpenGLES3Bgra new(raster, this)
		else
			result upload(raster)
		result
	}
	createYuv420Semiplanar: func (size: IntSize2D) -> GpuImage { OpenGLES3Yuv420Semiplanar new(size, this) }
	createYuv420Semiplanar: func ~fromImages (y: GpuMonochrome, uv: GpuUv) -> GpuYuv420Semiplanar {
		OpenGLES3Yuv420Semiplanar new(y as OpenGLES3Monochrome, uv as OpenGLES3Uv, this)
	}
	_createYuv420Semiplanar: func (raster: RasterYuv420Semiplanar) -> GpuImage { OpenGLES3Yuv420Semiplanar new(raster, this) }
	createYuv420Planar: func (size: IntSize2D) -> GpuImage { OpenGLES3Yuv420Planar new(size, this) }
	_createYuv420Planar: func (raster: RasterYuv420Planar) -> GpuImage { OpenGLES3Yuv420Planar new(raster, this) }
	createYuv422Semipacked: func (size: IntSize2D) -> GpuImage {
		result := this searchImageBin(GpuImageType yuv422, size)
		if (result == null)
			result = OpenGLES3Yuv422Semipacked new(size, this)
		result
	}
	_createYuv422Semipacked: func (raster: RasterYuv422Semipacked) -> GpuImage {
		result := this searchImageBin(GpuImageType yuv422, raster size)
		if (result == null)
			result = OpenGLES3Yuv422Semipacked new(raster, this)
		else
			result upload(raster)
		result
	}
	createGpuImage: func (rasterImage: RasterImage) -> GpuImage {
		match (rasterImage) {
			case image: RasterMonochrome => this _createMonochrome(image)
			case image: RasterBgr => this _createBgr(image)
			case image: RasterBgra => this _createBgra(image)
			case image: RasterUv => this _createUv(image)
			case image: RasterYuv420Semiplanar => this _createYuv420Semiplanar(image)
			case image: RasterYuv420Planar => this _createYuv420Planar(image)
			case image: RasterYuv422Semipacked => this _createYuv422Semipacked(image)
			case => Debug raise("Unknown input format in OpenGLES3Context createGpuImage"); null
		}
	}
	update: func { this _backend swapBuffers() }
	setViewport: func (viewport: IntBox2D) { Fbo setViewport(viewport) }
	enableBlend: func (blend: Bool) { Fbo enableBlend(blend) }
	packToRgba: func (source: GpuImage, target: GpuBgra, viewport: IntBox2D) {
		map := match(source) {
			case sourceImage: GpuMonochrome => this _packMonochrome
			case sourceImage: GpuUv => this _packUv
		} as OpenGLES3MapPack
		map imageWidth = source size width
		map channels = source channels
		map transform = FloatTransform3D createScaling(source transform a, source transform e, 1.0f)
		target canvas map = map
		target canvas viewport = viewport
		target canvas draw(source)
	}
	createFence: func -> GpuFence { OpenGLES3Fence new() }
	toRasterAsync: override func (gpuImage: GpuImage) -> (RasterImage, GpuFence) {
		result := this toRaster(gpuImage, true)
		fence := this createFence()
		fence sync()
		(result, fence)
	}
}
