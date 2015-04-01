use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D
import Axis
import io/File
import io/FileWriter
import SVGPlot
import LinePlotData2D
import svg/Shapes
import math

SVGWriter2D: class {
	file: File { get set }
	svgPlots: VectorList<SVGPlot> { get set }
	height: Int { get set }
	width: Int { get set }
	fontSize: Int { get set }
	numberOfPlotsHorizontally: Int

	init: func (=file) {
		this svgPlots = VectorList<SVGPlot> new()
		this width = 1920
		this height = 1080
		this fontSize = 14
	}
	init: func ~fileName(filename: String) {
		this init(File new(filename))
	}
	init: func ~svgPlot(file: File, args: ...) {
		this init(file)

		iterator := args iterator()
		while (iterator hasNext?()) {
			match (iterator getNextType()) {
				case SVGPlot => this addPlot(iterator next(SVGPlot))
				case => // no action, unsupported type
			}
		}
	}
	init: func ~svgPlotWithFilename(filename: String, args: ...) {
		this init(File new(filename), args)
	}
	init: func ~withPositioning(file: File, =numberOfPlotsHorizontally, args: ...) {
		this init(file, args)
	}
	init: func ~withPositioningFilename(filename: String, =numberOfPlotsHorizontally, args: ...) {
		this init(File new(filename), args)
	}
	init: func ~svgPlots(file: File, svgPlots: VectorList<SVGPlot>) {
		this init(file)
		this svgPlots = svgPlots
	}
	init: func ~svgPlotsFilename(filename: String, svgPlots: VectorList<SVGPlot>) {
		this init(File new(filename))
		this svgPlots = svgPlots
	}
	free: override func {
		svgPlots free()
		file free()
		super();
	}

	addPlot: func (svgPlot: SVGPlot) {
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
		result = result >> "<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.1' width='" & this width toString() >> "' height='" & this height toString() >> "'>\n"

		result = result >> "<rect desc='background' width='100%' height='100%' fill='white'/>\n"

		if (!this svgPlots empty()) {
			numPlotsX: Int
			numPlotsY: Int
			if (this numberOfPlotsHorizontally == 0) {
				if (this svgPlots count > 1 && this svgPlots count < 5)
					numPlotsX = 2
				else if (this svgPlots count >= 5)
					numPlotsX = 3
				else
					numPlotsX = 1
				numPlotsY = Int modulo(this svgPlots count, numPlotsX) ? 1 + this svgPlots count / numPlotsX : this svgPlots count / numPlotsX
			} else {
				numPlotsX = numberOfPlotsHorizontally
				numPlotsY = ceil(this svgPlots count as Float / numPlotsX as Float) as Int
			}

			plotSize := FloatPoint2D new(this width / numPlotsX, this height / numPlotsY)
			position := FloatPoint2D new()

			for (i in 0..this svgPlots count) {
				position x = plotSize x * Int modulo(i, numPlotsX)
				position y = plotSize y * (i / numPlotsX)

				result = result >> "<svg desc='Plot " & (i + 1) toString() >> "' x='" & position x toString() >> "' y='" & position y toString() >> "' width='" & plotSize x toString() >> "' height='" & plotSize y toString() >> "'>\n"
				result = result & svgPlots[i] getSVG(plotSize, fontSize)
				result = result >> "</svg>\n"
			}
		}

		result = result >> "</svg>\n"
		result
	}
}
