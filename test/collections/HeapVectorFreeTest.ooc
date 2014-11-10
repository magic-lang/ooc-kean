
use ooc-collections
use ooc-math

for (i in 0..1) {

	/*heapVector := HeapVector<Dictionary> new(100) as Vector<Dictionary>
	for (i in 0..32) {
		dict := Dictionary new()
		dict add(0, Cell new(FloatTransform2D identity))
		dict add(1, Cell new(FloatTransform2D identity))
		dict add(2, Cell new(FloatTransform2D identity))
		heapVector[i] = dict
	}*/

	vectorList := VectorList<Dictionary> new() as VectorList<Dictionary>

	for (i in 0..10) {
		dict := Dictionary new()
		dict add(0, Cell new(FloatTransform2D identity))
		dict add(1, Cell new(FloatTransform2D identity))
		dict add(2, Cell new(FloatTransform2D identity))
		vectorList add(dict)
	}

	//heapVector free()
	vectorList free()
	for (i in 0..10) {
		//gc_free(vectorList[i] )
	}

}
