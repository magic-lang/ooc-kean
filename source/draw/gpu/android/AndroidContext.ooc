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

use ooc-draw-gpu
use ooc-opengl
use ooc-draw
use ooc-math
import GpuPacker, GpuMapAndroid, GpuPackerBin, EglRgba
AndroidContext: class extends OpenGLES3Context {
	_packMonochrome: OpenGLES3MapPackMonochrome
	_packUv: OpenGLES3MapPackUv
	_packerBin: GpuPackerBin
	init: func {
		super()
		this _packMonochrome = OpenGLES3MapPackMonochrome new()
		this _packUv = OpenGLES3MapPackUv new()
		this _packerBin = GpuPackerBin new()
	}
	toRaster: func (gpuImage: GpuImage) -> RasterImage {
		result := null
		if(gpuImage instanceOf?(GpuYuv420Semiplanar)) {
			raster := RasterYuv420Semiplanar new(gpuImage size)
			semiPlanar := gpuImage as GpuYuv420Semiplanar
			yPacker := createPacker(semiPlanar y size, 1)
			yPacker pack(semiPlanar y, this _packMonochrome, raster y)
			yPacker recycle()
			uvPacker := createPacker(semiPlanar uv size, 2)
			uvPacker pack(semiPlanar uv, this _packUv, raster uv)
			uvPacker recycle()
			result = raster
		}
		result
	}
	recycle: func ~GpuPacker (packer: GpuPacker) {
		this _packerBin add(packer)
	}
	createPacker: func (size: IntSize2D, bytesPerPixel: UInt) -> GpuPacker {
		result := this _packerBin find(size, bytesPerPixel)
		if (result == null) {
			//result = GpuPacker new(size, bytesPerPixel, this)
		}
		result
	}
	createEglRgba: func (size: IntSize2D) -> EglRgba {
		EglRgba new(this _backend _eglDisplay, size)
	}
}

AndroidContextManager: class extends GpuContextManager {
	init: func {
		setShaderSources()
	}
	_createContext: func -> GpuContext {
		AndroidContext new()
	}
	/*
	copyPixels: func ~Monochrome (image: GpuMonochrome, destination: RasterMonochrome) {
		this _scaledPacker pack(image)
		yPixels := this _scaledPacker lock()
		memcpy(destination pointer, yPixels, 768 * 480)
		this _scaledPacker unlock()
	}
	copyPixels: func ~Yuv420Semiplanar(image: GpuYuv420Semiplanar, destination: RasterYuv420Semiplanar) {
		this _yPacker pack(image y)
		yPixels := this _yPacker lock()
		destinationPointer := destination y pointer
		destinationStride := destination y stride
		paddedBytes := 640 + 1920 - image size width;
		for(row in 0..image size height) {
			sourceRow := yPixels + row * (image size width + paddedBytes)
			destinationRow := destinationPointer + row * destinationStride
			memcpy(destinationRow, sourceRow, image size width)
		}
		this _yPacker unlock()

		this _uvPacker pack(image uv)
		uvPixels := this _uvPacker lock()
		uvOffset := destination y stride * destination y size height + (Int align(destination y size height, destination byteAlignment height) - destination y size height) * destination y stride
		uvDestination := destinationPointer + uvOffset
		for(row in 0..image size height / 2) {
			sourceRow := uvPixels + row * (image size width + paddedBytes)
			destinationRow := uvDestination + row * destinationStride
			memcpy(destinationRow, sourceRow, image size width)
		}
		this _uvPacker unlock()
	}
	*/
}
