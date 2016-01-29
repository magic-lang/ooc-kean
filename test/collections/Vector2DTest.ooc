/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use collections

Vector2DTest: class extends Fixture {
	init: func {
		sizeXS := 3
		sizeS := 5
		sizeM := 10
		sizeL := 15
		sizeXL := 20
		vector2D := Vector2D<Int> new(sizeM, sizeM)
		super("Vector2D")
		this add("count", func {
			expect(vector2D rowCount, is equal to(sizeM))
			expect(vector2D columnCount, is equal to(sizeM))
		})
		this add("get and set operators", func {
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(0))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * vector2D columnCount + column
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(row * vector2D columnCount + column))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = sizeM
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(sizeM))
		})
		this add("resize increase size", func {
			vector2D resize(sizeXL, sizeXL)
			expect(vector2D rowCount, is equal to(sizeXL))
			expect(vector2D columnCount, is equal to(sizeXL))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * vector2D columnCount + column
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(row * sizeXL + column))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = sizeXL
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(sizeXL))
		})
		this add("resize decrease size", func {
			vector2D resize(sizeM, sizeM)
			expect(vector2D rowCount, is equal to(sizeM))
			expect(vector2D columnCount, is equal to(sizeM))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(sizeXL))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = sizeL
		})
		this add("resize to non-square", func {
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * vector2D columnCount + column
			vector2D resize(sizeS, sizeL)
			expect(vector2D rowCount, is equal to(sizeS))
			expect(vector2D columnCount, is equal to(sizeL))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. sizeM)
					expect(vector2D[row, column], is equal to(row * sizeM + column))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * vector2D columnCount + column
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(row * vector2D columnCount + column))
		})
		this add("move", func {
			moveStepSize := 1
			vector2D resize(sizeXS, sizeXS)
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * column
			oldValues := Vector2D<Int> new(vector2D rowCount - moveStepSize, vector2D columnCount - moveStepSize)
			for (row in 0 .. oldValues rowCount)
				for (column in 0 .. oldValues columnCount)
					oldValues[row, column] = vector2D[row + moveStepSize, column + moveStepSize]
			vector2D move(moveStepSize, moveStepSize, 0, 0)
			for (row in 0 .. vector2D rowCount - moveStepSize)
				for (column in 0 .. vector2D columnCount - moveStepSize)
					expect(vector2D[row, column], is equal to(oldValues[row, column]))
			vector2D resize(sizeL, sizeL)
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * column
			vector2D resize(sizeXL, sizeXL)
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D move(row, row, row + 1, row + 1)
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(0))
		})
	}
}

Vector2DTest new() run() . free()
