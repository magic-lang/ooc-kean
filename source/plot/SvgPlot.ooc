use collections
use ooc-geometry
use ooc-draw
import Axis
import PlotData2D
import svg/Shapes

SvgPlot: class {
	_colorCount := 0
	_symmetric: Bool
	colorCount ::= this _colorCount
	symmetric: Bool {
		get { this _symmetric }
		set (newValue) {
			this _symmetric = newValue
		}
	}
	datasets: VectorList<PlotData2D> { get set }
	title: String { get set }
	fontSize: Int { get set }
	xAxis: Axis { get set }
	yAxis: Axis { get set }
	colorList: VectorList<String> { get set }
	init: func {
		this init(VectorList<PlotData2D> new())
	}
	init: func ~datasets (=datasets, title := "", xAxisLabel := "", yAxisLabel := "") {
		this title = title
		this _symmetric = false
		this xAxis = Axis new(Orientation Horizontal, xAxisLabel)
		this yAxis = Axis new(Orientation Vertical, yAxisLabel)
		this setAxesMinMax()
	}
	init: func ~dataset (dataset: PlotData2D, title := "", xAxisLabel := "", yAxisLabel := "") {
		datasets := VectorList<PlotData2D> new()
		datasets add(dataset)
		this init(datasets, title, xAxisLabel, yAxisLabel)
	}
	free: override func {
		this datasets free()
		this xAxis free()
		this yAxis free()
		if (this colorList)
			this colorList free()
		super()
	}
	addDataset: func (dataset: PlotData2D) {
		this datasets add(dataset)
		this setAxesMinMax()
	}
	getSvg: func (size: FloatVector2D, fontSize: Int) -> String {
		if (this fontSize == 0)
			this fontSize = fontSize
		aspectRatio := size x / size y
		this fillColorList()
		this setColor()
		this xAxis roundEndpoints()
		this yAxis roundEndpoints()
		if (this _symmetric && aspectRatio != 1) {
			if (aspectRatio > 1) {
				this xAxis min *= aspectRatio
				this xAxis max *= aspectRatio
			} else {
				this yAxis min *= aspectRatio
				this yAxis max *= aspectRatio
			}
		}
		margin := FloatVector2D new(yAxis getRequiredMargin(this fontSize), xAxis getRequiredMargin(this fontSize))
		plotAreaSize := size - FloatVector2D new(2.0f * margin x, 2.0f * margin y)
		transform := FloatTransform2D createTranslation(- this xAxis min, - this yAxis min)
		transform = transform scale(this xAxis length() != 0.0f ? plotAreaSize x / this xAxis length() : 1.0f, this yAxis length() != 0.0f ? - plotAreaSize y / this yAxis length() : -1.0f)
		transform = transform translate(0.0f, plotAreaSize y)
		result := Shapes text(FloatPoint2D new(size x / 2.0f, margin y / 2.0f + this fontSize / 3.0f), this title, this fontSize + 2, "middle")
		result = result & this xAxis getSvg(plotAreaSize, margin, transform, fontSize)
		result = result & this yAxis getSvg(plotAreaSize, margin, transform, fontSize)
		result = result >> "<rect desc='Plot-border' x='" & margin x toString() >> "' y='" & margin y toString() >> "' width='" & plotAreaSize x toString() >> "' height='" & plotAreaSize y toString() >> "' stroke='black' fill='none'/>\n"
		result = result >> "<svg desc='Data' x='" & margin x toString() >> "' y='" & margin y toString() >> "' width='" & plotAreaSize x toString() >> "' height='" & plotAreaSize y toString() >> "'>\n"
		if (!this datasets empty)
			for (i in 0 .. this datasets count)
				result = result & this datasets[i] getSvg(transform)
		result = result >> "</svg>\n"
		result & this setLegends(size, plotAreaSize)
	}
	setAxesMinMax: func {
		if (!datasets empty) {
			min := datasets[0] minValues()
			max := datasets[0] maxValues()
			for (i in 0 .. datasets count) {
				min = min minimum(datasets[i] minValues())
				max = max maximum(datasets[i] maxValues())
			}
			this xAxis min = min x
			this xAxis max = max x
			this yAxis min = min y
			this yAxis max = max y
		}
	}
	setColor: func {
		if (!datasets empty) {
			noneColor := ColorBgra new(0, 0, 0, 0)
			for (j in 0 .. datasets count) {
				if (noneColor != datasets[j] colorBgra) {
					datasets[j] color = datasets[j] colorBgra svgRGBToString()
					datasets[j] opacity = ((datasets[j] colorBgra svgRGBAlpha()) as Float) / 255.0f
				} else {
					datasets[j] color = colorList[this _colorCount % this colorList count] clone()
					datasets[j] opacity = 1
					this _colorCount += 1
				}
			}
		}
	}
	fillColorList: func {
		this colorList = VectorList<String> new(10, false)
		this colorList add("crimson")
		this colorList add("black")
		this colorList add("darkmagenta")
		this colorList add("seagreen")
		this colorList add("dodgerblue")
		this colorList add("darkorange")
		this colorList add("hotpink")
		this colorList add("lightgreen")
		this colorList add("yellowgreen")
		this colorList add("red")
	}
	setLegends: func (size, plotAreaSize: FloatVector2D) -> String {
		result := "<svg desc='Legends' x='" << ((size x - plotAreaSize x) / 2) toString() >> "' y='" & ((size y - plotAreaSize y) / 2) toString() >> "' width='" & plotAreaSize x toString() >> "' height='" & plotAreaSize y toString() >> "' xmlns:xlink='http://www.w3.org/1999/xlink' xmlns:drag='http://www.codedread.com/dragsvg' onload='initializeDraggableElements();' onmouseup='mouseUp(evt)' onmousemove='mouseMove(evt)'>\n<script id='draggableLibrary' xlink:href='http://www.codedread.com/dragsvg.js'/>\n<g id='Legend' drag:enable='true'>\n"
		legendCounter := 0
		for (i in 0 .. this datasets count) {
			if (this datasets[i] label != "") {
				legendCounter += 1
				result = result & this datasets[i] getSvgLegend(legendCounter, fontSize)
			}
		}
		result >> "</g>\n</svg>\n"
	}
}
