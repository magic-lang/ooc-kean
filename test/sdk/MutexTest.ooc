import threading/Thread

for (i in 0..10) {
	m := Mutex new()
	m lock()
	m unlock()
	m destroy()
}
