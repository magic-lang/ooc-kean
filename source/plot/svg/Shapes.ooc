use ooc-math

Shapes: abstract class {

	line: static func (start, end: FloatPoint2D, color: String) -> String {
		"<line x1='" clone() & start x toString() & "' y1='" clone() & start y toString() & "' x2='" clone() & end x toString() & "' y2='" clone() & end y toString() & "' stroke-width='1' stroke='" clone() & color clone() & "'/>\n" clone()
	}

	line: static func ~dashed(start, end: FloatPoint2D, color: String, dashFloatPair: FloatPoint2D) -> String {
		"<line x1='" clone() & start x toString() & "' y1='" clone() & start y toString() & "' x2='" clone() & end x toString() & "' y2='" clone() & end y toString() & "' stroke-width='1' stroke='" clone() & color clone() & "' stroke-dasharray='" clone() & dashFloatPair toString() & "'/>\n" clone()
	}

	circle: static func (x, y, r, opacity: Float, color: String) -> String {
		"<circle cx='" clone() & x toString() & "' cy='" clone() & y toString() & "' r='" clone() & r toString() & "' fill='" clone() & color clone() & "' fill-opacity='" clone() & opacity toString() & "'/>\n" clone()
	}

	ellipse: static func (center: FloatPoint2D, rx, ry, opacity: Float, color: String) -> String {
		"<ellipse cx='" clone() & center x toString() & "' cy='" clone() & center y toString() & "' rx='" clone() & rx toString() & "' ry='" clone() & ry toString() & "' fill='" clone() & color clone() & "' fill-opacity='" clone() & opacity toString() & "'/>\n" clone()
	}

	rect: static func ~FloatPoint2D(upperRight: FloatPoint2D, width, height: Float, opacity: Float, color: String) -> String {
		"<rect x='" clone() & upperRight x toString() & "' y='" clone() & upperRight y toString() & "' width='" clone() & width toString() & "' height='" clone() & height toString() & "' fill='" clone() & color clone() & "' fill-opacity='" clone() & opacity toString() & "'/>\n" clone()
	}

	rect: static func ~Float(x, y, width, height, opacity: Float, color: String) -> String {
		"<rect x='" clone() & x toString() & "' y='" clone() & y toString() & "' width='" clone() & width toString() & "' height='" clone() & height toString() & "' fill='" clone() & color clone() & "' fill-opacity='" clone() & opacity toString() & "'/>\n" clone()
	}

	text: static func ~simple(position: FloatPoint2D, text: String, fontSize: Int) -> String {
		This text(position, text, fontSize, "start")
	}

	text: static func ~textAnchor(position: FloatPoint2D, text: String, fontSize: Int, textAnchor: String) -> String {
		"<text id='" clone() & text clone() & "' x='" clone() & position x toString() & "' y='" clone() & position y toString() & "' font-size='" clone() & fontSize toString() & "' fill='black'	text-anchor='" clone() & textAnchor clone() & "' >" clone() & text clone() + "</text>\n" clone()
	}
}
