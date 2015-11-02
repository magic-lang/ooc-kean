use ooc-math
use ooc-draw

Shapes: abstract class {
	getColor: static func (bgra: ColorBgra) -> String {
		"rgb(" clone() & bgra bgr red toString() & "," clone() & bgra bgr green toString() & "," clone() & bgra bgr blue toString() & ")" clone()
	}
	getOpacity: static func (bgra: ColorBgra) -> String {
		((bgra alpha as Float) / 255.0f) toString()
	}
	line: static func (start, end: FloatPoint2D, lineWidth: Float, color: ColorBgra) -> String {
		"<line x1='" << start x toString() >> "' y1='" & start y toString() >> "' x2='" & end x toString() >> "' y2='" & end y toString() >> "' stroke-width='" & lineWidth toString() >> "' stroke-linecap='round' stroke='" >> This getColor(color) >> "' stroke-opacity='" >> This getOpacity(color) >> "'/>\n"
	}
	line: static func ~dashed (start, end: FloatPoint2D, lineWidth: Float, color: ColorBgra, dashFloatPair: FloatPoint2D) -> String {
		"<line x1='" << start x toString() >> "' y1='" & start y toString() >> "' x2='" & end x toString() >> "' y2='" & end y toString() >> "' stroke-width='" & lineWidth toString() >> "' stroke-linecap='round' stroke='" >> This getColor(color) >> "' stroke-opacity='" >> This getOpacity(color) >> "' stroke-dasharray='" & dashFloatPair toString() >> "'/>\n"
	}
	circle: static func (center: FloatPoint2D, r: Float, color: ColorBgra) -> String {
		This ellipse(center, r, r, color)
	}
	ellipse: static func (center: FloatPoint2D, rx, ry: Float, color: ColorBgra) -> String {
		"<ellipse cx='" << center x toString() >> "' cy='" & center y toString() >> "' rx='" & rx toString() >> "' ry='" & ry toString() >> "' fill='" >> This getColor(color) >> "' fill-opacity='" >> This getOpacity(color) >> "'/>\n"
	}
	rect: static func ~FloatPoint2D (upperRight, size: FloatPoint2D, color: ColorBgra) -> String {
		This rect(upperRight x, upperRight y, size x, size y, color)
	}
	rect: static func ~positionFloatPoint2D (upperRight: FloatPoint2D, width, height: Float, color: ColorBgra) -> String {
		This rect(upperRight x, upperRight y, width, height, color)
	}
	rect: static func ~Float (x, y, width, height: Float, color: ColorBgra) -> String {
		"<rect x='" << x toString() >> "' y='" & y toString() >> "' width='" & width toString() >> "' height='" & height toString() >> "' fill='" >> This getColor(color) >> "' fill-opacity='" >> This getOpacity(color) >> "'/>\n"
	}
	text: static func ~simple (position: FloatPoint2D, text: String, fontSize: Int, color := ColorBgra new(0, 0, 0, 255)) -> String {
		This text(position, text, fontSize, "start", color)
	}
	text: static func ~textAnchor (position: FloatPoint2D, text: String, fontSize: Int, textAnchor: String, color := ColorBgra new(0, 0, 0, 255)) -> String {
		"<text id='" + text >> "' x='" & position x toString() >> "' y='" & position y toString() >> "' font-size='" & fontSize toString() >> "px' text-anchor='" >> textAnchor >> "' fill='" >> This getColor(color) >> "' fill-opacity='" >> This getOpacity(color) >> "'>" >> text >> "</text>\n"
	}
}

Shape: enum {
	Circle
	Ellipse
	Square
	Rectangle
}
