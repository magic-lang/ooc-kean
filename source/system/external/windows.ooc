/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(windows) {
include stdint
include windows | (NOMINMAX, _WIN32_WINNT=0x0500)

COMPUTER_NAME_FORMAT: enum {
	NET_BIOS = 0
	DNS_HOSTNAME
	DNS_DOMAIN
	DNS_FULLY_QUALIFIED
	PHYSICAL_NET_BIOS
	PHYSICAL_DNS_HOSTNAME
	PHYSICAL_DNS_DOMAIN
	PHYSICAL_DNS_FULLY_QUALIFIED
	MAX
}

ERROR_HANDLE_EOF: extern Int
FORMAT_MESSAGE_FROM_SYSTEM: extern Long
FORMAT_MESSAGE_IGNORE_INSERTS: extern Long
FORMAT_MESSAGE_ARGUMENT_ARRAY: extern Long
WaitSuccess: extern (WAIT_OBJECT_0) Long
INFINITE: extern Long
WAIT_OBJECT_0: extern Long
WAIT_TIMEOUT: extern Long
PIPE_WAIT, PIPE_NOWAIT: extern ULong
ERROR_NO_DATA: extern Long
HANDLE_FLAG_PROTECT_FROM_CLOSE: extern Long
WAIT_ABANDONED, WAIT_OBJECT_0, WAIT_TIMEOUT, WAIT_FAILED: extern Int
HANDLE_FLAG_INHERIT: extern Long
PATHCCH_MAX_CCH: extern SizeT
LOCALE_USER_DEFAULT: extern LocaleId

COLOR_WINDOW, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, WM_CLOSE, WM_DESTROY, WM_QUIT, WS_EX_CLIENTEDGE, SW_SHOWDEFAULT, SRCCOPY: extern Int
IDC_ARROW, IDI_APPLICATION: extern LPSTR
PM_REMOVE: extern UInt

BYTE: extern cover from Byte
WORD: extern cover from Int
DWORD: extern cover from UInt
LPTSTR: extern cover from CString
MAKEWORD: extern func (low, high: BYTE) -> WORD
LocaleId: cover from LCID
Handle: cover from HANDLE
INVALID_HANDLE_VALUE: extern Handle
EXCEPTION_EXECUTE_HANDLER: extern Int

EXCEPTION_ACCESS_VIOLATION, EXCEPTION_ARRAY_BOUNDS_EXCEEDED,
EXCEPTION_BREAKPOINT, EXCEPTION_DATATYPE_MISALIGNMENT,
EXCEPTION_FLT_DENORMAL_OPERAND, EXCEPTION_FLT_DIVIDE_BY_ZERO,
EXCEPTION_FLT_INEXACT_RESULT, EXCEPTION_FLT_INVALID_OPERATION,
EXCEPTION_FLT_OVERFLOW, EXCEPTION_FLT_STACK_CHECK, EXCEPTION_FLT_UNDERFLOW,
EXCEPTION_ILLEGAL_INSTRUCTION, EXCEPTION_IN_PAGE_ERROR,
EXCEPTION_INT_DIVIDE_BY_ZERO, EXCEPTION_INT_OVERFLOW,
EXCEPTION_INVALID_DISPOSITION, EXCEPTION_NONCONTINUABLE_EXCEPTION,
EXCEPTION_PRIV_INSTRUCTION, EXCEPTION_SINGLE_STEP,
EXCEPTION_STACK_OVERFLOW: extern DWORD

FILE_ATTRIBUTE_DIRECTORY,
FILE_ATTRIBUTE_REPARSE_POINT,
FILE_ATTRIBUTE_NORMAL,
INVALID_FILE_ATTRIBUTES: extern Long

LPSTR: cover from Char*
LPMSG: cover from Msg*
LPARAM: cover from Long*
LRESULT: cover from Long*
WPARAM: cover from UInt*
HINSTANCE: cover from Void*
HBRUSH: cover from Void*
HWND: cover from Void*
HMENU: cover from Void*
LPVOID: cover from Void*
HICON: cover from Void*
HCURSOR: cover from Void*
HBITMAP: cover from Void*
HDC: cover from Void*
HGDIOBJ: cover from Void*

PaintStruct: cover from PAINTSTRUCT
Point: cover from POINT
Rect: cover from RECT

Msg: cover from MSG {
	hwnd: extern HWND
	message: extern UInt
	wParam: extern WPARAM
	lParam: extern LPARAM
	time: extern Int
	pt: extern Point
}

WndClassEXA: cover from WNDCLASSEXA {
	cbSize, style: extern UInt
	lpfnWndProc: extern Pointer
	cbClsExtra, cbWndExtra: extern Int
	hInstance: extern HINSTANCE
	hIcon, hIconSm: extern HICON
	hCursor: extern HCURSOR
	hbrBackground: extern HBRUSH
	lpszMenuName, lpszClassName: extern LPSTR
}

Bitmap: cover from BITMAP {
	bmType, bmWidth, bmHeight, bmWidthBytes: extern Long
	bmPlanes, bmBitsPixel: extern Short
	bmBits: extern LPVOID
}

SystemInfo: cover from SYSTEM_INFO {
	numberOfProcessors: extern (dwNumberOfProcessors) UInt
}

LargeInteger: cover from LARGE_INTEGER {
	lowPart: extern (LowPart) Long
	highPart: extern (HighPart) Long
	quadPart: extern (QuadPart) LLong
}

ULargeInteger: cover from ULARGE_INTEGER {
	lowPart: extern (LowPart) Long
	highPart: extern (HighPart) Long
	quadPart: extern (QuadPart) LLong
}

SecurityAttributes: cover from SECURITY_ATTRIBUTES {
	length: extern (nLength) Int
	inheritHandle: extern (bInheritHandle) Bool
	securityDescriptor: extern (lpSecurityDescriptor) Pointer
}

EXCEPTION_POINTERS: extern cover {
		ExceptionRecord: EXCEPTION_RECORD*
		ContextRecord: CONTEXT*
	}

CONTEXT: extern cover
HModule: cover from HMODULE

EXCEPTION_RECORD: extern cover {
	ExceptionCode: DWORD
}

FindData: cover from WIN32_FIND_DATA {
	attr: extern (dwFileAttributes) Long // DWORD
	fileSizeLow: extern (nFileSizeLow) Long // DWORD
	fileSizeHigh: extern (nFileSizeHigh) Long // DWORD
	creationTime: extern (ftCreationTime) FileTime
	lastAccessTime: extern (ftLastAccessTime) FileTime
	lastWriteTime: extern (ftLastWriteTime) FileTime
	fileName: extern (cFileName) CString
}

StartupInfo: cover from STARTUPINFO {
	structSize: extern (cb) Long
	reserved: extern (lpReserved) CString*
	desktop: extern (lpDesktop) CString*
	title: extern (lpTitle) CString*
	x: extern (dwX) Long
	y: extern (dwY) Long
	xSize: extern (dwXSize) Long
	ySize: extern (dwYSize) Long
	xCountChars: extern (dwXCountChars) Long
	yCountChars: extern (dwYCountChars) Long
	flags: extern (dwFlags) Long
	showWindow: extern (wShowWindow) Int
	cbReserved2: extern Int
	lpReserved2: extern Char* // LPBYTE
	stdInput : extern (hStdInput) Handle
	stdOutput: extern (hStdOutput) Handle
	stdError : extern (hStdError) Handle
}

StartFlags: cover {
	ForceOnFeedback : extern (STARTF_FORCEONFEEDBACK) static Long
	ForceOffFeedback: extern (STARTF_FORCEOFFFEEDBACK) static Long
	PreventPinning : extern (STARTF_PREVENTPINNING) static Long
	RunFullScreen: extern (STARTF_RUNFULLSCREEN) static Long
	TitleIsAppID: extern (STARTF_TITLEISAPPID) static Long
	TitleIsLinkName: extern (STARTF_TITLEISLINKNAME) static Long
	UseCountChars: extern (STARTF_USECOUNTCHARS) static Long
	UseFillAttribute: extern (STARTF_USEFILLATTRIBUTE) static Long
	UseHotKey: extern (STARTF_USEHOTKEY) static Long
	UsePosition: extern (STARTF_USEPOSITION) static Long
	UseShowWindow: extern (STARTF_USESHOWWINDOW) static Long
	UseSize: extern (STARTF_USESIZE) static Long
	UseStdHandles: extern (STARTF_USESTDHANDLES) static Long
}

ProcessInformation: cover from PROCESS_INFORMATION {
	process: extern (hProcess) Handle
	thread: extern (hThread) Handle
	pid: extern (dwProcessId) Long
}

SystemTime: cover from SYSTEMTIME {
	wYear, wMonth, wDayOfWeek, wDay, wHour, wMinute, wSecond, wMilliseconds: extern UShort
}

WindowsException: class extends Exception {
	init: func (.origin, err: Long) { super(origin, GetWindowsErrorMessage(err)) }
	init: func ~withMsg (.origin, err: Long, message: String) { super(origin, "%s: %s" format(message, GetWindowsErrorMessage(err))) }
}

/* Functions used for register, creating and handling a window */
LoadIcon: extern func (hInstance: HINSTANCE, lpIconName: LPSTR) -> HICON
LoadCursor: extern func (hInstance: HINSTANCE, lpCursorName: LPSTR) -> HCURSOR
RegisterClassEx: extern func (WndClassEXA*) -> Bool
CreateWindowEx: extern func (dwExStyle: Int, lpClassName, lpWindowName: LPSTR, dwStyle, X, Y, nWidth, nHeight: Int, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID) -> HWND
ShowWindow: extern func (hWnd: HWND, nCmdShow: Int) -> Bool
UpdateWindow: extern func (hWnd: HWND) -> Bool
DestroyWindow: extern func (hWnd: HWND) -> Bool
PostQuitMessage: extern func (nExitCode: Int)
DefWindowProc: extern func (hWnd: HWND, Msg: UInt, wParam: WPARAM, lParam: LPARAM) -> LRESULT
PeekMessage: extern func (lpMsg: LPMSG, hWnd: HWND, WMsgFilterMin, wMsgFilterMax: UInt, wRemoveMsg: UInt) -> Bool
TranslateMessage: extern func (lpMsg: Msg*) -> Bool
DispatchMessage: extern func (lpMsg: Msg*) -> LRESULT
GetModuleHandle: extern func (lpModuleName: LPSTR) -> HINSTANCE

/* Functions used for drawing on a window */
CreateBitmap: extern func (nWidth, nHeight: Int, cPlanes, cBitsPerPel: UInt, lpvBits: LPVOID) -> HBITMAP
BeginPaint: extern func (hwnd: HWND, lpPaint: PaintStruct*) -> HDC
CreateCompatibleDC: extern func (hdc: HDC) -> HDC
SelectObject: extern func (hdc: HDC, hgdiobj: HGDIOBJ) -> HGDIOBJ
GetObject: extern func (hgdiobj: HGDIOBJ, cbBuffer: Int, lpvObject: LPVOID) -> Int
BitBlt: extern func (hdcDest: HDC, nXDest, nYDest, nWidth, nHeight: Int, hdcSrc: HDC, nXSrc, nYSrc, dwRop: Int)
DeleteDC: extern func (hdcMem: HDC) -> Bool
EndPaint: extern func (hwnd: HWND, ps: PaintStruct*) -> Bool
InvalidateRect: extern func (hwnd: HWND, lpRect: Rect*, bErase: Bool) -> Bool

CreateMutex: extern func (Pointer, Bool, Pointer) -> Handle
ReleaseMutex: extern func (Handle)
WaitForSingleObject: extern func (...) -> Long

LoadLibraryA: extern func (path: CString) -> HModule
GetProcAddress: extern func (module: HModule, name: CString) -> Pointer
FreeLibrary: extern func (module: HModule) -> Bool

GetTimeFormat: extern func (LocaleId, Long, SystemTime*, CString, CString, Int) -> Int
GetDateFormat: extern func (LocaleId, Long, SystemTime*, CString, CString, Int) -> Int
GetLocalTime: extern func (SystemTime*)
QueryPerformanceCounter: extern func (LargeInteger*)
QueryPerformanceFrequency: extern func (LargeInteger*)
Sleep: extern func (UInt)

GetLastError: extern func -> Int
FormatMessage: extern func (dwFlags: DWORD, lpSource: Pointer, dwMessageId: DWORD, dwLanguageId: DWORD, lpBuffer: LPTSTR, nSize: DWORD, ...) -> DWORD
GetSystemInfo: extern func (SystemInfo*)
GetComputerNameEx: extern func (COMPUTER_NAME_FORMAT, CString, UInt*)
CreateEvent: extern func (...) -> Handle
SetEvent: extern func (Handle) -> Bool

_beginthreadex: extern func (security: Pointer, stackSize: UInt, startAddress, arglist: Pointer, initflag: UInt, thrdaddr: UInt*) -> Handle
GetCurrentThread: extern func -> Handle
GetCurrentThreadId: extern func -> UInt
SwitchToThread: extern func -> Bool
TerminateThread: extern func (...) -> Bool

CreatePipe: extern func (readPipe: Handle*, writePipe: Handle*, lpPipeAttributes: Pointer, nSize: Long) -> Bool
ReadFile: extern func (hFile: Handle, buffer: Pointer, numberOfBytesToRead: Long, numberOfBytesRead: Long*, lpOverlapped: Pointer) -> Bool
WriteFile: extern func (hFile: Handle, buffer: Pointer, numberOfBytesToWrite: Long, numberOfBytesWritten: Long*, lpOverlapped: Pointer) -> Bool
CloseHandle: extern func (handle: Handle) -> Bool
SetNamedPipeHandleState: extern func (handle: Handle, mode: Long*, maxCollectionCount: Long*, collectDataTimeout: Long*)

ZeroMemory: extern func (Pointer, SizeT)
CreateProcess: extern func (CString, CString, Pointer, Pointer, Bool, Long, Pointer, CString, Pointer, Pointer) -> Bool
GetExitCodeProcess: extern func (Handle, ULong*) -> Int
SetHandleInformation: extern func (Handle, Long, Long) -> Bool

DebugBreak: extern func
RaiseException: extern func (ULong, ULong, ULong, Pointer)
IsDebuggerPresent: extern func -> Pointer
SetUnhandledExceptionFilter: extern func (handler: Pointer) -> Pointer

FindFirstFile: extern (FindFirstFileA) func (CString, FindData*) -> Handle
FindNextFile: extern func (Handle, FindData*) -> Bool
FindClose: extern func (Handle)
GetFileAttributes: extern func (CString) -> ULong
CreateDirectory: extern func (CString, Pointer) -> Bool
GetCurrentDirectory: extern func (ULong, Pointer) -> Int
GetFullPathName: extern func (CString, ULong, CString, CString) -> ULong
GetLongPathName: extern func (CString, CString, ULong) -> ULong
DeleteFile: extern func (CString) -> Bool
RemoveDirectory: extern func (CString) -> Bool

GetWindowsErrorMessage: func (err: DWORD) -> String {
	BUF_SIZE := 256
	buf := CharBuffer new(BUF_SIZE)
	len: SSizeT = FormatMessage(
		FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_ARGUMENT_ARRAY,
		null,
		err,
		0,
		buf data as CString,
		BUF_SIZE,
		null
	)
	buf setLength(len)

	// rip away trailing CR LF TAB SPACES etc.
	while ((len > 0) && (buf[len - 1] as Byte < 32)) len -= 1
	buf setLength(len)
	buf toString()
}

toLLong: func ~twoPartsLargeInteger (lowPart, highPart: Long) -> LLong {
	li: LargeInteger
	li lowPart = lowPart
	li highPart = highPart
	li quadPart
}

toULLong: func ~twoPartsLargeInteger (lowPart, highPart: Long) -> ULLong {
	li: ULargeInteger
	li lowPart = lowPart
	li highPart = highPart
	li quadPart
}

// FILETIME is a Long that stores the number of 100-nanoseconds intervals from January 1st, 1601
FileTime: cover from FILETIME {
	lowDateTime: extern (dwLowDateTime) Long
	highDateTime: extern (dwHighDateTime) Long
}

/*
	* source: http://frenk.wordpress.com/2009/12/14/convert-filetime-to-unix-timestamp/
	* thanks, Francesco De Vittori from Lugano, Switzerland!
	*/
toTimestamp: func ~fromFiletime (fileTime: FileTime) -> Long {
	// takes the last modified date
	date, adjust: LargeInteger
	date lowPart = fileTime lowDateTime
	date highPart = fileTime highDateTime

	// 100-nanoseconds = milliseconds * 10000
	adjust quadPart = 11644473600000 * 10000

	// removes the diff between 1970 and 1601
	date quadPart -= adjust quadPart

	// converts back from 100-nanoseconds to seconds
	date quadPart / 10000000
}
}
