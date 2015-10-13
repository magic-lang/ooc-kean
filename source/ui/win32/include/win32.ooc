/*
 * Copyright (C) 2015 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

include windows

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

COLOR_WINDOW,
WS_OVERLAPPEDWINDOW,
CW_USEDEFAULT,
WM_CLOSE,
WM_DESTROY,
WM_QUIT,
WS_EX_CLIENTEDGE,
SW_SHOWDEFAULT,
SRCCOPY: extern Int
IDC_ARROW,
IDI_APPLICATION: extern LPSTR
PM_REMOVE: extern UInt

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
GetLastError: extern func -> Int
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
