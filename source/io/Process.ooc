/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import Pipe
import native/[ProcessUnix, ProcessWin32]

Process: abstract class {
	args: VectorList<String> // The first argument should be the path to the executable
	stdOut = null: Pipe
	stdIn = null: Pipe
	stdErr = null: Pipe
	env = null: HashMap<String, String> // Environment variables that should be defined for the launched process
	cwd = null: String
	pid = 0: Long

	free: override func {
		this args free()
		super()
	}
	terminate: abstract func // Terminate with SIGTERM
	kill: abstract func // Terminate with SIGKILL
	setStdout: func (=stdOut)
	setStdin: func (=stdIn)
	setStderr: func (=stdErr)
	setEnv: func (=env)
	setCwd: func (=cwd)
	wait: abstract func -> Int // Must call executeNoWait before
	waitNoHang: abstract func -> Int
	executeNoWait: abstract func -> Long
	execute: func -> Int {
		this executeNoWait()
		this wait()
	}
	getOutput: func -> (String, Int) {
		this stdOut = Pipe new()
		exitCode := this execute()
		result := PipeReader new(this stdOut) readAll()
		this stdOut free()
		this stdOut = null
		(result, exitCode)
	}
	getErrOutput: func -> (String, Int) {
		this stdErr = Pipe new()
		exitCode := this execute()
		result := PipeReader new(this stdErr) readAll()
		this stdErr free()
		this stdErr = null
		(result, exitCode)
	}
	// Returns a representation of the command, escaped to some point.
	getCommandLine: func -> String {
		result := this args[0]
		for (i in 1 .. this args count)
			result = " " >> (result >> this args[i])
		result = result replaceAll("\\", "\\\\")
	}
	new: static func ~fromArray (args: String[]) -> This {
		p := VectorList<String> new(args length, false)
		for (i in 0 .. args length) {
			arg := args[i]
			p add(arg)
		}
		This new(p)
	}
	new: static func (.args) -> This {
		result: This = null
		version(unix || apple)
			result = ProcessUnix new(args) as This
		version(windows)
			result = ProcessWin32 new(args) as This
		if (result == null)
			Debug error("os/Process is unsupported on your platform!")
		result
	}
	new: static func ~withEnvFromArray (args: String[], .env) -> This {
		p := This new(args)
		p env = env
		p
	}
	new: static func ~withEnv (.args, .env) -> This {
		p := This new(args)
		p env = env
		p
	}
}
