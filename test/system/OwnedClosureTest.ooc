/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit

MyClass: class {
	content: Int { get set }
	init: func { this content = 0 }
	apply: func (action: Func (This)) {
		action(this)
		(action as Closure) free(Owner Receiver)
	}
}

OwnedClosureTest: class extends Fixture {
	init: func {
		super("OwnedClosure")
		adder1 := 1
		adder2 := 2
		adder3 := 3
		function1 := func (instance: MyClass) {
			instance content += adder1
			instance content += adder2
			instance content += adder3
		}
		function2 := func (instance: MyClass) {
			instance content += adder1
			instance content += adder2
			instance content += adder3
		}
		this add("Owner Sender", func {
			f := function1 as Closure
			instance := MyClass new()
			expect(f owner == Owner Receiver)
			f = f take()
			expect(f owner == Owner Sender)
			instance apply(f as Func(MyClass))
			(f as Func(MyClass))(instance)
			f free(Owner Sender)
			expect(instance content, is equal to(12))
			instance free()
		})
		this add("Owner Receiver", func {
			f := function2 as Closure
			instance := MyClass new()
			expect(f owner == Owner Receiver)
			f = f give()
			f free(Owner Sender)
			expect(f owner == Owner Receiver)
			(f as Func(MyClass))(instance)
			instance apply(f as Func(MyClass))
			expect(instance content, is equal to(12))
			instance free()
		})
	}
}

OwnedClosureTest new() run() . free()
