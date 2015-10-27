use ooc-base
use ooc-unit
use ooc-math
import math

OwnedBufferTest: class extends Fixture {
	init: func {
		super("OwnedBuffer")
		this add("constructor static", func {
			t := OwnedBuffer new(c"test" as UInt8*, 4, Owner Static)
			expect(t size, is equal to(4))
			expect(t owner == Owner Static)
			t free()
			expect(t pointer == null)
			expect(t size, is equal to(0))
			expect(t owner == Owner Unknown)
		})
		this add("constructor allocate", func {
			t := OwnedBuffer new(4)
			expect(t size, is equal to(4))
			expect(t owner == Owner Receiver)
			t free()
			expect(t pointer == null)
			expect(t size, is equal to(0))
			expect(t owner == Owner Unknown)
		})
		this add("sender free", func {
			t := OwnedBuffer new(4)
			p := t pointer
			expect(t size, is equal to(4))
			expect(t owner == Owner Receiver)
			expect(t free(Owner Sender), is false)
			expect(t pointer == p)
			expect(t size, is equal to(4))
			expect(t owner == Owner Receiver)
			t = t take()
			expect(t pointer == p)
			expect(t size, is equal to(4))
			expect(t owner == Owner Sender)
			expect(t free(Owner Sender))
			expect(t pointer == null)
			expect(t size, is equal to(0))
			expect(t owner == Owner Unknown)
		})
		this add("take", func {
			t := OwnedBuffer new(4)
			p := t pointer
			expect(t size, is equal to(4))
			expect(t owner == Owner Receiver)
			t = t take()
			expect(t pointer == p)
			expect(t size, is equal to(4))
			expect(t owner == Owner Sender)
			expect(t free(Owner Receiver), is false)
			t = t give()
			expect(t pointer == p)
			expect(t size, is equal to(4))
			expect(t owner == Owner Receiver)
			expect(t free(Owner Receiver))
			expect(t pointer == null)
			expect(t size, is equal to(0))
			expect(t owner == Owner Unknown)
		})
		this add("copy", func {
			t := OwnedBuffer new(4)
			p := t pointer
			expect(t size, is equal to(4))
			expect(t owner == Owner Receiver)
			t = t take()
			expect(t owner == Owner Sender)
			s := t copy()
			expect(t pointer == p)
			expect(t size, is equal to(4))
			expect(t owner == Owner Sender)
			expect(t free())
			expect(t pointer == null)
			expect(t size, is equal to(0))
			expect(t owner == Owner Unknown)

			expect(s pointer != p)
			expect(s size, is equal to(4))
			expect(s owner == Owner Receiver)
			expect(s free())
			expect(s pointer == null)
			expect(s size, is equal to(0))
			expect(s owner == Owner Unknown)
		})
	}
}

OwnedBufferTest new() run()
