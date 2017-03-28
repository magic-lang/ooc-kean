/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
import svg/Shapes

Orientation: enum {
	Horizontal
	Vertical
}

Axis: class {
	visible: Bool { get set }
	label: String { get set }
	min: Float { get set }
	max: Float { get set }
	tick: Float { get set (length) {
		(value, radix) := length decomposeToCoefficientAndRadix(1)
		this tick = radix
		if (value != 0.0f) {
			if (length / this tick < 1.1f)
				this tick /= 10.0f
			else if (length / this tick < 4.0f)
				this tick /= 2.0f
		}}
	}
	orientation: Orientation { get set }
	fontSize: Int { get set }
	gridOn: Bool { get set }
	precision: Int { get set }
	roundAxisEndpoints: Bool { get set }
	init: func (=orientation, label := "") {
		this visible = true
		this label = label
		this gridOn = true
		this precision = 3
		this roundAxisEndpoints = true
	}
	length: func -> Float {
		this max - this min
	}
	getSvg: func (plotAreaSize, margin: FloatVector2D, transform: FloatTransform2D, fontSize: Int) -> String {
		result := ""
		if (this visible) {
			if (this fontSize == 0)
				this fontSize = fontSize
			this tick = this length()
			position := FloatPoint2D new(margin x, margin y + plotAreaSize y)
			radix := this length() getRadix(this precision)
			if (this orientation == Orientation Horizontal)
				result = this getHorizontalSvg(plotAreaSize, margin, position, transform, radix)
			else
				result = this getVerticalSvg(plotAreaSize, margin, position, transform, radix)
		}
		result
	}
	getHorizontalSvg: func (plotAreaSize, margin: FloatVector2D, position: FloatPoint2D, transform: FloatTransform2D, radix: Float) -> String {
		result := "<g desc='X-axis data'>\n"
		labelOffset := FloatPoint2D new(plotAreaSize x / 2.0f, 3.0f + (this fontSize - 4) + this fontSize)
		numberOffset := FloatPoint2D new(0.0f, 3.0f + (this fontSize - 4))
		radixOffset := FloatPoint2D new(plotAreaSize x + margin x / 2.0f, numberOffset y)
		tickMarkerEndOffset := FloatPoint2D new(0.0f, -5.0f)
		topTickMarkerStartOffset := FloatPoint2D new(0.0f, - plotAreaSize y)
		result = result & Shapes text(position + labelOffset, this label, this fontSize, "middle")
		result = result & this getRadixSvg(position + radixOffset, radix, "middle")
		tickValue := this getFirstTickValue()
		position x += transform translation x + transform scalingX * tickValue
		while (tickValue <= this max) {
			result = result & this getTickSvg(tickValue, radix, position, numberOffset, topTickMarkerStartOffset, tickMarkerEndOffset, "middle")
			tickValue += this tick
			position x += transform scalingX * this tick
		}
		result >> "</g>\n"
	}
	getVerticalSvg: func (plotAreaSize, margin: FloatVector2D, position: FloatPoint2D, transform: FloatTransform2D, radix: Float) -> String {
		result := "<g desc='Y-axis data'>\n"
		labelOffset := FloatPoint2D new(-((this max maximum(this min absolute) / radix) log10() + 3.0f) * 0.6f * (this fontSize - 4.0f), - plotAreaSize y / 2.0f)
		numberOffset := FloatPoint2D new(- 0.6f * (this fontSize - 4.0f), (this fontSize - 4.0f) / 3.0f)
		radixOffset := FloatPoint2D new(numberOffset x, - plotAreaSize y - margin y / 2 + this fontSize / 3.0f)
		tickMarkerEndOffset := FloatPoint2D new(5.0f, 0.0f)
		rightTickMarkerStartOffset := FloatPoint2D new(plotAreaSize x, 0.0f)
		result = result >> "<g desc='rotated Y-axis' transform='rotate(-90," & (position x + labelOffset x) toString() >> "," & (position y + labelOffset y) toString() >> ")'>\n"
		result = result & Shapes text(position + labelOffset, this label, this fontSize, "middle")
		result = result >> "</g>\n"
		result = result & this getRadixSvg(position + radixOffset, radix, "end")
		tickValue := this getFirstTickValue()
		position y += transform translation y - plotAreaSize y - transform scalingY * tickValue
		while (tickValue <= this max) {
			result = result & this getTickSvg(tickValue, radix, position, numberOffset, rightTickMarkerStartOffset, tickMarkerEndOffset, "end")
			tickValue += this tick
			position y -= transform scalingY * this tick
		}
		result >> "</g>\n"
	}
	getRadixSvg: func (position: FloatPoint2D, radix: Float, textAnchor: String) -> String {
		result := ""
		if (radix >= 10 pow(this precision - 1) || radix <= 10 pow(-this precision)) {
			scientificPower := radix getScientificPowerString()
			result = result & Shapes text(position, scientificPower, this fontSize, textAnchor)
			scientificPower free()
		}
		result
	}
	getTickSvg: func (tickValue, radix: Float, position, numberOffset, tickMarkerOnOtherSideOffset, tickMarkerEndOffset: FloatPoint2D, textAnchor: String) -> String {
		result := "<g desc='" << tickValue toString() >> "'>\n"
		if (this gridOn)
			result = result & Shapes line(position, position + tickMarkerOnOtherSideOffset, 1, 255.0f, "grey", FloatPoint2D new(5, 5))
		result = result & Shapes line(position, position + tickMarkerEndOffset, 1, 255.0f, "black")
		result = result & Shapes line(position + tickMarkerOnOtherSideOffset, position + tickMarkerOnOtherSideOffset - tickMarkerEndOffset, 1, 255.0f, "black")
		tickValue = radix >= 10 pow(this precision - 1) || radix <= 10 pow(-this precision) ? (tickValue / radix) : tickValue
		tempTick := tickValue toString()
		tempTickInt := tickValue as Int toString()
		result = result & Shapes text(position + numberOffset, (tickValue - tickValue round()) absolute < 0.001 ? tempTickInt : tempTick, this fontSize - 4, textAnchor)
		(tempTick, tempTickInt) free()
		result >> "</g>\n"
	}
	getFirstTickValue: func -> Float {
		result: Float
		if ((this min < this tick && this min > 0.0f) || (this min > this tick && this min < 1.0f))
			result = this min + this tick - this min modulo(this tick)
		else
			result = this min - this min modulo(this tick)
		result
	}
	getRequiredMargin: func (fontSize: Int) -> Float {
		result: Float
		if (this fontSize == 0)
			this fontSize = fontSize
		if (this orientation == Orientation Horizontal)
			result = 2.5f * this fontSize as Float
		else
			result = (this precision + 2) * (this fontSize as Float - 4)
		result
	}
	roundEndpoints: func {
		if (this roundAxisEndpoints) {
			this min = this min roundToValueDigits(2, false)
			this max = this max roundToValueDigits(2, true)
		}
	}
}
