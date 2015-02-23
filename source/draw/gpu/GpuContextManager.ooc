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
use ooc-draw
use ooc-math
import GpuContext, GpuMonochrome, GpuBgra, GpuBgr, GpuUv, GpuYuv420Semiplanar, GpuYuv422Semipacked, GpuYuv420Planar, GpuImage, GpuSurface, GpuMap, Viewport

pthread_self: extern func -> Long

GpuContextManager: abstract class extends GpuContext {
	MAX_CONTEXTS: UInt
	_contexts: GpuContext[]
	_threadIdentifiers: Int[]
	init: func (=MAX_CONTEXTS) {
		this _threadIdentifiers = Int[this MAX_CONTEXTS] new()
		this _contexts = GpuContext[this MAX_CONTEXTS] new()
	}
	getMaxContexts: func -> Int { this MAX_CONTEXTS }
	_getContext: func -> GpuContext {
		threadIdentifier := pthread_self()
		for (i in 0..MAX_CONTEXTS) {
			if (threadIdentifier == this _threadIdentifiers[i])
				return this _contexts[i]
		}
		for (i in 0..MAX_CONTEXTS) {
			if (this _threadIdentifiers[i] == 0) {
				this _threadIdentifiers[i] = threadIdentifier
				this _contexts[i] = this _createContext()
				return this _contexts[i]
			}
		}
		DebugPrint print("ERROR: Maximum gpu contexts already used!")
		raise("Maximum contexts already used!")
		return null
	}
	getCurrentIndex: func -> Int {
		threadIdentifier := pthread_self()
		result := -1
		for (i in 0..MAX_CONTEXTS) {
			if (threadIdentifier == this _threadIdentifiers[i])
				result = i
		}
		result
	}
	_createContext: abstract func -> GpuContext
	free: func {
		for(i in 0..MAX_CONTEXTS) {
			if (this _contexts[i] != null)
				this _contexts[i] free()
		}
		super()
	}
	clean: func {
		for(i in 0..MAX_CONTEXTS) {
			if (this _contexts[i] != null)
				this _contexts[i] clean()
		}
	}
	createYuv422Semipacked: func (size: IntSize2D) -> GpuYuv422Semipacked { this _getContext() createYuv422Semipacked(size) }
	createMonochrome: func (size: IntSize2D) -> GpuMonochrome { this _getContext() createMonochrome(size) }
	createBgr: func (size: IntSize2D) -> GpuBgr { this _getContext() createBgr(size) }
	createBgra: func (size: IntSize2D) -> GpuBgra { this _getContext() createBgra(size) }
	createUv: func (size: IntSize2D) -> GpuUv { this _getContext() createUv(size) }
	createYuv420Semiplanar: func (size: IntSize2D) -> GpuYuv420Semiplanar { this _getContext() createYuv420Semiplanar(size) }
	createYuv420Semiplanar: func ~fromImages (y: GpuMonochrome, uv: GpuUv) -> GpuYuv420Semiplanar { this _getContext() createYuv420Semiplanar(y, uv) }
	createYuv420Planar: func (size: IntSize2D) -> GpuYuv420Planar { this _getContext() createYuv420Planar(size) }
	createGpuImage: func (rasterImage: RasterImage) -> GpuImage { this _getContext() createGpuImage(rasterImage) }
	update: func { this _getContext() update() }
	recycle: func ~image (gpuImage: GpuImage) { this _getContext() recycle(gpuImage) }
	recycle: func ~surface (surface: GpuSurface) { this _getContext() recycle(surface) }
	createSurface: func -> GpuSurface { this _getContext() createSurface() }
	toRaster: func (gpuImage: GpuImage) -> RasterImage { this _getContext() toRaster(gpuImage) }
	toRaster: func ~overwrite (gpuImage: GpuImage, rasterImage: RasterImage) { this _getContext() toRaster(gpuImage, rasterImage) }
	setViewport: func (viewport: Viewport) { this _getContext() setViewport(viewport) }
	getMap: func (gpuImage: GpuImage, mapType := GpuMapType defaultmap) -> GpuMap { this _getContext() getMap(gpuImage, mapType) }
}
