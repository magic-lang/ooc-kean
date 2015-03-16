use ooc-collections
use ooc-math
use ooc-draw
import PlotData2D
import Axis
import io/FileWriter
import SVGPlot
import LinePlotData2D
import svg/Shapes

SVGWriter2D: class {
	filename: String { get set }
	svgPlots: VectorList<SVGPlot> { get set }
	height: Int { get set }
	width: Int { get set }

	init: func (=filename) {
		this svgPlots = VectorList<SVGPlot> new()
		this width = 1920
		this height = 1080
	}
	init: func ~svgPlot(filename: String, args: ...) {
		this init(filename)
		args each(|arg|
			match arg {
				case plot: SVGPlot => this addPlot(plot)
				case => // no action, unsupported argument
			}
		)
	}
	init: func ~svgPlots(filename: String, svgPlots: VectorList<SVGPlot>) {
		this init(filename)
		this svgPlots = svgPlots
	}

	addPlot: func (svgPlot: SVGPlot) {
		this svgPlots add(svgPlot)
	}

	write: func {
		output := prepareOutput()
		fileWriter := FileWriter new(this filename, false)
		fileWriter write(output)
		fileWriter close()
		output free()
		fileWriter free()
	}

	prepareOutput: func -> String {
		result := "<?xml version='1.0' standalone='no'?>\n"
		result = result >> "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>\n"
		result = result >> "<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.1' width='" & this width toString() & "' height='" clone() & this height toString() & "'>\n" clone()

		result = result & "<rect desc='background' width='100%' height='100%' fill='white'/>\n" clone()

		if (!this svgPlots empty()) {
			numPlotsX: Int
			numPlotsY: Int
			if (this svgPlots count > 1 && this svgPlots count < 5)
				numPlotsX = 2
			else if (this svgPlots count >= 5)
				numPlotsX = 3
			else
				numPlotsX = 1

			numPlotsY = Int modulo(this svgPlots count, numPlotsX) ? 1 + this svgPlots count / numPlotsX : this svgPlots count / numPlotsX
			plotSize := FloatPoint2D new(this width / numPlotsX, this height / numPlotsY)
			position := FloatPoint2D new()

			for (i in 0..this svgPlots count) {
				position x = plotSize x * Int modulo(i, numPlotsX)
				position y = plotSize y * (i / numPlotsX)

				result = result & "<svg desc='Plot " clone() & (i + 1) toString() & "' x='" clone() & position x toString() & "' y='" clone() & position y toString() & "' width='" clone() & plotSize x toString() & "' height='" clone() & plotSize y toString() & "'>\n" clone()
				result = result & svgPlots[i] getSVG(plotSize)
				result = result & "</svg>\n" clone()
			}
		}

		result = result & "</svg>\n" clone()
		result
	}
}
