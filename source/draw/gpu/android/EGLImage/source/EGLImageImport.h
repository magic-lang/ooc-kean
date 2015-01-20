#ifndef EGLIMAGEIMPORT_H_
extern int createEGLImage(int width, int height, void* display, int write);
extern void destroyEGLImage(int index);
extern void unlockPixels(int index);
extern int getStride(int index);
extern void destroyAll();
extern void* readPixels(int index);
extern void* writePixels(int index);
#endif /* EGLIMAGEIMPORT_H_ */
