# ooc-kean changes by release

## Release 2.11.0

- **Changes to support new rock version**
- **VectorList now resizes exponentially instead of linearly**
- **Bugfixes and better error checking in draw and OpenGL namespaces**
- **Made it possible to draw text on the CPU**

## Release 2.10.0

- **Various minor bugfixes to draw and system namespaces**
- **Profiler uses TimeSpan**
- **Using Debug error() instead of raise() in most places**

## Release  2.9.0

- **Added support for utilizing YUV extension in OpenGL**
- **Fixed memory leaks in debugGL printouts**
- **Added some new promises**

## Release  2.8.0

- **Standardized the existence of methods and properties in Vector and Point covers**
- **Normalizing the zero vector returns a zero vector instead of NaN values**
- **Bilinear interpolation added to ColorUv and ColorMonochrome**

## Release  2.7.0

- **Added function for checking if value is inside a certain range in TimeSpan.**

## Release  2.6.0

- **Text completely removed in favor of String**
- **Fixed various thread-related bugs and race conditions**
- **Removed Synchronized class**
- **Added support for C11 atomics**
- **The -Ddeterministic flag automatically sets the random generator seeds to fixed values**

## Release-2.5.0

- **Bug fixes in ReferenceCounter**
- **toString() now takes number of decimals as argument**

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
