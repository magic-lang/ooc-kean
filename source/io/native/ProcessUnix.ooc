/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import structs/HashMap
import os/[Env, wait, unistd]
import ../[Process, Pipe]
import PipeUnix

version(unix || apple) {
include errno, signal

errno : extern Int
SIGTERM: extern Int
SIGKILL: extern Int
SIGSEGV: extern Int
SIGABRT: extern Int

WNOHANG: extern Int

kill: extern func (Long, Int)
signal: extern func (Int, Pointer)

ProcessUnix: class extends Process {
	init: func ~unix (=args)

	terminate: override func {
		if (pid)
			kill(pid, SIGTERM)
	}

	kill: override func {
		if (pid)
			kill(pid, SIGKILL)
	}

	wait: override func -> Int {
		_wait(0)
	}

	waitNoHang: override func -> Int {
		_wait(WNOHANG)
	}

	_wait: func (options: Int) -> Int {
		status: Int
		result := -1

		waitpid(pid, status&, options)
		err := errno

		if (status == -1) {
			errString := strerror(err)
			Exception new("Process wait(): %s" format(errString toString())) throw()
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
				case =>
					// pffrt.
			}

			message = message + "\n"
			if (stdErr)
				stdErr write(message)
			else
				stderr write(message)
		}

		if (result != -1) {
			if (stdOut != null)
				stdOut close('w')
			if (stdErr != null)
				stdErr close('w')
		}

		result
	}

	executeNoWait: override func -> Long {
		pid = fork()
		if (pid == 0) {
			if (stdIn != null) {
				stdIn close('w')
				dup2(stdIn as PipeUnix readFD, 0)
			}
			if (stdOut != null) {
				stdOut close('r')
				dup2(stdOut as PipeUnix writeFD, 1)
			}
			if (stdErr != null) {
				stdErr close('r')
				dup2(stdErr as PipeUnix writeFD, 2)
			}

			/* amend the environment if needed */
			if (env)
				for (key in env keys)
					Env set(key, env[key], true)

			/* set a new cwd? */
			if (cwd != null)
				chdir(cwd as CString)

			/* run the stuff. */
			cArgs : CString * = calloc(args count + 1, Pointer size)
			for (i in 0 .. args count) {
				cArgs[i] = args[i] toCString()
			}
			cArgs[args count] = null // null-terminated - makes sense

			signal(SIGABRT, sigabrtHandler)

			execvp(cArgs[0], cArgs)
			exit(errno) // don't allow the forked process to continue if execvp fails
		}
		pid
	}

	sigabrtHandler: static func {
		"Got a sigabrt" println()
		exit(255)
	}
}
}
