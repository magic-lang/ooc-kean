import ../[Thread], math, os/Time

include unistd

version(unix || apple) {
	ThreadUnix: class extends Thread {
		pthread: PThread

		init: func ~unix (=_code)
		start: func -> Bool {
			result := pthread_create(pthread&, null, _code as Closure thunk, _code as Closure context)
			(result == 0)
		}
		wait: func -> Bool {
			result := pthread_join(pthread, null)
			(result == 0)
		}
		wait: func ~timed (seconds: Double) -> Bool {
			result := false
			version (apple || android)
				result = __fake_timedjoin(seconds)
			else {
				ts: TimeSpec
				__setupTimeout(ts&, seconds)
				result = (pthread_timedjoin_np(pthread, null, ts&) == 0)
			}
			result
		}
		cancel: func -> Bool {
			result := false
			version (!android)
				result = this alive?() && (pthread_cancel(this pthread) == 0)
			result
		}
		alive?: func -> Bool {
			pthread_kill(pthread, 0) == 0
		}
		_currentThread: static func -> This {
			thread := This new(func)
			thread pthread = pthread_self()
			thread
		}
		_yield: static func -> Bool {
			// pthread_yield is non-standard, use sched_yield instead
			// as a bonus, this works on OSX too.
			result := sched_yield()
			(result == 0)
		}
		__setupTimeout: func (ts: TimeSpec@, seconds: Double) {
			// We need an absolute number of seconds since the epoch
			// First order of business - what time is it?
			tv: TimeVal
			gettimeofday(tv&, null)
			nowSeconds: Double = tv tv_sec as Double + tv tv_usec as Double / 1_000_000.0

			// Now compute the amount of seconds between January 1st, 1970 and the time
			// we will stop waiting on our thread
			absSeconds: Double = nowSeconds + seconds

			// And store it in a timespec, converting again...
			ts tv_sec = floor(absSeconds) as TimeT
			ts tv_nsec = ((absSeconds - ts tv_sec) * 1000 + 0.5) * (1_000_000 as Long)
		}
		__fake_timedjoin: func (seconds: Double) -> Bool {
			//TODO: This *is* fake, use WaitCondition instead
			result := false
			while (seconds > 0.0 && !result) {
				Time sleepMilli(20)
				seconds -= 0.02
				if (!alive?())
					result = true
			}
			result
		}
	}

	/* C interface */
	include pthread
	include sched

	PThread: cover from pthread_t
	TimeT: cover from time_t
	TimeSpec: cover from struct timespec {
		tv_sec: extern TimeT
		tv_nsec: extern Long
	}
	version (!apple && !android) {
		// Using proto here as defining '_GNU_SOURCE' seems to cause more trouble than anything else...
		pthread_timedjoin_np: extern proto func (thread: PThread, retval: Pointer, abstime: TimeSpec*) -> Int
	}

	pthread_create: extern func (threadPointer: PThread*, attributePointer, startRoutine, userArgument: Pointer) -> Int
	pthread_join: extern func (thread: PThread, retval: Pointer*) -> Int
	pthread_kill: extern func (thread: PThread, signal: Int) -> Int
	pthread_self: extern func -> PThread
	pthread_cancel: extern func (thread: PThread) -> Int
	sched_yield: extern func -> Int
}
