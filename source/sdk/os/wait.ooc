version(unix || apple) {
	include sys/wait
}

WEXITSTATUS: extern func (Int) -> Int
WIFEXITED: extern func (Int) -> Int
WIFSIGNALED: extern func (Int) -> Int
WTERMSIG: extern func (Int) -> Int

wait: extern func (Int*) -> Int
waitpid: extern func (Int, Int*, Int) -> Int
