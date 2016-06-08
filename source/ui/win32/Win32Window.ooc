/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use ui
use geometry
use draw

version(windows) {
Win32Window: class extends NativeWindow {
	init: func (size: IntVector2D, title: String) {
		windowClassName := "Window class" as CString
		display := GetModuleHandle(null)
		windowClass: WndClassEXA
		windowClass cbSize = WndClassEXA size
		windowClass style = 0
		windowClass lpfnWndProc = This _defaultWindowProcedure
		windowClass cbClsExtra = 0
		windowClass cbWndExtra = 0
		windowClass hInstance = display
		windowClass hIcon = LoadIcon(null, IDI_APPLICATION)
		windowClass hCursor = LoadCursor(null, IDC_ARROW)
		windowClass hbrBackground = (COLOR_WINDOW + 1) as HBRUSH
		windowClass lpszMenuName = null
		windowClass lpszClassName = windowClassName
		windowClass hIconSm = LoadIcon(null, IDI_APPLICATION)
		if (!RegisterClassEx(windowClass&))
			raise("Unable to register win32 window class. Error code: " + GetLastError() toString())
		backend := CreateWindowEx(WS_EX_CLIENTEDGE, windowClassName, title as CString, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, size x, size y, null, null, display, null)
		if (backend == null)
			raise("Unable to create win32 window. Error code: " + GetLastError() toString())
		super(size, backend, display)
		ShowWindow(backend, SW_SHOWDEFAULT)
		UpdateWindow(backend)
	}
	free: override func {
		DestroyWindow(this backend as HWND)
		super()
	}
	draw: func (image: RasterRgba) {
		paintStruct: PaintStruct
		bitmap: Bitmap
		InvalidateRect(this backend as HWND, null, false)
		bitmapHandle := CreateBitmap(image size x, image size y, 1, 32, image buffer pointer)
		deviceContext := BeginPaint(this backend as HWND, paintStruct&)
		deviceContextMemory := CreateCompatibleDC(deviceContext)
		oldBitmap := SelectObject(deviceContextMemory, bitmapHandle)
		GetObject(bitmapHandle, Bitmap size, bitmap&)
		BitBlt(deviceContext, 0, 0, bitmap bmWidth, bitmap bmHeight, deviceContextMemory, 0, 0, SRCCOPY)
		SelectObject(deviceContextMemory, oldBitmap)
		DeleteDC(deviceContextMemory)
		EndPaint(this backend as HWND, paintStruct&)
	}
	peekMessage: func {
		msg: Msg
		if (PeekMessage(msg&, null, 0, 0, PM_REMOVE)) {
			TranslateMessage(msg&)
			DispatchMessage(msg&)
		}
	}
	_defaultWindowProcedure: static func (backend: HWND, message: UInt, wParam: WPARAM, lParam: LPARAM) -> LRESULT {
		match (message) {
			case WM_CLOSE =>
				DestroyWindow(backend)
			case WM_DESTROY =>
				PostQuitMessage(0)
		}
		DefWindowProc(backend, message, wParam, lParam)
	}
}
}
