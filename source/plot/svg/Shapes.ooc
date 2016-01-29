/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry

Shapes: abstract class {
	line: static func (start, end: FloatPoint2D, lineWidth: Float, opacity: Float, color: String) -> String {
		"<line x1='" << start x toString() >> "' y1='" & start y toString() >> "' x2='" & end x toString() >> "' y2='" & end y toString() >> "' stroke-width='" & lineWidth toString() >> "' stroke='" >> color >> "' stroke-opacity='" & opacity toString() >> "'/>\n"
	}
	line: static func ~dashed (start, end: FloatPoint2D, lineWidth: Float, opacity: Float, color: String, dashFloatPair: FloatPoint2D) -> String {
		"<line x1='" << start x toString() >> "' y1='" & start y toString() >> "' x2='" & end x toString() >> "' y2='" & end y toString() >> "' stroke-width='" & lineWidth toString() >> "' stroke='" >> color >> "' stroke-opacity='" & opacity toString() >> "' stroke-dasharray='" & dashFloatPair toString() >> "'/>\n"
	}
	circle: static func (center: FloatPoint2D, r, opacity: Float, color: String) -> String {
		This ellipse(center, r, r, opacity, color)
	}
	ellipse: static func (center: FloatPoint2D, rx, ry, opacity: Float, color: String) -> String {
		"<ellipse cx='" << center x toString() >> "' cy='" & center y toString() >> "' rx='" & rx toString() >> "' ry='" & ry toString() >> "' fill='" >> color >> "' fill-opacity='" & opacity toString() >> "'/>\n"
	}
	rect: static func ~FloatPoint2D (upperRight, size: FloatPoint2D, opacity: Float, color: String) -> String {
		This rect(upperRight x, upperRight y, size x, size y, opacity, color)
	}
	rect: static func ~positionFloatPoint2D (upperRight: FloatPoint2D, width, height, opacity: Float, color: String) -> String {
		This rect(upperRight x, upperRight y, width, height, opacity, color)
	}
	rect: static func ~Float (x, y, width, height, opacity: Float, color: String) -> String {
		"<rect x='" << x toString() >> "' y='" & y toString() >> "' width='" & width toString() >> "' height='" & height toString() >> "' fill='" >> color >> "' fill-opacity='" & opacity toString() >> "'/>\n"
	}
	text: static func ~simple (position: FloatPoint2D, text: String, fontSize: Int, opacity := 255.0f, color := "black") -> String {
		This text(position, text, fontSize, "start", opacity, color)
	}
	text: static func ~textAnchor (position: FloatPoint2D, text: String, fontSize: Int, textAnchor: String, opacity := 255.0f, color := "black") -> String {
		"<text id='" + text >> "' x='" & position x toString() >> "' y='" & position y toString() >> "' font-size='" & fontSize toString() >> "px' text-anchor='" >> textAnchor >> "' fill='" >> color >> "' fill-opacity='" & opacity toString() >> "'>" >> text >> "</text>\n"
	}
}
