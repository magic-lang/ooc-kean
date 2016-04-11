/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version((unix || apple) && !android) {
include X11/Xlib
include X11/Xatom
include X11/Xutil
include X11/Xos
include X11/keysym
include X11/XKBlib

ExposureMask: extern const Long
PointerMotionMask: extern const Long
CopyFromParent: extern const Long
InputOutput: extern const UInt
CWEventMask: extern const ULong
PSize: extern const Long
PMinSize: extern const Long
PPosition: extern const Long

Aspect: cover {
	x: Int
	y: Int
}

XSizeHintsOoc: cover from XSizeHints {
	flags: extern Long
	x, y: extern Int
	width, height: extern Int
	min_width, min_height: extern Int
	max_width, max_height: extern Int
	width_inc, height_inc: extern Int
	min_aspect, max_aspect: extern Aspect
	base_width, base_height: extern Int
	win_gravity: extern Int
}

XSetWindowAttributesOoc: cover from XSetWindowAttributes {
	backgroundPixmap: extern (background_pixmap) Long
	backgroundPixel: extern (background_pixel) ULong
	borderPixmap: extern (border_pixmap) Long
	borderPixel: extern (border_pixel) ULong
	bitGravity: extern (bit_gravity) Int
	winGravity: extern (win_gravity) Int
	backingStore: extern (backing_store) Int
	backingPlanes: extern (backing_planes) ULong
	backingPixel: extern (backing_pixel) ULong
	saveUnder: extern (save_under) Bool
	eventMask: extern (event_mask) Long
	doNotPropagateMask: extern (do_not_propagate_mask) Long
	overrideRedirect: extern (override_redirect) Bool
	colormap: extern Long
	cursor: extern Long
}

XEventOoc: cover from XEvent {
	type: extern Int
	xkey: extern XKeyEventOoc
}

GraphicsContextX11: cover from GC

XOpenDisplay: extern func (displayName: Char*) -> Pointer
XCloseDisplay: extern func (display: Pointer) -> Int
XCreateWindow: extern func (display: Pointer, window: Long, x, y: Int,
	width, height, borderWidth: UInt, depth: Int, class: UInt, visual: Pointer, valueMask: ULong, attributes: Pointer) -> Long
XMapWindow: extern func (display: Pointer, window: Long) -> Int
XStoreName: extern func (display: Pointer, window: Long, windowName: Char*) -> Int
DefaultRootWindow: extern func (display: Pointer) -> UInt
XSetWMNormalHints: extern func (display: Pointer, window: Long, hints: XSizeHintsOoc*)
XResizeWindow: extern func (display: Pointer, window: Long, width, height: UInt)
XSync: extern func (display: Pointer, discard: Bool)
XFlush: extern func (display: Pointer)
XSendEvent: extern func (display: Pointer, window: Long, propagate: Bool, event_mask: Long, event_send: XEventOoc*)
XClearWindow: extern func (display: Pointer, window: Long)
XMoveWindow: extern func (display: Pointer, window: Long, x, y: Int)
XDefaultScreen: extern func (display: Pointer) -> Int
DefaultDepth: extern func (display: Pointer, screen: Int) -> Int
XSetBackground: extern func (...)
XCreateGC: extern func (...) -> GraphicsContextX11
XFreeGC: extern func (...)
XDestroyWindow: extern func (...)

XImageOoc: cover from XImage {
	width, height, xoffset, format: Int
	data: Char*
	byteOrder, bitmapUnit, bitmapBitOrder, bitmapPad, depth, bytesPerLine, bitsPerPixel: Int
	redMask, greenMask, blueMask: ULong
}
XCreateImage: extern func (...) -> XImageOoc*
XPutImage: extern func (...)
XDestroyImage: extern func (image: XImageOoc*)
XPutPixel: extern func (...)

XKeyEventOoc: cover from XKeyEvent {
	type: extern Int
	serial: extern ULong
	sendEvent: extern (send_event) Bool
	display: extern Pointer
	window: extern ULong
	root: extern ULong
	subwindow: extern ULong
	time: extern ULong
	x: extern Int
	y: extern Int
	xRoot: extern (x_root) Int
	yRoot: extern (y_root) Int
	state: extern UInt
	keycode: extern UInt
	sameScreen: extern (same_screen) Bool
}

ZPixmap: extern const Long

XKeyPressedEventOoc: extern XKeyEventOoc
XKeyReleasedEventOoc: extern XKeyEventOoc
XKeySymOoc: cover from KeySym
XComposeStatusOoc: cover from XComposeStatus

XNextEvent: extern func (display, XEvent: Pointer)
XSelectInput: extern func (display: Pointer, window: ULong, eventMask: extern (event_mask) Long)
XPending: extern func (display: Pointer) -> Int
XkbSetDetectableAutoRepeat: extern func (display: Pointer, detectable: Bool, supported_rtrn: Pointer) -> Bool
XLookupKeysym: extern func (keyEvent: extern (key_event) XKeyEventOoc*, index: Int) -> ULong
XLookupString: extern func (keyEvent: XKeyEventOoc*, result: Char*, resultLength: Int, symbol: XKeySymOoc*, composeStatus: XComposeStatusOoc*)
KeyPress: extern const Int
KeyRelease: extern const Int
KeyPressMask: extern const Long
KeyReleaseMask: extern const Long
ButtonPress: extern const Int
ButtonRelease: extern const Int
ButtonPressMask: extern const Long
ButtonReleaseMask: extern const Long

Button1 : extern const UInt
Button2 : extern const UInt
Button3 : extern const UInt
Button4 : extern const UInt
Button5 : extern const UInt

MouseButton: class {
	Left: static extern (Button1) const UInt
	Middle: static extern (Button2) const UInt
	Right: static extern (Button3) const UInt
	WheelUp: static extern (Button4) const UInt
	WheelDown: static extern (Button5) const UInt
}

XK_VoidSymbol,
XK_VoidSymbol,

/*
 * TTY function keys, cleverly chosen to map to ASCII, for convenience of
 * programming, but could have been arbitrary (at the cost of lookup
 * tables in client code).
 */

XK_BackSpace,
XK_Tab,
XK_Linefeed,
XK_Clear,
XK_Return,
XK_Pause,
XK_Scroll_Lock,
XK_Sys_Req,
XK_Escape,
XK_Delete,

/* Cursor control & motion */

XK_Home,
XK_Left,
XK_Up,
XK_Right,
XK_Down,
XK_Prior,
XK_Page_Up,
XK_Next,
XK_Page_Down,
XK_End,
XK_Begin,

/* Misc functions */

XK_Select,
XK_Print,
XK_Execute,
XK_Insert,
XK_Undo,
XK_Redo,
XK_Menu,
XK_Find,
XK_Cancel,
XK_Help,
XK_Break,
XK_Mode_switch,
XK_script_switch,
XK_Num_Lock,

/* Keypad functions, keypad numbers cleverly chosen to map to ASCII */

XK_KP_Space,
XK_KP_Tab,
XK_KP_Enter,
XK_KP_F1,
XK_KP_F2,
XK_KP_F3,
XK_KP_F4,
XK_KP_Home,
XK_KP_Left,
XK_KP_Up,
XK_KP_Right,
XK_KP_Down,
XK_KP_Prior,
XK_KP_Page_Up,
XK_KP_Next,
XK_KP_Page_Down,
XK_KP_End,
XK_KP_Begin,
XK_KP_Insert,
XK_KP_Delete,
XK_KP_Equal,
XK_KP_Multiply,
XK_KP_Add,
XK_KP_Separator,
XK_KP_Subtract,
XK_KP_Decimal,
XK_KP_Divide,

XK_KP_0,
XK_KP_1,
XK_KP_2,
XK_KP_3,
XK_KP_4,
XK_KP_5,
XK_KP_6,
XK_KP_7,
XK_KP_8,
XK_KP_9,

/*
 * Auxiliary functions; note the duplicate definitions for left and right
 * function keys;  Sun keyboards and a few other manufacturers have such
 * function key groups on the left and/or right sides of the keyboard.
 * We've not found a keyboard with more than 35 function keys total.
 */

XK_F1,
XK_F2,
XK_F3,
XK_F4,
XK_F5,
XK_F6,
XK_F7,
XK_F8,
XK_F9,
XK_F10,
XK_F11,
XK_L1,
XK_F12,
XK_L2,
XK_F13,
XK_L3,
XK_F14,
XK_L4,
XK_F15,
XK_L5,
XK_F16,
XK_L6,
XK_F17,
XK_L7,
XK_F18,
XK_L8,
XK_F19,
XK_L9,
XK_F20,
XK_L10,
XK_F21,
XK_R1,
XK_F22,
XK_R2,
XK_F23,
XK_R3,
XK_F24,
XK_R4,
XK_F25,
XK_R5,
XK_F26,
XK_R6,
XK_F27,
XK_R7,
XK_F28,
XK_R8,
XK_F29,
XK_R9,
XK_F30,
XK_R10,
XK_F31,
XK_R11,
XK_F32,
XK_R12,
XK_F33,
XK_R13,
XK_F34,
XK_R14,
XK_F35,
XK_R15,

/* Modifiers */

XK_Shift_L,
XK_Shift_R,
XK_Control_L,
XK_Control_R,
XK_Caps_Lock,
XK_Shift_Lock,

XK_Meta_L,
XK_Meta_R,
XK_Alt_L,
XK_Alt_R,
XK_Super_L,
XK_Super_R,
XK_Hyper_L,
XK_Hyper_R,

/*
 * 3270 Terminal Keys
 * Byte 3 = 0xfd
 */

XK_3270_Duplicate,
XK_3270_FieldMark,
XK_3270_Right2,
XK_3270_Left2,
XK_3270_BackTab,
XK_3270_EraseEOF,
XK_3270_EraseInput,
XK_3270_Reset,
XK_3270_Quit,
XK_3270_PA1,
XK_3270_PA2,
XK_3270_PA3,
XK_3270_Test,
XK_3270_Attn,
XK_3270_CursorBlink,
XK_3270_AltCursor,
XK_3270_KeyClick,
XK_3270_Jump,
XK_3270_Ident,
XK_3270_Rule,
XK_3270_Copy,
XK_3270_Play,
XK_3270_Setup,
XK_3270_Record,
XK_3270_ChangeScreen,
XK_3270_DeleteWord,
XK_3270_ExSelect,
XK_3270_CursorSelect,
XK_3270_PrintScreen,
XK_3270_Enter,

/*
 * Latin 1
 * (ISO/IEC 8859-1 = Unicode U+0020..U+00FF)
 * Byte 3 = 0
 */
XK_space,
XK_exclam,
XK_quotedbl,
XK_numbersign,
XK_dollar,
XK_percent,
XK_ampersand,
XK_apostrophe,
XK_quoteright,
XK_parenleft,
XK_parenright,
XK_asterisk,
XK_plus,
XK_comma,
XK_minus,
XK_period,
XK_slash,
XK_0,
XK_1,
XK_2,
XK_3,
XK_4,
XK_5,
XK_6,
XK_7,
XK_8,
XK_9,
XK_colon,
XK_semicolon,
XK_less,
XK_equal,
XK_greater,
XK_question,
XK_at,
XK_A,
XK_B,
XK_C,
XK_D,
XK_E,
XK_F,
XK_G,
XK_H,
XK_I,
XK_J,
XK_K,
XK_L,
XK_M,
XK_N,
XK_O,
XK_P,
XK_Q,
XK_R,
XK_S,
XK_T,
XK_U,
XK_V,
XK_W,
XK_X,
XK_Y,
XK_Z,
XK_bracketleft,
XK_backslash,
XK_bracketright,
XK_asciicircum,
XK_underscore,
XK_grave,
XK_quoteleft,
XK_a,
XK_b,
XK_c,
XK_d,
XK_e,
XK_f,
XK_g,
XK_h,
XK_i,
XK_j,
XK_k,
XK_l,
XK_m,
XK_n,
XK_o,
XK_p,
XK_q,
XK_r,
XK_s,
XK_t,
XK_u,
XK_v,
XK_w,
XK_x,
XK_y,
XK_z,
XK_braceleft,
XK_bar,
XK_braceright,
XK_asciitilde,

XK_EcuSign,
XK_ColonSign,
XK_CruzeiroSign,
XK_FFrancSign,
XK_LiraSign,
XK_MillSign,
XK_NairaSign,
XK_PesetaSign,
XK_RupeeSign,
XK_WonSign,
XK_NewSheqelSign,
XK_DongSign,
XK_EuroSign: extern const ULong

Key: class {
	BackSpace: static extern (XK_BackSpace) const ULong
	Tab: static extern (XK_Tab) const ULong
	Linefeed: static extern (XK_Linefeed) const ULong
	Clear: static extern (XK_Clear) const ULong
	Return: static extern (XK_Return) const ULong
	Pause: static extern (XK_Pause) const ULong
	ScrollLock: static extern (XK_Scroll_Lock) const ULong
	SysReq: static extern (XK_Sys_Req) const ULong
	Escape: static extern (XK_Escape) const ULong
	Delete: static extern (XK_Delete) const ULong
	Home: static extern (XK_Home) const ULong
	Left: static extern (XK_Left) const ULong
	Up: static extern (XK_Up) const ULong
	Right: static extern (XK_Right) const ULong
	Down: static extern (XK_Down) const ULong
	Prior: static extern (XK_Prior) const ULong
	PageUp: static extern (XK_Page_Up) const ULong
	Next: static extern (XK_Next) const ULong
	PageDown: static extern (XK_Page_Down) const ULong
	End: static extern (XK_End) const ULong
	Begin: static extern (XK_Begin) const ULong
	Select: static extern (XK_Select) const ULong
	Print: static extern (XK_Print) const ULong
	Execute: static extern (XK_Execute) const ULong
	Insert: static extern (XK_Insert) const ULong
	Undo: static extern (XK_Undo) const ULong
	Redo: static extern (XK_Redo) const ULong
	Menu: static extern (XK_Menu) const ULong
	Find: static extern (XK_Find) const ULong
	Cancel: static extern (XK_Cancel) const ULong
	Help: static extern (XK_Help) const ULong
	Break: static extern (XK_Break) const ULong
	ModeSwitch: static extern (XK_Mode_switch) const ULong
	ScriptSwitch: static extern (XK_script_switch) const ULong
	NumLock: static extern (XK_Num_Lock) const ULong
	KeypadSpace: static extern (XK_KP_Space) const ULong
	KeypadTab: static extern (XK_KP_Tab) const ULong
	KeypadEnter: static extern (XK_KP_Enter) const ULong
	KeypadF1: static extern (XK_KP_F1) const ULong
	KeypadF2: static extern (XK_KP_F2) const ULong
	KeypadF3: static extern (XK_KP_F3) const ULong
	KeypadF4: static extern (XK_KP_F4) const ULong
	KeypadHome: static extern (XK_KP_Home) const ULong
	KeypadLeft: static extern (XK_KP_Left) const ULong
	KeypadUp: static extern (XK_KP_Up) const ULong
	KeypadRight: static extern (XK_KP_Right) const ULong
	KeypadDown: static extern (XK_KP_Down) const ULong
	KeypadPrior: static extern (XK_KP_Prior) const ULong
	KeypadPageUp: static extern (XK_KP_Page_Up) const ULong
	KeypadNext: static extern (XK_KP_Next) const ULong
	KeypadPageDown: static extern (XK_KP_Page_Down) const ULong
	KeypadEnd: static extern (XK_KP_End) const ULong
	KeypadBegin: static extern (XK_KP_Begin) const ULong
	KeypadInsert: static extern (XK_KP_Insert) const ULong
	KeypadDelete: static extern (XK_KP_Delete) const ULong
	KeypadEqual: static extern (XK_KP_Equal) const ULong
	KeypadMultiply: static extern (XK_KP_Multiply) const ULong
	KeypadAdd: static extern (XK_KP_Add) const ULong
	KeypadSeparator: static extern (XK_KP_Separator) const ULong
	KeypadSubtract: static extern (XK_KP_Subtract) const ULong
	KeypadDecimal: static extern (XK_KP_Decimal) const ULong
	KeypadDivide: static extern (XK_KP_Divide) const ULong
	Keypad0: static extern (XK_KP_0) const ULong
	Keypad1: static extern (XK_KP_1) const ULong
	Keypad2: static extern (XK_KP_2) const ULong
	Keypad3: static extern (XK_KP_3) const ULong
	Keypad4: static extern (XK_KP_4) const ULong
	Keypad5: static extern (XK_KP_5) const ULong
	Keypad6: static extern (XK_KP_6) const ULong
	Keypad7: static extern (XK_KP_7) const ULong
	Keypad8: static extern (XK_KP_8) const ULong
	Keypad9: static extern (XK_KP_9) const ULong
	F1: static extern (XK_F1) const ULong
	F2: static extern (XK_F2) const ULong
	F3: static extern (XK_F3) const ULong
	F4: static extern (XK_F4) const ULong
	F5: static extern (XK_F5) const ULong
	F6: static extern (XK_F6) const ULong
	F7: static extern (XK_F7) const ULong
	F8: static extern (XK_F8) const ULong
	F9: static extern (XK_F9) const ULong
	F10: static extern (XK_F10) const ULong
	F11: static extern (XK_F11) const ULong
	L1: static extern (XK_L1) const ULong
	F12: static extern (XK_F12) const ULong
	L2: static extern (XK_L2) const ULong
	F13: static extern (XK_F13) const ULong
	L3: static extern (XK_L3) const ULong
	F14: static extern (XK_F14) const ULong
	L4: static extern (XK_L4) const ULong
	F15: static extern (XK_F15) const ULong
	L5: static extern (XK_L5) const ULong
	F16: static extern (XK_F16) const ULong
	L6: static extern (XK_L6) const ULong
	F17: static extern (XK_F17) const ULong
	L7: static extern (XK_L7) const ULong
	F18: static extern (XK_F18) const ULong
	L8: static extern (XK_L8) const ULong
	F19: static extern (XK_F19) const ULong
	L9: static extern (XK_L9) const ULong
	F20: static extern (XK_F20) const ULong
	L10: static extern (XK_L10) const ULong
	F21: static extern (XK_F21) const ULong
	R1: static extern (XK_R1) const ULong
	F22: static extern (XK_F22) const ULong
	R2: static extern (XK_R2) const ULong
	F23: static extern (XK_F23) const ULong
	R3: static extern (XK_R3) const ULong
	F24: static extern (XK_F24) const ULong
	R4: static extern (XK_R4) const ULong
	F25: static extern (XK_F25) const ULong
	R5: static extern (XK_R5) const ULong
	F26: static extern (XK_F26) const ULong
	R6: static extern (XK_R6) const ULong
	F27: static extern (XK_F27) const ULong
	R7: static extern (XK_R7) const ULong
	F28: static extern (XK_F28) const ULong
	R8: static extern (XK_R8) const ULong
	F29: static extern (XK_F29) const ULong
	R9: static extern (XK_R9) const ULong
	F30: static extern (XK_F30) const ULong
	R10: static extern (XK_R10) const ULong
	F31: static extern (XK_F31) const ULong
	R11: static extern (XK_R11) const ULong
	F32: static extern (XK_F32) const ULong
	R12: static extern (XK_R12) const ULong
	F33: static extern (XK_F33) const ULong
	R13: static extern (XK_R13) const ULong
	F34: static extern (XK_F34) const ULong
	R14: static extern (XK_R14) const ULong
	F35: static extern (XK_F35) const ULong
	R15: static extern (XK_R15) const ULong
	LeftShift: static extern (XK_Shift_L) const ULong
	RightShift: static extern (XK_Shift_R) const ULong
	LeftControl: static extern (XK_Control_L) const ULong
	RightControl: static extern (XK_Control_R) const ULong
	CapsLock: static extern (XK_Caps_Lock) const ULong
	ShiftLock: static extern (XK_Shift_Lock) const ULong
	LeftMeta: static extern (XK_Meta_L) const ULong
	RightMeta: static extern (XK_Meta_R) const ULong
	LeftAlt: static extern (XK_Alt_L) const ULong
	RightAlt: static extern (XK_Alt_R) const ULong
	LeftSuper: static extern (XK_Super_L) const ULong
	RightSuper: static extern (XK_Super_R) const ULong
	LeftHyper: static extern (XK_Hyper_L) const ULong
	RightHyper: static extern (XK_Hyper_R) const ULong
	Space: static extern (XK_space) const ULong
	Exclam: static extern (XK_exclam) const ULong
	Quotedbl: static extern (XK_quotedbl) const ULong
	Numbersign: static extern (XK_numbersign) const ULong
	Dollar: static extern (XK_dollar) const ULong
	Percent: static extern (XK_percent) const ULong
	Ampersand: static extern (XK_ampersand) const ULong
	Apostrophe: static extern (XK_apostrophe) const ULong
	RightQuote: static extern (XK_quoteright) const ULong
	LeftParenthesis: static extern (XK_parenleft) const ULong
	RightParenthesis: static extern (XK_parenright) const ULong
	Asterisk: static extern (XK_asterisk) const ULong
	Plus: static extern (XK_plus) const ULong
	Comma: static extern (XK_comma) const ULong
	Minus: static extern (XK_minus) const ULong
	Period: static extern (XK_period) const ULong
	Slash: static extern (XK_slash) const ULong
	Number0: static extern (XK_0) const ULong
	Number1: static extern (XK_1) const ULong
	Number2: static extern (XK_2) const ULong
	Number3: static extern (XK_3) const ULong
	Number4: static extern (XK_4) const ULong
	Number5: static extern (XK_5) const ULong
	Number6: static extern (XK_6) const ULong
	Number7: static extern (XK_7) const ULong
	Number8: static extern (XK_8) const ULong
	Number9: static extern (XK_9) const ULong
	Colon: static extern (XK_colon) const ULong
	Semicolon: static extern (XK_semicolon) const ULong
	Less: static extern (XK_less) const ULong
	Equal: static extern (XK_equal) const ULong
	Greater: static extern (XK_greater) const ULong
	Question: static extern (XK_question) const ULong
	At: static extern (XK_at) const ULong
	A: static extern (XK_A) const ULong
	B: static extern (XK_B) const ULong
	C: static extern (XK_C) const ULong
	D: static extern (XK_D) const ULong
	E: static extern (XK_E) const ULong
	F: static extern (XK_F) const ULong
	G: static extern (XK_G) const ULong
	H: static extern (XK_H) const ULong
	I: static extern (XK_I) const ULong
	J: static extern (XK_J) const ULong
	K: static extern (XK_K) const ULong
	L: static extern (XK_L) const ULong
	M: static extern (XK_M) const ULong
	N: static extern (XK_N) const ULong
	O: static extern (XK_O) const ULong
	P: static extern (XK_P) const ULong
	Q: static extern (XK_Q) const ULong
	R: static extern (XK_R) const ULong
	S: static extern (XK_S) const ULong
	T: static extern (XK_T) const ULong
	U: static extern (XK_U) const ULong
	V: static extern (XK_V) const ULong
	W: static extern (XK_W) const ULong
	X: static extern (XK_X) const ULong
	Y: static extern (XK_Y) const ULong
	Z: static extern (XK_Z) const ULong
	LeftBracket: static extern (XK_bracketleft) const ULong
	Backslash: static extern (XK_backslash) const ULong
	RightBracket: static extern (XK_bracketright) const ULong
	AsciiCircum: static extern (XK_asciicircum) const ULong
	Underscore: static extern (XK_underscore) const ULong
	Grave: static extern (XK_grave) const ULong
	LeftQuote: static extern (XK_quoteleft) const ULong
	a: static extern (XK_a) const ULong
	b: static extern (XK_b) const ULong
	c: static extern (XK_c) const ULong
	d: static extern (XK_d) const ULong
	e: static extern (XK_e) const ULong
	f: static extern (XK_f) const ULong
	g: static extern (XK_g) const ULong
	h: static extern (XK_h) const ULong
	i: static extern (XK_i) const ULong
	j: static extern (XK_j) const ULong
	k: static extern (XK_k) const ULong
	l: static extern (XK_l) const ULong
	m: static extern (XK_m) const ULong
	n: static extern (XK_n) const ULong
	o: static extern (XK_o) const ULong
	p: static extern (XK_p) const ULong
	q: static extern (XK_q) const ULong
	r: static extern (XK_r) const ULong
	s: static extern (XK_s) const ULong
	t: static extern (XK_t) const ULong
	u: static extern (XK_u) const ULong
	v: static extern (XK_v) const ULong
	w: static extern (XK_w) const ULong
	x: static extern (XK_x) const ULong
	y: static extern (XK_y) const ULong
	z: static extern (XK_z) const ULong
	LeftBrace: static extern (XK_braceleft) const ULong
	Bar: static extern (XK_bar) const ULong
	RightBrace: static extern (XK_braceright) const ULong
	AsciiTilde: static extern (XK_asciitilde) const ULong
	EcuSign: static extern (XK_EcuSign) const ULong
	ColonSign: static extern (XK_ColonSign) const ULong
	CruzeiroSign: static extern (XK_CruzeiroSign) const ULong
	FFrancSign: static extern (XK_FFrancSign) const ULong
	LiraSign: static extern (XK_LiraSign) const ULong
	MillSign: static extern (XK_MillSign) const ULong
	NairaSign: static extern (XK_NairaSign) const ULong
	PesetaSign: static extern (XK_PesetaSign) const ULong
	RupeeSign: static extern (XK_RupeeSign) const ULong
	WonSign: static extern (XK_WonSign) const ULong
	NewSheqelSign: static extern (XK_NewSheqelSign) const ULong
	DongSign: static extern (XK_DongSign) const ULong
	EuroSign: static extern (XK_EuroSign) const ULong
}
}
