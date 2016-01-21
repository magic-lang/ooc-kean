use unit
use plot
use math
use geometry
use collections
use draw
import io/[File, FileReader]

SvgPlotTest: class extends Fixture {
	init: func {
		super("SvgPlot")
		this add("Create plots", func {
			logVector := VectorList<FloatPoint2D> new()
			sinVector := VectorList<FloatPoint2D> new()
			cosVector := VectorList<FloatPoint2D> new()
			sinMinusCos := VectorList<FloatPoint2D> new()
			unitCircle := VectorList<FloatPoint2D> new()
			scatter := VectorList<FloatPoint2D> new()
			parabola := VectorList<FloatPoint2D> new()
			sparseParabola := VectorList<FloatPoint2D> new()
			randomGenerator := IntUniformRandomGenerator new(0, 100)
			randomGenerator setSeed(1991)

			for (i in -200 .. 201) {
				logVector add(FloatPoint2D new((201 + i as Float) * 100, (201.0f + i) log() * 100))
				sinVector add(FloatPoint2D new(i as Float / 20, sin(i as Float / 20)))
				cosVector add(FloatPoint2D new(i as Float / 20, cos(i as Float / 20)))
				sinMinusCos add(FloatPoint2D new(i as Float / 20, sin(i as Float / 20) - cos(i as Float / 20)))
				unitCircle add(FloatPoint2D new(i as Float / 200, sqrt(1 - (i as Float / 200) pow(2))))
				scatter add(FloatPoint2D new(randomGenerator next() as Float, randomGenerator next() as Float))
				parabola add(FloatPoint2D new(i as Float / 20, (i as Float / 20) pow(2)))
			}
			for (i in -200 .. 201) {
				unitCircle add(FloatPoint2D new(i as Float / 200, - sqrt(1 - (i as Float / 200) pow(2))))
				if (i % 50 == 0)
					sparseParabola add(FloatPoint2D new(i as Float / 20, (i as Float / 20) pow(2)))
			}
			randomGenerator free()

			// Simplest use-case with line plot
			logData := LinePlotData2D new(logVector, "log(x)")
			logPlot := SvgPlot new(logData, "Simplest use-case with line plot")

			// Simplest use-case with scatter plot
			scatterData := ScatterPlotData2D new(scatter, "Random numbers")
			scatterPlot := SvgPlot new(scatterData, "Simplest use-case with scatter plot")

			// Multiple shapes in one plot
			sinData := LinePlotData2D new(sinVector, "sin(x)")
			cosData := LinePlotData2D new(cosVector, "cos(x)")
			sinMinusCosData := LinePlotData2D new(sinMinusCos, "sin(x) - cos(x)")
			trigonometryPlot := SvgPlot new(sinData, "Multiple shapes in one plot")
			trigonometryPlot addDataset(cosData)
			trigonometryPlot addDataset(sinMinusCosData)
			trigonometryPlot xAxis label = "x"
			trigonometryPlot yAxis label = "y"

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
			symmetricUnitCircleData := LinePlotData2D new(unitCircle copy(), "Unit circle")
			symmetricUnitCirclePlot := SvgPlot new(symmetricUnitCircleData, "Unit circle plot with symmetic set to true")
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
			filename = filename >> "example.svg"
			writer := SvgWriter2D new(filename, logPlot)
			writer addPlot(scatterPlot)
			writer addPlot(trigonometryPlot)
			writer addPlot(unitCirclePlot)
			writer addPlot(symmetricUnitCirclePlot)
			writer addPlot(formatPlot)
			writer write()
			writer free()
		})
		this add("Output check", func {
			generated := t"test/plot/output/example.svg"
			comparison := t"test/plot/input/exampleComparison.svg"
			generatedFile := FileReader new(generated)
			comparisonFile := FileReader new(comparison)
			generatedBuffer := CharBuffer new()
			comparisonBuffer := CharBuffer new()

			while (generatedFile hasNext?() && comparisonFile hasNext?()) {
				generatedFile read(generatedBuffer)
				comparisonFile read(comparisonBuffer)
				expect(generatedBuffer == comparisonBuffer)
			}

			expect(generatedFile hasNext?(), is false)
			expect(comparisonFile hasNext?(), is false)

			generatedFile free()
			comparisonFile free()
		})
	}
}

SvgPlotTest new() run() . free()
