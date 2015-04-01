use ooc-math
import svg/Shapes
import math

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
			(value, radix) := Float decomposeToCoefficientAndRadix(length, 1)
			this tick = radix
			if (value != 0.0f) {
				if (length / this tick < 1.1f)
					this tick /= 10.0f
				else if (length / this tick < 4.0f)
					this tick /= 2.0f
			}
		}
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
		result := this max - this min
		result
	}

	getSVG: func (plotAreaSize, margin, translationToOrigo, scaling: FloatPoint2D, fontSize: Int) -> String {
		result := ""
		if (this visible) {
			position := FloatPoint2D new(margin x, margin y + plotAreaSize y)

			if (this fontSize == 0)
				this fontSize = fontSize

			this tick = this length()
			radix := Float getRadix(this length(), this precision)
			if (this orientation == Orientation Horizontal) {
				result = result >> "<g desc='X-axis data'>\n"
				labelOffset := FloatPoint2D new(plotAreaSize x / 2.0f, 3.0f + (this fontSize - 4) + this fontSize)
				numberOffset := FloatPoint2D new(0.0f, 3.0f + (this fontSize - 4))
				tickMarkerEndOffset := FloatPoint2D new(0.0f, -5.0f)
				topTickMarkerStartOffset := FloatPoint2D new(0.0f, - plotAreaSize y)
				result = result & Shapes text(position + labelOffset, this label, this fontSize, "middle")
				if (radix >= pow(10, this precision - 1) || radix <= pow(10, - this precision)) {
					radixOffset := FloatPoint2D new(plotAreaSize x + margin x / 2.0f, numberOffset y)
					scientificPower := Float getScientificPowerString(radix)
					result = result & Shapes text(position + radixOffset, scientificPower, this fontSize, "middle")
					scientificPower free()
				}

				tickValue := this getFirstTickValue()
				position x += translationToOrigo x + scaling x * tickValue
				while (tickValue <= this max) {
					result = result & this getTickSVG(tickValue, radix, position, numberOffset, topTickMarkerStartOffset, tickMarkerEndOffset, "middle")
					tickValue += this tick
					position x += scaling x * tick
				}
			} else {
				result = result >> "<g desc='Y-axis data'>\n"
				labelOffset := FloatPoint2D new(- (log10(Float maximum(this max, Float absolute(this min)) / radix) + 3.0f) * 0.6f * (this fontSize - 4.0f), - plotAreaSize y / 2.0f)
				numberOffset := FloatPoint2D new(- 0.6f * (this fontSize - 4.0f), (this fontSize - 4.0f) / 3.0f)
				tickMarkerEndOffset := FloatPoint2D new(5.0f, 0.0f)
				rightTickMarkerStartOffset := FloatPoint2D new(plotAreaSize x, 0.0f)
				result = result >> "<g desc='rotated Y-axis' transform='rotate(-90," & (position x + labelOffset x) toString() >> "," & (position y + labelOffset y) toString() >> ")'>\n"
				result = result & Shapes text(position + labelOffset, this label, this fontSize, "middle")
				result = result >> "</g>\n"
				if (radix >= pow(10, this precision - 1) || radix <= pow(10, - this precision)) {
					radixOffset := FloatPoint2D new(numberOffset x, - plotAreaSize y - margin y / 2 + this fontSize / 3.0f)
					scientificPower := Float getScientificPowerString(radix)
					result = result & Shapes text(position + radixOffset, scientificPower, this fontSize, "end")
					scientificPower free()
				}

				tickValue := this getFirstTickValue()
				position y += translationToOrigo y - plotAreaSize y - scaling y * tickValue
				while (tickValue <= this max) {
					result = result & this getTickSVG(tickValue, radix, position, numberOffset, rightTickMarkerStartOffset, tickMarkerEndOffset, "end")
					tickValue += this tick
					position y -= scaling y * tick
				}
			}
			result = result >> "</g>\n"
		}
		result
	}

	getFirstTickValue: func -> Float {
		result: Float
		if ((this min < this tick && this min > 0.0f) || (this min > this tick && this min > 0.0f && this min < 1.0f))
			result = this min + (this tick - Float modulo(this min, this tick))
		else
			result = this min - Float modulo(this min, this tick)
		result
	}

	getTickSVG: func (tickValue, radix: Float, position, numberOffset, tickMarkerOnOtherSideOffset, tickMarkerEndOffset: FloatPoint2D, textAnchor: String) -> String {
		result := "<g desc='" << tickValue toString() >> "'>\n"
		if (this gridOn)
			result = result & Shapes line(position, position + tickMarkerOnOtherSideOffset, 1, 255.0f, "grey", FloatPoint2D new(5,5))
		result = result & Shapes line(position, position + tickMarkerEndOffset, 1, 255.0f, "black")
		result = result & Shapes line(position + tickMarkerOnOtherSideOffset, position + tickMarkerOnOtherSideOffset - tickMarkerEndOffset, 1, 255.0f, "black")
		tickValue = radix >= pow(10, this precision - 1) || radix <= pow(10, - this precision) ? (tickValue / radix) : tickValue
		tempTick := tickValue toString()
		tempTickInt := tickValue as Int toString()
		result = result & Shapes text(position + numberOffset, Float absolute(tickValue - tickValue round()) < 0.001 ? tempTickInt : tempTick, this fontSize - 4, textAnchor)
		tempTick free()
		tempTickInt free()
		result = result >> "</g>\n"
		result
	}

	getRequiredMargin: func(fontSize: Int) -> Float {
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
			this min = Float roundToValueDigits(this min, 2, false)
			this max = Float roundToValueDigits(this max, 2, true)
		}
	}
}
