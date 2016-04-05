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
import RasterPacked
import RasterImage
import StbImage
import Image, FloatImage
import Color
import Pen
import Canvas, RasterCanvas

RasterMonochromeCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterMonochrome
	init: func (image: RasterMonochrome) { super(image) }
	_drawPoint: override func (x, y: Int, pen: Pen) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(pen alphaAsFloat, pen color toMonochrome())
	}
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) {
		monochrome: RasterMonochrome = null
		if (image instanceOf(RasterMonochrome))
			monochrome = image as RasterMonochrome
		else if (image instanceOf(RasterImage))
			monochrome = RasterMonochrome convertFrom(image as RasterImage)
		else
			Debug error("Unsupported image type in RasterMonochromeCanvas draw")
		this _resizePacked(monochrome buffer pointer as ColorMonochrome*, monochrome, source, destination)
		if (monochrome != image)
			monochrome referenceCount decrease()
	}
}

RasterMonochrome: class extends RasterPacked {
	bytesPerPixel ::= 1
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt, coordinateSystem := CoordinateSystem Default) { super(buffer, size, stride, coordinateSystem) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D, coordinateSystem := CoordinateSystem Default) { this init(buffer, size, this bytesPerPixel * size x, coordinateSystem) }
	init: func ~fromRasterMonochrome (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	copy: override func -> This { This new(this) }
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
		for (row in 0 .. this size y)
			for (column in 0 .. this size x) {
				pixel := pointer + row * this stride + column
				action(pixel@)
			}
	}
	resizeTo: override func (size: IntVector2D) -> This {
		this resizeTo(size, InterpolationMode Smooth) as This
	}
	resizeTo: override func ~withMethod (size: IntVector2D, method: InterpolationMode) -> This {
		result := This new(size)
		result canvas interpolationMode = method
		result canvas draw(this, IntBox2D new(this size), IntBox2D new(size))
		//TODO will be fixed by subcanvas
		result canvas interpolationMode = InterpolationMode Fast
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
			for (y in 0 .. this size y)
				for (x in 0 .. this size x) {
					c := this[x, y]
					o := (other as This)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in 0 maximum(y - 2) .. (y + 3) minimum(this size y))
							for (otherX in 0 maximum(x - 2) .. (x + 3) minimum(this size x))
								if (otherX != x || otherY != y) {
									pixel := (other as This)[otherX, otherY]
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
			result /= (this size x squared + this size y squared as Float sqrt())
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
			raise(x >= this size x || y >= this size y || x < 0 || y < 0, "Accessing RasterMonochrome index out of range in getValue")
		(this buffer pointer[y * this stride + x])
	}

	getRow: func (row: Int) -> FloatVectorList {
		result := FloatVectorList new(this size x)
		this getRowInto(row, result)
		result
	}
	getRowInto: func (row: Int, vector: FloatVectorList) {
		version(safe)
			raise(row >= this size y || row < 0, "Accessing RasterMonochrome index out of range in getRow")
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
			raise(column >= this size x || column < 0, "Accessing RasterMonochrome index out of range in getColumn")
		for (row in 0 .. this size y)
			vector add(this buffer pointer[row * this stride + column] as Float)
	}
	_createCanvas: override func -> Canvas { RasterMonochromeCanvas new(this) }

	operator [] (x, y: Int) -> ColorMonochrome {
		version(safe)
			raise(!this isValidIn(x, y), "Accessing RasterMonochrome index out of range in get operator")
		ColorMonochrome new(this buffer pointer[y * this stride + x])
	}
	operator []= (x, y: Int, value: ColorMonochrome) {
		version(safe)
			raise(x >= this size x || y >= this size y || x < 0 || y < 0, "Accessing RasterMonochrome index out of range in set operator")
		((this buffer pointer + y * this stride) as ColorMonochrome* + x)@ = value
	}

	open: static func (filename: String, coordinateSystem := CoordinateSystem Default) -> This {
		requiredComponents := 1
		(buffer, size, _) := StbImage load(filename, requiredComponents)
		This new(buffer, size, coordinateSystem)
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original)
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
	// TODO: Move to new module?
	// Precondition: 0 <= value < 16
	// 0..15 -> 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
	toHexaDigit: static func (value: Byte) -> Char {
		if (value >= 0 && value < 10)
			'0' + value
		else if (value >= 10 && value < 16)
			'A' + value - 10
		else
			'?'
	}
	// Syntax: hexa <- 0..9 | A..F
	fromHexaDigit: static func (c: Char) -> Int {
		if (c >= '0' && c <= '9')
			(c - '0') as Int
		else if (c >= 'A' && c <= 'F')
			(c - 'A' + 10) as Int
		else if (c >= 'a' && c <= 'f')
			(c - 'a' + 10) as Int
		else
			0
	}
	isHexadecimal: static func (c: Char) -> Bool {
		(c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f')
	}
	// Serialize the image into lossless hexadecimals
	toHexadecimals: func -> String {
		result := CharBuffer new((((this size x * 2) + 1) * this size y) + 1)
		for (y in 0 .. this size y) {
			for (x in 0 .. this size x) {
				value := this[x, y] y
				small := value % 16
				big := value / 16
				result append(This toHexaDigit(big))
				result append(This toHexaDigit(small))
			}
			result append('\n')
		}
		result append('\0')
		String new(result)
	}
	// Create an image from hexadecimals
	// Syntax: doubleHexaImage <- ((hexa hexa)+ lineBreak)+
	fromHexadecimals: static func (content: String) -> This {
		currentValue := 0
		decimalCount := 0
		x := 0
		y := 0
		width := 0
		height := 0
		// Measure dimensions
		for (i in 0 .. (content size)) {
			c := content[i]
			if (c == '\0')
				break
			else if (This isHexadecimal(c))
				x += 1
			else if (c == '\n') {
				raise(x % 2 > 0, "A corrupted 8-bit hexadecimal image had an odd number of hexadecimals per line!")
				width = width maximum(x / 2)
				if (x > 0)
					height += 1
				x = 0
			}
		}
		raise(x > 0, "All hexadecimal images must end with a linebreak!")
		x = 0
		y = 0
		// Allocate image
		raise(width <= 0 || height <= 0, "A hexadecimal image had zero dimensions!")
		result := This new(IntVector2D new(width, height))
		// Fill pixels
		for (i in 0 .. (content size)) {
			c := content[i]
			if (c == '\0')
				break
			else if (This isHexadecimal(c)) {
				currentValue = (currentValue * 16) + fromHexaDigit(c)
				decimalCount += 1
				if (decimalCount >= 2) {
					result[x, y] = ColorMonochrome new(currentValue)
					currentValue = 0
					decimalCount = 0
					x += 1
				}
			} else if (c == '\n') {
				if (x > 0)
					y += 1
				x = 0
			}
		}
		result
	}
	// Serialize to a lossy ascii image using an alphabet to make the string more compact
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
		// Store alphabet
		result append('<')
		result append(alphabet)
		result append('>')
		result append('\n')
		// Serialize image
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
	// Parse the image using the same alphabet that was used to serialize the image.
	fromAscii: static func (content: String) -> This {
		// Measure dimensions and read the alphabet
		alphabet: Char[128]
		alphabetSize := 0
		x := 0
		y := -1
		width := 0
		inLine := false
		for (i in 0 .. (content size)) {
			c := content[i]
			if (c == '\0')
				break
			else if (inLine) {
				if (y < 0) {
					if (c == '>') {
						inLine = false
						y = 0
					} else if (alphabetSize < 128) {
						alphabet[alphabetSize] = c
						alphabetSize += 1
					}
				} else {
					if (c == '>') {
						inLine = false
						width = width maximum(x)
						y += 1
						x = 0
					} else
						x += 1
				}
			} else if (c == '<')
				inLine = true
		}
		raise(alphabetSize < 2, "The alphabet needs at least two characters!")
		height := y
		raise(x > 0, "All hexadecimal images must end with a linebreak!")
		// Create alphabet mapping from character to luma
		alphabetMap: Byte[128]
		for (i in 0 .. 128)
			alphabetMap[i] = 0
		for (i in 0 .. alphabetSize) {
			code := alphabet[i] as Int
			raise(code < 32 || code > 126, "Character '" + alphabet[i] + "' (" + code toString() + ") is not printable standard ascii!")
			raise(alphabetMap[code] > 0, "Character '" + alphabet[i] + "' (" + code toString() + ") is used more than once!")
			value := ((i as Float) * (255.0f / ((alphabetSize - 1) as Float))) as Int clamp(0, 255)
			alphabetMap[code] = value
		}
		// Allocate image
		raise(width <= 0 || height <= 0, "An ascii image had zero dimensions!")
		result := This new(IntVector2D new(width, height))
		// Fill pixels
		x = 0
		y = -1
		inLine = false
		for (i in 0 .. (content size)) {
			c := content[i]
			if (c == '\0')
				break
			else if (inLine) {
				if (c == '>') {
					inLine = false
					raise(y >= 0 && x != width, "Lines in the ascii image do not have the same length.")
					y += 1
					x = 0
				} else if (y >= 0) {
					result[x, y] = ColorMonochrome new(alphabetMap[(c as Int) clamp(0, 127)])
					x += 1
				}
			} else if (c == '<')
				inLine = true
		}
		result
	}
}
