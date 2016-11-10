/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use math
use geometry
use draw
import RasterPacked
import RasterImage
import StbImage
import Image, FloatImage
import Color
import Pen

RasterMonochrome: class extends RasterPacked {
	bytesPerPixel ::= 1
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	_drawPoint: override func (x, y: Int, pen: Pen) {
		position := this _map(IntPoint2D new(x, y))
		if (this isValidIn(position x, position y))
			this[position x, position y] = ColorMonochrome mix(this[position x, position y], pen color toMonochrome(), pen alphaAsFloat)
	}
	_draw: override func (image: Image, source, destination: IntBox2D, normalizedTransform: FloatTransform3D, interpolate, flipX, flipY: Bool) {
		monochrome: This = null
		if (image == null)
			Debug error("Null image in RasterMonochrome draw")
		else if (image instanceOf(This))
			monochrome = image as This
		else if (image instanceOf(RasterImage))
			monochrome = This convertFrom(image as RasterImage)
		else
			Debug error("Unsupported image type in RasterMonochrome draw")
		this _resizePacked(monochrome buffer pointer as ColorMonochrome*, monochrome, source, destination, normalizedTransform, interpolate, flipX, flipY, ColorMonochrome new())
		if (monochrome != image)
			monochrome referenceCount decrease()
	}
	fill: override func (color: ColorRgba) { this buffer memset(color r) }
	copy: override func -> This { This new(this buffer copy(), this size, this stride) }
	apply: override func ~rgb (action: Func(ColorRgb)) {
		convert := ColorConvert fromMonochrome(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~yuv (action: Func(ColorYuv)) {
		convert := ColorConvert fromMonochrome(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~monochrome (action: Func(ColorMonochrome)) {
		pointer := this buffer pointer as ColorMonochrome*
		sizeX := this size x
		sizeY := this size y
		thisStride := this stride
		for (row in 0 .. sizeY)
			for (column in 0 .. sizeX) {
				pixel := pointer + row * thisStride + column
				action(pixel@)
			}
	}
	resizeTo: override func (size: IntVector2D) -> This { this resizeTo(size, true) as This }
	resizeTo: override func ~withMethod (size: IntVector2D, interpolate: Bool) -> This {
		result := This new(size)
		DrawState new(result) setInputImage(this) setInterpolate(interpolate) draw()
		result
	}
	distance: override func (other: Image) -> Float {
		result := 0.0f
		if (!other || (this size != other size))
			result = Float maximumValue
		else if (!other instanceOf(This)) {
			converted := This convertFrom(other as RasterImage)
			result = this distance(converted)
			converted referenceCount decrease()
		} else {
			sizeX := this size x
			sizeY := this size y
			thisStride := this stride
			otherStride := (other as This) stride
			thisBuffer := this buffer _pointer as ColorMonochrome*
			otherBuffer := (other as This) buffer _pointer as ColorMonochrome*
			for (y in 0 .. sizeY)
				for (x in 0 .. sizeX) {
					c := thisBuffer[x + y * thisStride]
					o := otherBuffer[x + y * otherStride]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in 0 maximum(y - 2) .. (y + 3) minimum(sizeY))
							for (otherX in 0 maximum(x - 2) .. (x + 3) minimum(sizeX))
								if (otherX != x || otherY != y) {
									pixel := otherBuffer[otherX + otherY * otherStride]
									if (maximum y < pixel y)
										maximum y = pixel y
									else if (minimum y > pixel y)
										minimum y = pixel y
								}
						distance := 0.0f
						if (c y < minimum y)
							distance += (minimum y - c y) as Float squared
						else if (c y > maximum y)
							distance += (c y - maximum y) as Float squared
						result += distance sqrt()
					}
				}
			result /= this size norm
		}
		result
	}
	getFirstDerivative: func (x, y: Int) -> (Float, Float) {
		step := 2
		sourceStride := this stride
		source := this buffer pointer + y * sourceStride
		derivativeX := (8 * source[x + step] - 8 * source[x - step] + source[x - 2 * step] - source[x + 2 * step]) as Float / (12.0f * step)
		derivativeY := (8 * source[x + sourceStride * step] - 8 * source[x - sourceStride * step] + source[x - sourceStride * 2 * step] - source[x + sourceStride * 2 * step]) as Float / (12.0f * step)
		(derivativeX, derivativeY)
	}
	// get the derivative on small window, region is window's global location on image, window is left top centered.
	getFirstDerivative: func ~window (region: IntBox2D, imageX, imageY: FloatImage) {
		step := 2
		sourceStride := this stride
		source := this buffer pointer + region leftTop y * sourceStride // this getValue [x,y]
		destinationX := imageX pointer
		destinationY := imageY pointer

		// Ix & Iy  centered difference approximation with 4th error order, centered window
		for (y in (region leftTop y) .. (region rightBottom y)) {
			for (x in (region leftTop x) .. (region rightBottom x)) {
				destinationX@ = (
					8 * source[x + step] -
					8 * source[x - step] +
					source[x - 2 * step] -
					source[x + 2 * step]
				) as Float / (12.0f * step)
				destinationX += 1

				destinationY@ = (
					8 * source[x + sourceStride * step] -
					8 * source[x - sourceStride * step] +
					source[x - sourceStride * 2 * step] -
					source[x + sourceStride * 2 * step]
				) as Float / (12.0f * step)
				destinationY += 1
			}
			source += sourceStride
		}
	}

	getValue: func (x, y: Int) -> Byte {
		version(safe)
			Debug error(x >= this size x || y >= this size y || x < 0 || y < 0, "Accessing RasterMonochrome index out of range in getValue")
		(this buffer pointer[y * this stride + x])
	}

	getRow: func (row: Int) -> FloatVectorList {
		result := FloatVectorList new(this size x)
		this getRowInto(row, result)
		result
	}
	getRowInto: func (row: Int, vector: FloatVectorList) {
		version(safe)
			Debug error(row >= this size y || row < 0, "Accessing RasterMonochrome index out of range in getRow")
		for (column in 0 .. this size x)
			vector add(this buffer pointer[row * this stride + column] as Float)
	}
	getColumn: func (column: Int) -> FloatVectorList {
		result := FloatVectorList new(this size y)
		this getColumnInto(column, result)
		result
	}
	getColumnInto: func (column: Int, vector: FloatVectorList) {
		version(safe)
			Debug error(column >= this size x || column < 0, "Accessing RasterMonochrome index out of range in getColumn")
		for (row in 0 .. this size y)
			vector add(this buffer pointer[row * this stride + column] as Float)
	}
	operator [] (x, y: Int) -> ColorMonochrome {
		version(safe)
			Debug error(!this isValidIn(x, y), "Accessing RasterMonochrome index out of range in get operator")
		ColorMonochrome new(this buffer pointer[y * this stride + x])
	}
	operator []= (x, y: Int, value: ColorMonochrome) {
		version(safe)
			Debug error(x >= this size x || y >= this size y || x < 0 || y < 0, "Accessing RasterMonochrome index out of range in set operator")
		((this buffer pointer + y * this stride) as ColorMonochrome* + x)@ = value
	}

	open: static func (filename: String) -> This {
		requiredComponents := 1
		(buffer, size, _) := StbImage load(filename, requiredComponents)
		This new(buffer, size)
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original size)
			row := result buffer pointer as PtrDiff
			rowLength := result stride
			rowEnd := row + rowLength
			destination := row as ColorMonochrome*
			f := func (color: ColorMonochrome) {
				destination@ = color
				destination += 1
				if (destination >= rowEnd) {
					row += result stride as PtrDiff
					destination = row as ColorMonochrome*
					rowEnd = row + rowLength
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
	// Serialize to a lossy ascii image using an alphabet
	// Precondition: alphabet may not have extended ascii, non printable, '\', '"', '>' or linebreak
	// Example alphabet: " .,-_':;!+~=^?*abcdefghijklmnopqrstuvwxyz()[]{}|&%@#0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	toAscii: func (alphabet: String) -> String {
		result := CharBuffer new(((this size x + 3) * this size y) + 1)
		// Generate mapping from luma to character
		alphabetMap: Char[256]
		scale := ((alphabet size - 1) as Float) / 255.0f
		output := 0.49f
		for (rawValue in 0 .. 256) {
			alphabetMap[rawValue] = alphabet[(output as Int) clamp(0, alphabet size - 1)]
			output += scale
		}

		result append('<') . append(alphabet) . append('>') . append('\n')
		for (y in 0 .. this size y) {
			result append('<')
			for (x in 0 .. this size x)
				result append(alphabetMap[this[x, y] y])
			result append('>')
			result append('\n')
		}
		result append('\0')
		String new(result)
	}
	// Parse an ascii image
	fromAscii: static func (content: String) -> This {
		// Measure dimensions and read the alphabet
		alphabet: Char[128]
		alphabetSize := 0
		(x, y, width, height) := (0, -1, 0, 0)
		quoted := false
		current: Char
		i := 0
		while (i < content size && ((current = content[i]) != '\0')) {
			if (quoted) {
				if (y < 0) {
					if (current == '>') {
						quoted = false
						y = 0
					} else if (alphabetSize < 128) {
						alphabet[alphabetSize] = current
						alphabetSize += 1
					}
				} else {
					if (current == '>') {
						quoted = false
						width = width maximum(x)
						y += 1
						x = 0
					} else
						x += 1
				}
			} else if (current == '<')
				quoted = true
			i += 1
		}
		Debug error(alphabetSize < 2, "The alphabet needs at least two characters!")
		height = y
		Debug error(x > 0, "All hexadecimal images must end with a linebreak!")
		// Create alphabet mapping from character to luma
		alphabetMap: Byte[128]
		for (i in 0 .. 128)
			alphabetMap[i] = 0
		for (i in 0 .. alphabetSize) {
			code := alphabet[i] as Int
			if (code < 32 || code > 126)
				Debug error("Character '" + alphabet[i] + "' (" + code toString() + ") is not printable standard ascii!")
			if (alphabetMap[code] > 0)
				Debug error("Character '" + alphabet[i] + "' (" + code toString() + ") is used more than once!")
			value := ((i as Float) * (255.0f / ((alphabetSize - 1) as Float))) as Int clamp(0, 255)
			alphabetMap[code] = value
		}

		Debug error(width <= 0 || height <= 0, "An ascii image had zero dimensions!")
		result := This new(IntVector2D new(width, height))
		(x, y) = (0, -1)
		quoted = false
		i = 0
		while (i < content size && ((current = content[i]) != '\0')) {
			if (quoted) {
				if (current == '>') {
					quoted = false
					Debug error(y >= 0 && x != width, "Lines in the ascii image do not have the same length.")
					y += 1
					x = 0
				} else if (y >= 0) {
					result[x, y] = ColorMonochrome new(alphabetMap[(current as Int) clamp(0, 127)])
					x += 1
				}
			} else if (current == '<')
				quoted = true
			i += 1
		}
		result
	}
}
