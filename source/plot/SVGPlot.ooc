use ooc-collections
use ooc-math
use ooc-draw
import Axis
import PlotData2D
import math
import svg/Shapes

SVGPlot: class {
	datasets: VectorList<PlotData2D> { get set }
	title: String { get set }
	fontSize: Int { get set }
	xAxis: Axis { get set }
	yAxis: Axis { get set }
	colorList: VectorList<String> { get set }
	colorCount:= 0
	plotAreaPercentage: Float
	symmetric: Bool


	init: func {
		this plotAreaPercentage = 0.8f
		this title=""
		this fontSize = 14
		this symmetric = false
		this xAxis = Axis new(Orientation HORIZONTAL)
		this yAxis = Axis new(Orientation VERTICAL)
		if (this datasets == null)
			this datasets = VectorList<PlotData2D> new()
		this setAxesMinMax()
	}

	init: func ~dataset (dataset: PlotData2D) {
		this init(dataset, "")
	}

	init: func ~datasets (datasets: VectorList<PlotData2D>) {
		this init(datasets, "")
	}

	init: func ~datasetTitle (dataset: PlotData2D, title: String) {
		this datasets = VectorList<PlotData2D> new()
		this datasets add(dataset)
	this init()
	this title = title
	}

	init: func ~datasetsTitle (datasets: VectorList<PlotData2D>, title: String) {
		this datasets = datasets
	this init()
	this title = title
	}

	addDataset: func(dataset: PlotData2D) {
		this datasets add(dataset)
		this setAxesMinMax()
	}

	getSVG: func(size: FloatPoint2D) -> String {
		aspectRatio:= size x / size y
		this fillColorList()
		this setColor()
		this xAxis roundEndpoints()
		this yAxis roundEndpoints()
		if (this symmetric && aspectRatio != 1) {
			if (aspectRatio > 1) {
				this xAxis min *= aspectRatio
				this xAxis max *= aspectRatio
			} else {
				this yAxis min *= aspectRatio
				this yAxis max *= aspectRatio
			}
		}

		plotAreaSize:= size * this plotAreaPercentage
		scaling:= FloatPoint2D new(plotAreaSize x / this xAxis length(), plotAreaSize y / this yAxis length())
		translationToRealOrigo:= FloatPoint2D new(- scaling x * this xAxis min, plotAreaSize y + scaling y * this yAxis min)
		bottomLeftCornerOfPlot:= FloatPoint2D new((size x - plotAreaSize x) / 2, (plotAreaSize y + (size y - plotAreaSize y) / 2))

		result:= Shapes text(FloatPoint2D new(size x / 2, (size y - plotAreaSize y) / 4 + this fontSize / 2), this title, this fontSize, "middle")
		xAxisSize:= FloatPoint2D new(plotAreaSize x, (size y - plotAreaSize y) / 2)
		yAxisSize:= FloatPoint2D new((size x - plotAreaSize x) / 2, plotAreaSize y)
		result += this xAxis getSVG(plotAreaSize, xAxisSize, bottomLeftCornerOfPlot, translationToRealOrigo, scaling)
		result += this yAxis getSVG(plotAreaSize, yAxisSize, bottomLeftCornerOfPlot, translationToRealOrigo, scaling)
		result += "<rect desc='Plot-border' x='" + bottomLeftCornerOfPlot x toString() + "' y='" + (bottomLeftCornerOfPlot y - plotAreaSize y) toString() + "' width='" + plotAreaSize x toString() + "' height='" + plotAreaSize y toString() + "' stroke='black' fill='none'/>"
		result += "<svg desc='Data' x='" + bottomLeftCornerOfPlot x toString() + "' y='" + (bottomLeftCornerOfPlot y - plotAreaSize y) toString() + "' width='" + plotAreaSize x toString() + "' height='" + plotAreaSize y toString() + "'>"
		result += "<g transform='translate(" + translationToRealOrigo toString() + ")'>"
		if (!this datasets empty()) {
			for (i in 0..this datasets count) {
				result += this datasets[i] getSVG(scaling)
			}
		}
		result += "</g></svg>"
		result += this setLegends(size, plotAreaSize)
		result
	}

	setAxesMinMax: func() {
		if (!datasets empty()) {
			min:= datasets[0] minValues()
			max:= datasets[0] maxValues()

			for (i in 0..datasets count) {
					min = min minimum(datasets[i] minValues())
					max = max maximum(datasets[i] maxValues())
			}

			this xAxis min = min x
			this xAxis max = max x
			this yAxis min = min y
			this yAxis max = max y
		}
	}

	setColor: func () {
		if (!datasets empty()) {
			noneColor:= ColorBgra new(0,0,0,0)
			for (j in 0..datasets count) {
				if(!(noneColor == datasets[j] colorBgra)){
					datasets[j] color = datasets[j] colorBgra svgRGBToString()
					datasets[j] opacity = ((datasets[j] colorBgra svgRGBAlpha()) as Float) / 255.0f
				}else{
					datasets[j] color = colorList[this colorCount % this colorList count]
					datasets[j] opacity = 1
					this colorCount+=1
				}
			}
		}
	}

	fillColorList: func() {
		this colorList = VectorList<String> new()
		this colorList add("crimson")
		this colorList add("darkorange")
		this colorList add("black")
		this colorList add("darkmagenta")
		this colorList add("seagreen")
		this colorList add("dodgerblue")
		this colorList add("hotpink")
		this colorList add("lightgreen")
		this colorList add("yellowgreen")
		this colorList add("red")
	}

	setLegends: func(size, plotAreaSize: FloatPoint2D) -> String {
		result:="<svg desc='Legends' x='" + ((size x - plotAreaSize x) / 2) toString() + "' y='" + ((size y - plotAreaSize y) / 2) toString() + "' width='" + (0.8f * size x) toString() + "' height='" + (0.8f * size y) toString() + "' xmlns:xlink='http://www.w3.org/1999/xlink' xmlns:drag='http://www.codedread.com/dragsvg' onload='initializeDraggableElements();' onmouseup='mouseUp(evt)' onmousemove='mouseMove(evt)'><script id='draggableLibrary' xlink:href='http://www.codedread.com/dragsvg.js'/><g id='Legend' drag:enable='true'>"
		legendCounter:= 0
		for (i in 0..this datasets count) {
			if (this datasets[i] label != "") {
				legendCounter += 1
				result += this datasets[i] getSvgLegend(legendCounter)
			}
		}
		result+="</g></svg>"
		result
	}
}
