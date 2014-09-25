#ifndef EGLIMAGEIMPORT_H_
extern int createEGLImage(void* display);
extern void destroyEGLImage(int index);
extern void* lockPixels(int index);
extern void unlockPixels(int index);
#endif /* EGLIMAGEIMPORT_H_ */
