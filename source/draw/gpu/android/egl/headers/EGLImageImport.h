#ifndef EGLIMAGEIMPORT_H_
extern int createEGLImage(int width, int height, void* display);
extern void destroyEGLImage(int index);
extern void* lockPixels(int index);
extern void unlockPixels(int index);
extern int getStride(int index);
extern void destroyAll();
#endif /* EGLIMAGEIMPORT_H_ */
