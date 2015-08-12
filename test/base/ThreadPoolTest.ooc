use ooc-base
import threading/Thread
import os/Time

version(debugTests) {
	threadedTest: func {
		pool := ThreadPool new()

		pool add(func { println("Job1"); for (i in 0 .. 1000000000) {} } )
		pool add(func { println("Job2"); for (i in 0 .. 1000000000) {} } )
		pool add(func { println("Job3"); for (i in 0 .. 1000000000) {} } )
		pool add(func { println("Job4"); for (i in 0 .. 1000000000) {} } )
		pool add(func { println("Job5"); for (i in 0 .. 1000000000) {} } )

		pool waitAll()
	}

	unthreadedTest: func {
		println("Job1"); for (i in 0 .. 1000000000) {}
		println("Job2"); for (i in 0 .. 1000000000) {}
		println("Job3"); for (i in 0 .. 1000000000) {}
		println("Job4"); for (i in 0 .. 1000000000) {}
		println("Job5"); for (i in 0 .. 1000000000) {}
	}

	durationThreaded := Time measure(|| threadedTest() )
	println("Duration threaded: " + durationThreaded toString())
	durationUnthreaded := Time measure(|| unthreadedTest() )
	println("Duration unthreaded: " + durationUnthreaded toString())
}
