# Draw API

## Image
An image is responsible for storing an array of pixels in 2 or 3 dimensions on CPU or GPU.

## Canvas
An abstraction layer for drawing that is responsible for portability between underlaying versions of OpenGL using class inheritance.

## Target
The target is the image being drawn to. The same image cannot be both input and output to the same draw call because of hardware limitations on some graphics cards.

## Viewport
The viewport is the sub region of the target image that is using the whole image by default. This can be set to a smaller region to store multiple images in an atlas.

No pixels will be drawn outside of the viewport. If you apply a transform, it will be centered to the viewport and any pixel leaving the area will be clipped by the viewport.

## Destination
The destination is similar to the viewport by defining where to draw. The difference is how they work together with the transform. Viewport is deciding the center of the transform and where to clip with a default viewport. The transform will be centered around the whole target image instead of being centered around the destination. The destination may leave its original location using a transform. The destination is just a way to shrink the drawn quad shape.

## Transform
Transform is the inverse camera matrix applied after the destination scaling.

## Source
The source is a subregion of the input image affecting generation of texture coordinates in the shader.

## Opacity
Opacity sets the amount of the new color to use. Values lower than 1.0 will also show the previous colors on the image.

## Coordinate systems for regions
Image regions go from zero in the upper left corner and increase with either pixels or pixels divided by size.

* **Local regions** goes from the upper left corner and increase in pixels. X goes right and Y goes down.

* **Normalized regions** go from (0, 0) in the upper left corner to (+1, +1) in the bottom right corner. This allows using the same coordinates for multiple image resolutions. This is the normalized version of local coordinates for subsets of images because the conversion is easy to understand as a simple multiplication.

## Coordinate systems for transforms
Transforms go from zero in the center and increase with either pixels or pixels divided by size.

* **Reference transforms** start from the center of the image and increase in pixels. X goes right and Y goes down. This allows applying rotations with automatic compensation for aspect ratio and preserving pixel density when cropping images.

* **Normalized transforms** start from the center of the image and go from (-1, -1) in the top left corner to (+1, +1) in the bottom right corner. This allows using the same coordinates for multiple image resolutions. The disadvantage is that it does not preserve aspect ratio when rotating since it treats all images as squares when not knowing their size. This is the normalized version of reference coordinates.

# DrawState
Using `DrawState` you can draw things without having to call the canvas directly.
This is convenient if you have a lot of things to draw that have settings in common.

## Availability of settings
Using destination or transform on the CPU would require a rewrite of legacy draw calls.

| setting | draw(gpu) | draw(cpu) | write |
|-|-|-|-|
| target | X | X | X |
| inputImage | X | X | X |
| viewport | X | X |  |
| source | X | X |  |
| destination | X |  |  |
| transform | X |  |  |
| focalLength | X |  |  |
| map | X |  |  |
| mesh | X |  |  |
| opacity | X |  |  |
| blendMode | X |  |  |
| interpolate |  | X |  |
| origin |  |  | X |

## How to use
Create a `DrawState` with a target image as input argument.
Continue with setters to add information.
The setters leave no side-effects but return a clone of the state with the setting changed.
```ooc
DrawState new(target) setMap(shader) draw()
```
You can also leave it empty but then you have to call `setTarget` later.
```ooc
state := DrawState new() setMap(shader)
state setTarget(target) draw()
```
Cloning of the `DrawState` can be used to share common settings.
```ooc
state := DrawState new() setMap(shader) setTransformNormalized(transform)
state setTarget(smallTarget) draw()
state setTarget(largeTarget) draw()
```

## Debug checklist for things we have not yet implemented safety for
* If the application is crashing.
	Did you forget to bind a texture to the correct name?

* If you see random images, funky colors, moving clouds or tunnels.
	Did you forget to bind a texture to the correct name?
	Did you forget `draw()` at the end?

* If the input image has sharp square pixels.
	Did you forget to turn on interpolated sampling?
	This is unsafe because of the poor design of OpenGL that makes it hard to make a decent interface.
