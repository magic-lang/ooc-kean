use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D
import Axis
import io/File
import io/FileWriter
import SvgPlot
import LinePlotData2D
import svg/Shapes
import math

SvgWriter2D: class {
	file: File { get set }
	svgPlots: VectorList<SvgPlot> { get set }
	size: FloatSize2D { get set }
	fontSize: Int { get set }
	numberOfPlotsHorizontally: Int
	init: func (=file) {
		this init(file, VectorList<SvgPlot> new())
	}
	init: func ~fileName (filename: String) {
		this init(File new(filename))
	}
	init: func ~svgPlot (file: File, args: ...) {
		this init(file)
		iterator := args iterator()
		while (iterator hasNext?()) {
			match (iterator getNextType()) {
				case SvgPlot => this addPlot(iterator next(SvgPlot))
				case => // no action, unsupported type
			}
		}
	}
	init: func ~svgPlotWithFilename (filename: String, args: ...) {
		this init(File new(filename), args)
	}
	init: func ~withPositioning (file: File, =numberOfPlotsHorizontally, args: ...) {
		this init(file, args)
	}
	init: func ~withPositioningFilename (filename: String, =numberOfPlotsHorizontally, args: ...) {
		this init(File new(filename), args)
	}
	init: func ~svgPlotsFilename (filename: String, svgPlots: VectorList<SvgPlot>) {
		this init(File new(filename), svgPlots)
	}
	init: func ~svgPlotsFile (=file, =svgPlots) {
		this size = FloatSize2D new(1920, 1080)
		this fontSize = 14
	}
	free: override func {
		svgPlots free()
		file free()
		super()
	}
	addPlot: func (svgPlot: SvgPlot) {
		this svgPlots add(svgPlot)
	}
	write: func {
		output := prepareOutput()
		fileWriter := FileWriter new(this file, false)
		fileWriter write(output)
		fileWriter close()
		output free()
		fileWriter free()
	}
	prepareOutput: func -> String {
		result := "<?xml version='1.0' standalone='no'?>\n"
		result = result >> "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>\n"
		result = result >> "<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.1' width='" & this size width toString() >> "' height='" & this size height toString() >> "'>\n"
		result = result >> "<rect desc='background' width='100%' height='100%' fill='white'/>\n"
		if (!this svgPlots empty) {
			numPlotsX: Int
			numPlotsY: Int
			if (this numberOfPlotsHorizontally == 0) {
				if (this svgPlots count == 1)
					numPlotsX = 1
				else if (this svgPlots count < 5)
					numPlotsX = 2
				else
					numPlotsX = 3
				numPlotsY = Int modulo(this svgPlots count, numPlotsX) ? 1 + this svgPlots count / numPlotsX : this svgPlots count / numPlotsX
			} else {
				numPlotsX = numberOfPlotsHorizontally
				numPlotsY = ceil(this svgPlots count as Float / numPlotsX as Float) as Int
			}
			plotSize := FloatSize2D new(this size width / numPlotsX, this size height / numPlotsY)
			position := FloatPoint2D new()
			for (i in 0 .. this svgPlots count) {
				position x = plotSize width * Int modulo(i, numPlotsX)
				position y = plotSize height * (i / numPlotsX)
				result = result >> "<svg desc='Plot " & (i + 1) toString() >> "' x='" & position x toString() >> "' y='" & position y toString() >> "' width='" & plotSize width toString() >> "' height='" & plotSize height toString() >> "'>\n"
				result = result & svgPlots[i] getSvg(plotSize, fontSize)
				result = result >> "</svg>\n"
			}
		}
		result >> "</svg>\n"
	}
}
