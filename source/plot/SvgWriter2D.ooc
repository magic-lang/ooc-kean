/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use geometry
use draw
import PlotData2D
import Axis
import io/File
import io/FileWriter
import SvgPlot
import LinePlotData2D
import svg/Shapes

SvgWriter2D: class {
	_numberOfPlotsHorizontally: Int
	file: File { get set }
	svgPlots: VectorList<SvgPlot> { get set }
	size: FloatVector2D { get set }
	fontSize: Int { get set }
	init: func (=file) {
		this init(file, VectorList<SvgPlot> new())
	}
	init: func ~fileName (filename: String) {
		this init(File new(filename))
	}
	init: func ~svgPlot (file: File, args: ...) {
		this init(file)
		iterator := args iterator()
		while (iterator hasNext()) {
			match (iterator getNextType()) {
				case SvgPlot => this addPlot(iterator next(SvgPlot))
				case => // no action, unsupported type
			}
		}
	}
	init: func ~svgPlotWithFilename (filename: String, args: ...) {
		this init(File new(filename), args)
	}
	init: func ~withPositioning (file: File, =_numberOfPlotsHorizontally, args: ...) {
		this init(file, args)
	}
	init: func ~withPositioningFilename (filename: String, =_numberOfPlotsHorizontally, args: ...) {
		this init(File new(filename), args)
	}
	init: func ~svgPlotsFilename (filename: String, svgPlots: VectorList<SvgPlot>) {
		this init(File new(filename), svgPlots)
	}
	init: func ~svgPlotsFile (=file, =svgPlots) {
		this size = FloatVector2D new(1920, 1080)
		this fontSize = 14
	}
	free: override func {
		(this svgPlots, this file) free()
		super()
	}
	addPlot: func (svgPlot: SvgPlot) {
		this svgPlots add(svgPlot)
	}
	write: func {
		output := this prepareOutput()
		fileWriter := FileWriter new(this file, false)
		fileWriter write(output)
		(output, fileWriter) free()
	}
	prepareOutput: func -> String {
		result := "<?xml version='1.0' standalone='no'?>\n"
		result = result >> "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>\n"
		result = result >> "<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.1' width='" & this size x toString() >> "' height='" & this size y toString() >> "'>\n"
		result = result >> "<rect desc='background' width='100%' height='100%' fill='white'/>\n"
		if (!this svgPlots empty) {
			numPlotsX: Int
			numPlotsY: Int
			if (this _numberOfPlotsHorizontally == 0) {
				if (this svgPlots count == 1)
					numPlotsX = 1
				else if (this svgPlots count < 5)
					numPlotsX = 2
				else
					numPlotsX = 3
				numPlotsY = this svgPlots count modulo(numPlotsX) != 0 ? 1 + this svgPlots count / numPlotsX : this svgPlots count / numPlotsX
			} else {
				numPlotsX = this _numberOfPlotsHorizontally
				numPlotsY = (this svgPlots count as Float / numPlotsX as Float) ceil() as Int
			}
			plotSize := FloatVector2D new(this size x / numPlotsX, this size y / numPlotsY)
			position := FloatPoint2D new()
			for (i in 0 .. this svgPlots count) {
				position x = plotSize x * i modulo(numPlotsX)
				position y = plotSize y * (i / numPlotsX)
				result = result >> "<svg desc='Plot " & (i + 1) toString() >> "' x='" & position x toString() >> "' y='" & position y toString() >> "' width='" & plotSize x toString() >> "' height='" & plotSize y toString() >> "'>\n"
				result = result & this svgPlots[i] getSvg(plotSize, this fontSize)
				result = result >> "</svg>\n"
			}
		}
		result >> "</svg>\n"
	}
}
