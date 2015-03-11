use ooc-math

Shapes: abstract class {

	line: static func(start, end: FloatPoint2D, color: String) -> String {
		"<line x1='" + start x toString() + "' y1='" + start y toString() + "' x2='" + end x toString() + "' y2='" + end y toString() + "' stroke-width='1' stroke='" + color + "'/>"
	}

	line: static func ~dashed(start, end: FloatPoint2D, color: String, dashFloatPair: FloatPoint2D) -> String {
		"<line x1='" + start x toString() + "' y1='" + start y toString() + "' x2='" + end x toString() + "' y2='" + end y toString() + "' stroke-width='1' stroke='" + color + "' stroke-dasharray='" + dashFloatPair toString() + "'/>"
	}

	circle: static func(x, y, r, opacity: Float, color: String) -> String {
		"<circle cx='" + x toString() + "' cy='" + y toString() + "' r='" + r toString() + "' fill='" + color + "' fill-opacity='" + opacity toString() + "'/>"
	}

	ellipse: static func(center: FloatPoint2D, rx, ry, opacity: Float, color: String) -> String {
		"<ellipse cx='" + center x toString() + "' cy='" + center y toString() + "' rx='" + rx toString() + "' ry='" + ry toString() + "' fill='" + color + "' fill-opacity='" + opacity toString() + "'/>"
	}

	rect: static func ~FloatPoint2D(upperRight: FloatPoint2D, width, height: Float, opacity: Float, color: String) -> String {
		"<rect x='" + upperRight x toString() + "' y='" + upperRight y toString() + "' width='" + width toString() + "' height='" + height toString() + "' fill='" + color + "' fill-opacity='" + opacity toString() + "'/>"
	}

	rect: static func ~Float(x, y, width, height, opacity: Float, color: String) -> String {
		"<rect x='" + x toString() + "' y='" + y toString() + "' width='" + width toString() + "' height='" + height toString() + "' fill='" + color + "' fill-opacity='" + opacity toString() + "'/>"
	}

	text: static func ~simple(position: FloatPoint2D, text: String, fontSize: Int) -> String {
		This text(position, text, fontSize, "start")
	}

	text: static func ~textAnchor(position: FloatPoint2D, text: String, fontSize: Int, textAnchor: String) -> String {
		"<text id='" + text + "' x='" + position x toString() + "' y='" + position y toString() + "' font-size='" + fontSize toString() + "' fill='black'	text-anchor='" + textAnchor + "' >" + text + "</text>"
	}
}
