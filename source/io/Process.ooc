/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Pipe
import structs/HashMap
import native/[ProcessUnix, ProcessWin32]

Process: abstract class {
	// The first argument should be the path to the executable.
	args: VectorList<String>

	// Pipe to which standard output will be redirected if it's non-null
	stdOut = null: Pipe
	// Pipe to which standard input will be redirected if it's non-null
	stdIn = null: Pipe
	// Pipe to which standard error will be redirected if it's non-null
	stdErr = null: Pipe

	// Environment variables that should be defined for the launched process
	env = null : HashMap<String, String>

	// Current working directory of the launched process
	cwd = null : String

	// PID of the child process
	pid = 0: Long

	/** Terminate the child process with a SIGTERM signal */
	terminate: abstract func

	/** Terminate the child process with a SIGKILL signal. Like `terminate`, but more violent. */
	kill: abstract func

	setStdout: func (=stdOut)
	setStdin: func (=stdIn)
	setStderr: func (=stdErr)

	setEnv: func (=env)
	setCwd: func (=cwd)

	execute: func -> Int {
		executeNoWait()
		wait()
	}

	// Bad things will happen if you haven't called `executeNoWait` before.
	wait: abstract func -> Int

	// Returns exit code, or -1 if process hasn't exited yet.
	waitNoHang: abstract func -> Int

	executeNoWait: abstract func -> Long

	// Execute the process, and return all the output to stdout as a string
	getOutput: func -> (String, Int) {
		stdOut = Pipe new()
		exitCode := execute()

		result := PipeReader new(stdOut) readAll()

		stdOut close()
		stdOut = null

		(result, exitCode)
	}

	// Execute the process, and return all the output to stderr as a string
	getErrOutput: func -> (String, Int) {
		stdErr = Pipe new()
		exitCode := execute()

		result := PipeReader new(stdErr) readAll()

		stdErr close()
		stdErr = null

		(result, exitCode)
	}

	// Returns a representation of the command, escaped to some point.
	getCommandLine: func -> String {
		result := args[0]
		for (i in 1 .. args count)
			result = " " >> (result >> args[i])
		result = result replaceAll("\\", "\\\\")
	}
	new: static func ~fromArray (args: String[]) -> This {
		p := VectorList<String> new(args length, false)
		for (i in 0 .. args length) {
			arg := args[i]
			p add(arg)
		}
		new(p)
	}

	new: static func (.args) -> This {
		result: This = null
		version(unix || apple)
			result = ProcessUnix new(args) as This
		version(windows)
			result = ProcessWin32 new(args) as This
		if (result == null)
			Exception new(This, "os/Process is unsupported on your platform!") throw()
		result
	}

	new: static func ~withEnvFromArray (args: String[], .env) -> This {
		p := new(args)
		p env = env
		p
	}

	new: static func ~withEnv (.args, .env) -> This {
		p := new(args)
		p env = env
		p
	}
}

ProcessException: class extends Exception {
	init: super func
}

BadExecutableException: class extends ProcessException {
	init: super func
}
