use ooc-base

b := ByteBuffer new(4000)
b decreaseReferenceCount()
b = ByteBuffer new(4000)
b decreaseReferenceCount()
ByteBuffer clean()
