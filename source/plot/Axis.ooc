use ooc-math
import svg/Shapes
import math
use ooc-draw

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
	getSvg: func (plotAreaSize, margin: FloatSize2D, transform: FloatTransform2D, fontSize: Int) -> String {
		result := ""
		if (this visible) {
			if (this fontSize == 0)
				this fontSize = fontSize

			this tick = this length()
			position := FloatPoint2D new(margin width, margin height + plotAreaSize height)
			radix := Float getRadix(this length(), this precision)
			if (this orientation == Orientation Horizontal)
				result = this getHorizontalSvg(plotAreaSize, margin, position, transform, radix)
			else
				result = this getVerticalSvg(plotAreaSize, margin, position, transform, radix)
		}
		result
	}

	getHorizontalSvg: func (plotAreaSize, margin: FloatSize2D, position: FloatPoint2D, transform: FloatTransform2D, radix: Float) -> String {
		result := "<g desc='X-axis data'>\n"
		labelOffset := FloatPoint2D new(plotAreaSize width / 2.0f, 3.0f + (this fontSize - 4) + this fontSize)
		numberOffset := FloatPoint2D new(0.0f, 3.0f + (this fontSize - 4))
		radixOffset := FloatPoint2D new(plotAreaSize width + margin width / 2.0f, numberOffset y)
		tickMarkerEndOffset := FloatPoint2D new(0.0f, -5.0f)
		topTickMarkerStartOffset := FloatPoint2D new(0.0f, - plotAreaSize height)
		result = result & Shapes text(position + labelOffset, this label, this fontSize, "middle")
		result = result & this getRadixSvg(position + radixOffset, radix, "middle")
		tickValue := this getFirstTickValue()
		position x += transform translation width + transform scalingX * tickValue
		while (tickValue <= this max) {
			result = result & this getTickSvg(tickValue, radix, position, numberOffset, topTickMarkerStartOffset, tickMarkerEndOffset, "middle")
			tickValue += this tick
			position x += transform scalingX * tick
		}
		result >> "</g>\n"
	}

	getVerticalSvg: func (plotAreaSize, margin: FloatSize2D, position: FloatPoint2D, transform: FloatTransform2D, radix: Float) -> String {
		result := "<g desc='Y-axis data'>\n"
		labelOffset := FloatPoint2D new(- (log10(Float maximum(this max, Float absolute(this min)) / radix) + 3.0f) * 0.6f * (this fontSize - 4.0f), - plotAreaSize height / 2.0f)
		numberOffset := FloatPoint2D new(- 0.6f * (this fontSize - 4.0f), (this fontSize - 4.0f) / 3.0f)
		radixOffset := FloatPoint2D new(numberOffset x, - plotAreaSize height - margin height / 2 + this fontSize / 3.0f)
		tickMarkerEndOffset := FloatPoint2D new(5.0f, 0.0f)
		rightTickMarkerStartOffset := FloatPoint2D new(plotAreaSize width, 0.0f)
		result = result >> "<g desc='rotated Y-axis' transform='rotate(-90," & (position x + labelOffset x) toString() >> "," & (position y + labelOffset y) toString() >> ")'>\n"
		result = result & Shapes text(position + labelOffset, this label, this fontSize, "middle")
		result = result >> "</g>\n"
		result = result & this getRadixSvg(position + radixOffset, radix, "end")
		tickValue := this getFirstTickValue()
		position y += transform translation height - plotAreaSize height - transform scalingY * tickValue
		while (tickValue <= this max) {
			result = result & this getTickSvg(tickValue, radix, position, numberOffset, rightTickMarkerStartOffset, tickMarkerEndOffset, "end")
			tickValue += this tick
			position y -= transform scalingY * tick
		}
		result >> "</g>\n"
	}
	getRadixSvg: func (position: FloatPoint2D, radix: Float, textAnchor: String) -> String {
		result := ""
		if (radix >= pow(10, this precision - 1) || radix <= pow(10, - this precision)) {
			scientificPower := Float getScientificPowerString(radix)
			result = result & Shapes text(position, scientificPower, this fontSize, textAnchor)
			scientificPower free()
		}
		result
	}
	getTickSvg: func (tickValue, radix: Float, position, numberOffset, tickMarkerOnOtherSideOffset, tickMarkerEndOffset: FloatPoint2D, textAnchor: String) -> String {
		result := "<g desc='" << tickValue toString() >> "'>\n"
		if (this gridOn)
			result = result & Shapes line(position, position + tickMarkerOnOtherSideOffset, 1, ColorBgra new(128, 128, 128, 255), FloatPoint2D new(5, 5))
		result = result & Shapes line(position, position + tickMarkerEndOffset, 1, ColorBgra new(0, 0, 0, 255))
		result = result & Shapes line(position + tickMarkerOnOtherSideOffset, position + tickMarkerOnOtherSideOffset - tickMarkerEndOffset, 1, ColorBgra new(0, 0, 0, 255))
		tickValue = radix >= pow(10, this precision - 1) || radix <= pow(10, - this precision) ? (tickValue / radix) : tickValue
		tempTick := tickValue toString()
		tempTickInt := tickValue as Int toString()
		result = result & Shapes text(position + numberOffset, Float absolute(tickValue - tickValue round()) < 0.001 ? tempTickInt : tempTick, this fontSize - 4, textAnchor)
		tempTick free()
		tempTickInt free()
		result >> "</g>\n"
	}
	getFirstTickValue: func -> Float {
		result: Float
		if ((this min < this tick && this min > 0.0f) || (this min > this tick && this min < 1.0f))
			result = this min + (this tick - Float modulo(this min, this tick))
		else
			result = this min - Float modulo(this min, this tick)
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
			this min = Float roundToValueDigits(this min, 2, false)
			this max = Float roundToValueDigits(this max, 2, true)
		}
	}
}
