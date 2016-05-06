/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw-gpu
use geometry
use draw
use opengl
import DisplayWindow
import X11Window

version((unix || apple) && !android) {
UnixWindowBase: class extends DisplayWindow {
	_xWindow: X11Window
	init: func (size: IntVector2D, title: String) {
		super()
		this _xWindow = X11Window new(size, title)
	}
	free: override func {
		this _xWindow free()
		super()
	}
	draw: override func (image: Image) {
		if (image instanceOf(RasterRgba))
			this _xWindow draw(image as RasterRgba)
		else {
			raster := RasterRgba convertFrom(image as RasterImage)
			this _xWindow draw(raster)
			raster referenceCount decrease()
		}
	}
	create: static func (size: IntVector2D, title: String) -> This {
		result: This
		version(gpuOff)
			result = This new(size, title)
		else
			result = UnixWindow new(size, title)
		result
	}
}
version(!gpuOff) {
UnixWindow: class extends UnixWindowBase {
	_openGLWindow: OpenGLWindow
	context ::= this _openGLWindow context
	init: func (size: IntVector2D, title: String) {
		super(size, title)
		this _openGLWindow = OpenGLWindow new(this _xWindow size, this _xWindow display, this _xWindow backend)
	}
	free: override func {
		this _openGLWindow free()
		super()
	}
	draw: override func (image: Image) {
		map := this _openGLWindow _getDefaultMap(image)
		tempImageA: GpuImage = null
		tempImageB: GpuImage = null
		match (image) {
			case (matchedImage: RasterYuv420Semiplanar) =>
				tempImageA = this _openGLWindow context createImage(matchedImage y)
				tempImageB = this _openGLWindow context createImage(matchedImage uv)
				map add("texture0", tempImageA)
				map add("texture1", tempImageB)
			case (matchedImage: RasterImage) =>
				tempImageA = this _openGLWindow context createImage(matchedImage)
				map add("texture0", tempImageA)
			case (matchedImage: GpuYuv420Semiplanar) =>
				map add("texture0", matchedImage y)
				map add("texture1", matchedImage uv)
			case (matchedImage: GpuImage) =>
				map add("texture0", matchedImage)
		}
		map use(null, FloatTransform3D identity, FloatTransform3D identity)
		this _openGLWindow context backend setViewport(IntBox2D new(image size))
		this _openGLWindow context backend disableBlend()
		this _openGLWindow context drawQuad()
		if (tempImageA)
			tempImageA free()
		if (tempImageB)
			tempImageB free()
	}
	refresh: override func {
		this _openGLWindow refresh()
	}
}
}
}
