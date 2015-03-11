use ooc-math
import svg/Shapes
import math

Orientation: enum {
	Horizontal
	Vertical
}

Axis: class {
	label: String { get set }
	min: Float { get set }
	max: Float { get set }
	tick: Float { get set (length) {
			valueAndPower := this decomposeToValueAndPower(length, 1)
			this tick = valueAndPower[1]
			if (valueAndPower[0] != 0) {
				if (length / this tick < 1.1f) {
					this tick /= 10.0f
				} else if (length / this tick < 4.0f) {
					this tick /= 2.0f
				}
			}
		}
	}
	orientation: Orientation { get set }
	fontSize: Int { get set }
	gridOn: Bool { get set }
	precision: Int { get set }
	roundAxisEndpoints: Bool { get set }

	init: func (=orientation) {
		this label = ""
		this fontSize = 10
		this gridOn = true
		this precision = 3
		this roundAxisEndpoints = true
	}

	length: func -> Float {
		result := this max - this min
		result
	}

	getSVG: func (plotAreaSize, axisAreaSize, position, translationToOrigo, scaling: FloatPoint2D) -> String {
		result := ""
		this tick = this length()
		base := this getBase(this length(), this precision)
		if (this orientation == Orientation Horizontal) {
			result = result & "<g desc='X-axis data'>\n" clone()
			labelOffset := FloatPoint2D new(this length() * scaling x / 2.0f, this fontSize + 0.5f * axisAreaSize y)
			numberOffset := FloatPoint2D new(0.0f, this fontSize + 0.2f * axisAreaSize y)
			tickMarkerEndOffset := FloatPoint2D new(0.0f, - axisAreaSize y * 0.1f)
			topTickMarkerStartOffset := FloatPoint2D new(0.0f, - plotAreaSize y)
			result = result & Shapes text(position + labelOffset, this label, this fontSize + 4, "middle")
			if (base >= pow(10, this precision - 1) || base <= pow(10, - this precision)) {
				baseOffset := FloatPoint2D new(axisAreaSize x + (plotAreaSize x / plotAreaSize y) * axisAreaSize y / 2, numberOffset y)
				result = result & Shapes text(position + baseOffset, this getScientificPower(base), this fontSize, "middle")
			}

			tickValue := this getFirstTickValue()
			position x += translationToOrigo x + scaling x * tickValue
			while (tickValue <= this max) {
				result = result & this getTickSVG(tickValue, base, position, numberOffset, topTickMarkerStartOffset, tickMarkerEndOffset, "middle")
				tickValue += this tick
				position x += scaling x * tick
			}
		} else {
			result = result & "<g desc='Y-axis data'>\n" clone()
			labelOffset := FloatPoint2D new(- 0.6f * axisAreaSize x, - this length() * scaling y / 2.0f)
			numberOffset := FloatPoint2D new(-0.2f * axisAreaSize x, this fontSize / 2)
			tickMarkerEndOffset := FloatPoint2D new(axisAreaSize x * 0.1f, 0.0f)
			rightTickMarkerStartOffset := FloatPoint2D new(plotAreaSize x, 0.0f)
			result = result & "<g desc='rotated Y-axis' transform='rotate(-90," clone() & (position x + labelOffset x) toString() & "," clone() & (position y + labelOffset y) toString() & ")'>\n" clone()
			result = result & Shapes text(position + labelOffset, this label, this fontSize + 4, "middle")
			result = result & "</g>\n" clone()
			if (base >= pow(10, this precision - 1) || base <= pow(10, - this precision)) {
				baseOffset := FloatPoint2D new(numberOffset x, - axisAreaSize y - (plotAreaSize y / plotAreaSize x) * axisAreaSize x / 2 + this fontSize / 2)
				result = result & Shapes text(position + baseOffset, this getScientificPower(base), this fontSize, "end")
			}

			tickValue := this getFirstTickValue()
			position y += translationToOrigo y - plotAreaSize y - scaling y * tickValue
			while (tickValue <= this max) {
				result = result & this getTickSVG(tickValue, base, position, numberOffset, rightTickMarkerStartOffset, tickMarkerEndOffset, "end")
				tickValue += this tick
				position y += - scaling y * tick
			}
		}
		result = result & "</g>\n" clone()
		result
	}

	getFirstTickValue: func -> Float {
		result: Float
		if ((this min < this tick && this min > 0.0f) || (this min > this tick && this min > 0.0f && this min < 1.0f) )
			result = this min + (this tick - Float modulo(this min, this tick))
		else
			result = this min - Float modulo(this min, this tick)
		result
	}

	getTickSVG: func (tickValue, base: Float, position, numberOffset, tickMarkerOnOtherSideOffset, tickMarkerEndOffset: FloatPoint2D, textAnchor: String) -> String {
		result := "<g desc='" clone() & tickValue toString() & "'>\n" clone()
		if (this gridOn)
			result = result & Shapes line(position, position + tickMarkerOnOtherSideOffset, "grey", FloatPoint2D new(5,5))
		result = result & Shapes line(position, position + tickMarkerEndOffset, "black")
		result = result & Shapes line(position + tickMarkerOnOtherSideOffset, position + tickMarkerOnOtherSideOffset - tickMarkerEndOffset, "black")
		tickValue = base >= pow(10, this precision - 1) || base <= pow(10, - this precision) ? (tickValue / base) : tickValue
		tempTick := tickValue toString()
		tempTickInt := tickValue as Int toString()
		result = result & Shapes text(position + numberOffset, tickValue == floor(tickValue) ? tempTickInt : tempTick, this fontSize, textAnchor)
		tempTick free()
		tempTickInt free()
		result = result & "</g>\n" clone()
		result
	}

	roundEndpoints: func {
		if (this roundAxisEndpoints) {
			this min = this roundToValueDigits(this min, 2, false)
			this max = this roundToValueDigits(this max, 2, true)
		}
	}

	roundToValueDigits: func (value: Float, valueDigits: Int, up: Bool) -> Float {
		valueAndPower := this decomposeToValueAndPower(value, valueDigits)
		result := valueAndPower[0]
		if (valueAndPower[0] != 0) {
			result = up ? ceil(valueAndPower[0]) : floor(valueAndPower[0])
			result *= valueAndPower[1]
		}
		result
	}

	decomposeToValueAndPower: func (value: Float, valueDigits: Int) -> Float[] {
		power := 1.0f
		if (value != 0) {
			while (Float absolute(value) > pow(10, valueDigits)) {
				value /= 10.0f
				power *= 10.0f
			}
			while (Float absolute(value) < pow(10, valueDigits-1)) {
				value *= 10.0f
				power /= 10.0f
			}
		}
		result := Float[2] new()
		result[0] = value
		result[1] = power
		result
	}

	getBase: func (value: Float, valueDigits: Int) -> Float {
		valueAndPower := this decomposeToValueAndPower(value, valueDigits)
		result := valueAndPower[1]
		result
	}

	getScientificPower: func (value: Float) -> String {
		// TODO: handle zero value
		power := 1
		while (value > 10) {
			power += 1
			value /= 10
		}
		while (value <= 1) {
			power -= 1
			value *= 10
		}
		result := "10^" + power toString()
		result
	}
}
