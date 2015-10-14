use ooc-unit
use ooc-plot
use ooc-math
use ooc-collections
use ooc-draw
import math
import io/File

log := VectorList<FloatPoint2D> new()
cos := VectorList<FloatPoint2D> new()
unitCircle := VectorList<FloatPoint2D> new()
scatter := VectorList<FloatPoint2D> new()
parabola := VectorList<FloatPoint2D> new()
sparseParabola := VectorList<FloatPoint2D> new()
randomGenerator := IntUniformRandomGenerator new(0, 100)
for (i in -200 .. 201) {
	log add(FloatPoint2D new((201 + i as Float) * 100, log((201 + i as Float)) * 100))
	cos add(FloatPoint2D new(i as Float / 20, cos(i as Float / 20)))
	unitCircle add(FloatPoint2D new(i as Float / 200, sqrt(1 - pow(i as Float / 200, 2))))
	scatter add(FloatPoint2D new(randomGenerator next() as Float, randomGenerator next() as Float))
	parabola add(FloatPoint2D new(i as Float / 20, pow(i as Float / 20, 2)))
}
for (i in -200 .. 201) {
	unitCircle add(FloatPoint2D new(i as Float / 200, - sqrt(1 - pow(i as Float / 200, 2))))
	if (i % 50 == 0)
		sparseParabola add(FloatPoint2D new(i as Float / 20, pow(i as Float / 20, 2)))
}
randomGenerator free()

// Simplest use-case with line plot
logData := LinePlotData2D new(log, "log(x)")
logPlot := SvgPlot new(logData, "Simplest use-case with line plot")

// Simplest use-case with scatter plot
scatterData := ScatterPlotData2D new(scatter, "Random numbers")
scatterPlot := SvgPlot new(scatterData, "Simplest use-case with scatter plot")

// Multiple shapes in one plot
cosData := LinePlotData2D new(cos, "cos(x)")
shapesData := ShapePlotData2D new("Mixed shapes", ColorBgra new(0, 0, 0, 128))
shapesData addRectangle(FloatBox2D new(-4, 2, 8, 1)) // Default
shapesData addRectangle(FloatBox2D new(-4, -3, 8, 1)) // Default
shapesData addCircle(FloatPoint2D new(-3.1416, 0), 1, ColorBgra new(0, 0, 200, 128)) // Red
shapesData addCircle(FloatPoint2D new(0, 0), 1, ColorBgra new(0, 200, 0, 128)) // Green
shapesData addCircle(FloatPoint2D new(3.1416, 0), 1, ColorBgra new(200, 0, 0, 128)) // Blue
shapePlot := SvgPlot new(cosData, "Multiple shapes in one plot")
shapePlot addDataset(shapesData)
shapePlot xAxis label = "x"
shapePlot yAxis label = "y"
shapePlot xAxis min = -4
shapePlot xAxis max = 4
shapePlot yAxis min = -4
shapePlot yAxis max = 4
shapePlot symmetric = true

// Adjustment of axis endpoints
unitCircleData := LinePlotData2D new(unitCircle, "Unit circle")
unitCirclePlot := SvgPlot new(unitCircleData, "Unit circle plot with set axis endpoints")
unitCirclePlot xAxis label = "x"
unitCirclePlot yAxis label = "y"
unitCirclePlot xAxis min = -1.5
unitCirclePlot xAxis max = 1.5
unitCirclePlot yAxis min = -1.5
unitCirclePlot yAxis max = 1.5

// Symmetric plot
symmetricUnitCircleData := LinePlotData2D new(unitCircle, "Unit circle")
symmetricUnitCirclePlot := SvgPlot new(unitCircleData, "Unit circle plot with symmetric set to true")
symmetricUnitCirclePlot xAxis label = "x"
symmetricUnitCirclePlot yAxis label = "y"
symmetricUnitCirclePlot symmetric = true

// Plot that shows usage of various formatting options
scatterParabolaData := ScatterPlotData2D new(sparseParabola, "Temporary label")
scatterParabolaData shape = Shape Square
scatterParabolaData label = "" // label for the data object can be set
scatterParabolaData lineWidth = 4 // line width can be set, defaults to 1 if not set
scatterParabolaData colorBgra = ColorBgra new(255, 0, 0, 150) // color can be specified, if not specified a color map will be used
lineParabolaData := LinePlotData2D new(parabola, "x²")
lineParabolaData colorBgra = ColorBgra new(255, 0, 0, 150)
formatPlot := SvgPlot new(scatterParabolaData, "temporary title")
formatPlot addDataset(lineParabolaData)
formatPlot title = "Plot showing usage of various formatting options" // title can be set in this way
formatPlot fontSize = 20 // defaults to 14 if not set
formatPlot xAxis label = "x"
formatPlot xAxis fontSize = 12 // default to 10 for numbers, the label is displayed with fontsize + 4
formatPlot xAxis gridOn = false // defaults to true, set to false if grid is not wanted
formatPlot xAxis roundAxisEndpoints = false // defaults to true, if set to false the axis endpoints will be equal to the data's endpoints

// Write plots to file
filename := "test/plot/output/"
file := File new(filename)
folder := file parent . mkdirs() . free()
file free()
filename = filename + "example.svg"
writer := SvgWriter2D new(filename, logPlot)
writer addPlot(scatterPlot)
writer addPlot(shapePlot)
writer addPlot(unitCirclePlot)
writer addPlot(symmetricUnitCirclePlot)
writer addPlot(formatPlot)
writer write()

"SvgPlotTest [TODO: Not implemented as a fixture!]" printfln()
