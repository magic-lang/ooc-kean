# ooc-kean changes by release

## Release-2.4.0

- **Fixed bug with multiple freeing of string literals**

- **Implemented SortedVectorList**

- **Major cleanup of draw namespace**

- **Added function for removing range of values in a VectorList**

- **Refactored Promise/Future**

- **Added preallocate and preregister functions to GpuContext**

- **Now using correct usage flags when uploading and downloading from GraphicBuffer**

## Release-2.3.0

- **Large clean up in draw module**
Major clean up of how the draw API works internally. Coordinate systems are replaced with flipping in DrawState. Added support for alpha blending.

- **HashMap and LinkedList are working**
LinkedList does not contain memory leaks anymore and a new (and working) implementation of HashMap has been written.

- **No more memory leaks in tests**
All the earlier memory leaks in all the tests have now been fixed and at the moment we do not have any memory leaks in the tests.

- **PromiseCollector and SynchronizedResource deleted**
We removed PromiseCollector and SynchronizedResource because they did no longer fill any purpose.
