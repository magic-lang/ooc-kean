/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import ../[Process, Pipe]
import PipeUnix

version(unix || apple) {
include sys/wait

WEXITSTATUS: extern func (Int) -> Int
WIFEXITED: extern func (Int) -> Int
WIFSIGNALED: extern func (Int) -> Int
WTERMSIG: extern func (Int) -> Int
WNOHANG: extern Int

kill: extern func (Long, Int)
signal: extern func (Int, Pointer)
wait: extern func (Int*) -> Int
waitpid: extern func (Int, Int*, Int) -> Int

ProcessUnix: class extends Process {
	init: func ~unix (=args)
	terminate: override func {
		if (this pid)
			kill(this pid, SIGTERM)
	}
	kill: override func {
		if (this pid)
			kill(this pid, SIGKILL)
	}
	wait: override func -> Int { this _wait(0) }
	waitNoHang: override func -> Int { this _wait(WNOHANG) }
	_wait: func (options: Int) -> Int {
		status: Int
		result := -1

		waitpid(this pid, status&, options)
		err := errno

		if (status == -1) {
			errString := strerror(err)
			Debug error("Process wait(): %s" format(errString toString()))
		}

		if (WIFEXITED(status))
			result = WEXITSTATUS(status)
		else if (WIFSIGNALED(status)) {
			termSig := WTERMSIG(status)
			message := "Child received signal %d" format(termSig)

			match termSig {
				case SIGSEGV =>
					message = message + " (Segmentation fault)"
				case SIGABRT =>
					message = message + " (Abort)"
			}

			message = message + "\n"
			if (this stdErr)
				this stdErr write(message)
			else
				stderr write(message)
		}

		if (result != -1) {
			if (this stdOut != null)
				this stdOut close('w')
			if (this stdErr != null)
				this stdErr close('w')
		}

		result
	}
	executeNoWait: override func -> Long {
		this pid = fork()
		if (this pid == 0) {
			if (this stdIn != null) {
				this stdIn close('w')
				dup2(this stdIn as PipeUnix readFD, 0)
			}
			if (this stdOut != null) {
				this stdOut close('r')
				dup2(this stdOut as PipeUnix writeFD, 1)
			}
			if (this stdErr != null) {
				this stdErr close('r')
				dup2(this stdErr as PipeUnix writeFD, 2)
			}

			envSetFunc := func (key, value: String*) { Env set(key@, value@, true) }
			if (this env)
				this env each(envSetFunc)
			(envSetFunc as Closure) free()

			if (this cwd != null)
				chdir(this cwd as CString)

			cArgs: CString* = calloc(this args count + 1, Pointer size)
			for (i in 0 .. this args count)
				cArgs[i] = this args[i] toCString()
			cArgs[this args count] = null

			signal(SIGABRT, sigabrtHandler)

			execvp(cArgs[0], cArgs)
			exit(errno) // don't allow the forked process to continue if execvp fails
		}
		this pid
	}
	sigabrtHandler: static func {
		"Got a sigabrt" println()
		exit(255)
	}
}
}
