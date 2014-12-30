use ooc-base

b := ByteBuffer new(4000)
b referenceCount decrease()
b = ByteBuffer new(4000)
b referenceCount decrease()
ByteBuffer clean()
