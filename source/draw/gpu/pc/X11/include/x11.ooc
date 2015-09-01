/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
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

//XNextEvent: extern func(Pointer, XEvent) -> Int

XKeyPressedEventOoc: extern XKeyEventOoc
XKeyReleasedEventOoc: extern XKeyEventOoc

XNextEvent: extern func (display, XEvent: Pointer)
XSelectInput: extern func (display: Pointer, window: ULong, eventMask: extern (event_mask) Long)
XPending: extern func (display: Pointer) -> Int
XkbSetDetectableAutoRepeat: extern func (display: Pointer, detectable: Bool, supported_rtrn: Pointer) -> Bool
XLookupKeysym: extern func (keyEvent: extern (key_event) XKeyEventOoc*, index: Int) -> ULong
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

MouseButton: enum {
	Left = Button1
	Middle = Button2
	Right = Button3
	WheelUp = Button4
	WheelDown = Button5
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

Key: enum {
	BackSpace = XK_BackSpace
	Tab = XK_Tab
	Linefeed = XK_Linefeed
	Clear = XK_Clear
	Return = XK_Return
	Pause = XK_Pause
	ScrollLock = XK_Scroll_Lock
	SysReq = XK_Sys_Req
	Escape = XK_Escape
	Delete = XK_Delete
	Home = XK_Home
	Left = XK_Left
	Up = XK_Up
	Right = XK_Right
	Down = XK_Down
	Prior = XK_Prior
	PageUp = XK_Page_Up
	Next = XK_Next
	PageDown = XK_Page_Down
	End = XK_End
	Begin = XK_Begin
	Select = XK_Select
	Print = XK_Print
	Execute = XK_Execute
	Insert = XK_Insert
	Undo = XK_Undo
	Redo = XK_Redo
	Menu = XK_Menu
	Find = XK_Find
	Cancel = XK_Cancel
	Help = XK_Help
	Break = XK_Break
	ModeSwitch = XK_Mode_switch
	ScriptSwitch = XK_script_switch
	NumLock = XK_Num_Lock
	KeypadSpace = XK_KP_Space
	KeypadTab = XK_KP_Tab
	KeypadEnter = XK_KP_Enter
	KeypadF1 = XK_KP_F1
	KeypadF2 = XK_KP_F2
	KeypadF3 = XK_KP_F3
	KeypadF4 = XK_KP_F4
	KeypadHome = XK_KP_Home
	KeypadLeft = XK_KP_Left
	KeypadUp = XK_KP_Up
	KeypadRight = XK_KP_Right
	KeypadDown = XK_KP_Down
	KeypadPrior = XK_KP_Prior
	KeypadPageUp = XK_KP_Page_Up
	KeypadNext = XK_KP_Next
	KeypadPageDown = XK_KP_Page_Down
	KeypadEnd = XK_KP_End
	KeypadBegin = XK_KP_Begin
	KeypadInsert = XK_KP_Insert
	KeypadDelete = XK_KP_Delete
	KeypadEqual = XK_KP_Equal
	KeypadMultiply = XK_KP_Multiply
	KeypadAdd = XK_KP_Add
	KeypadSeparator = XK_KP_Separator
	KeypadSubtract = XK_KP_Subtract
	KeypadDecimal = XK_KP_Decimal
	KeypadDivide = XK_KP_Divide
	Keypad0 = XK_KP_0
	Keypad1 = XK_KP_1
	Keypad2 = XK_KP_2
	Keypad3 = XK_KP_3
	Keypad4 = XK_KP_4
	Keypad5 = XK_KP_5
	Keypad6 = XK_KP_6
	Keypad7 = XK_KP_7
	Keypad8 = XK_KP_8
	Keypad9 = XK_KP_9
	F1 = XK_F1
	F2 = XK_F2
	F3 = XK_F3
	F4 = XK_F4
	F5 = XK_F5
	F6 = XK_F6
	F7 = XK_F7
	F8 = XK_F8
	F9 = XK_F9
	F10 = XK_F10
	F11 = XK_F11
	L1 = XK_L1
	F12 = XK_F12
	L2 = XK_L2
	F13 = XK_F13
	L3 = XK_L3
	F14 = XK_F14
	L4 = XK_L4
	F15 = XK_F15
	L5 = XK_L5
	F16 = XK_F16
	L6 = XK_L6
	F17 = XK_F17
	L7 = XK_L7
	F18 = XK_F18
	L8 = XK_L8
	F19 = XK_F19
	L9 = XK_L9
	F20 = XK_F20
	L10 = XK_L10
	F21 = XK_F21
	R1 = XK_R1
	F22 = XK_F22
	R2 = XK_R2
	F23 = XK_F23
	R3 = XK_R3
	F24 = XK_F24
	R4 = XK_R4
	F25 = XK_F25
	R5 = XK_R5
	F26 = XK_F26
	R6 = XK_R6
	F27 = XK_F27
	R7 = XK_R7
	F28 = XK_F28
	R8 = XK_R8
	F29 = XK_F29
	R9 = XK_R9
	F30 = XK_F30
	R10 = XK_R10
	F31 = XK_F31
	R11 = XK_R11
	F32 = XK_F32
	R12 = XK_R12
	F33 = XK_F33
	R13 = XK_R13
	F34 = XK_F34
	R14 = XK_R14
	F35 = XK_F35
	R15 = XK_R15
	LeftShift = XK_Shift_L
	RightShift = XK_Shift_R
	LeftControl = XK_Control_L
	RightControl = XK_Control_R
	CapsLock = XK_Caps_Lock
	ShiftLock = XK_Shift_Lock
	LeftMeta = XK_Meta_L
	RightMeta = XK_Meta_R
	LeftAlt = XK_Alt_L
	RightAlt = XK_Alt_R
	LeftSuper = XK_Super_L
	RightSuper = XK_Super_R
	LeftHyper = XK_Hyper_L
	RightHyper = XK_Hyper_R
	/*IBM3270Duplicate = XK_3270_Duplicate
	IBM3270FieldMark = XK_3270_FieldMark
	IBM3270Right2 = XK_3270_Right2
	IBM3270Left2 = XK_3270_Left2
	IBM3270BackTab = XK_3270_BackTab
	IBM3270EraseEOF = XK_3270_EraseEOF
	IBM3270EraseInput = XK_3270_EraseInput
	IBM3270Reset = XK_3270_Reset
	IBM3270Quit = XK_3270_Quit
	IBM3270PA1 = XK_3270_PA1
	IBM3270PA2 = XK_3270_PA2
	IBM3270PA3 = XK_3270_PA3
	IBM3270Test = XK_3270_Test
	IBM3270Attn = XK_3270_Attn
	IBM3270CursorBlink = XK_3270_CursorBlink
	IBM3270AltCursor = XK_3270_AltCursor
	IBM3270KeyClick = XK_3270_KeyClick
	IBM3270Jump = XK_3270_Jump
	IBM3270Ident = XK_3270_Ident
	IBM3270Rule = XK_3270_Rule
	IBM3270Copy = XK_3270_Copy
	IBM3270Play = XK_3270_Play
	IBM3270Setup = XK_3270_Setup
	IBM3270Record = XK_3270_Record
	IBM3270ChangeScreen = XK_3270_ChangeScreen
	IBM3270DeleteWord = XK_3270_DeleteWord
	IBM3270ExSelect = XK_3270_ExSelect
	IBM3270CursorSelect = XK_3270_CursorSelect
	IBM3270PrintScreen = XK_3270_PrintScreen
	IBM3270Enter = XK_3270_Enter*/
	Space = XK_space
	Exclam = XK_exclam
	Quotedbl = XK_quotedbl
	Numbersign = XK_numbersign
	Dollar = XK_dollar
	Percent = XK_percent
	Ampersand = XK_ampersand
	Apostrophe = XK_apostrophe
	RightQuote = XK_quoteright
	LeftParenthesis = XK_parenleft
	RightParenthesis = XK_parenright
	Asterisk = XK_asterisk
	Plus = XK_plus
	Comma = XK_comma
	Minus = XK_minus
	Period = XK_period
	Slash = XK_slash
	Number0 = XK_0
	Number1 = XK_1
	Number2 = XK_2
	Number3 = XK_3
	Number4 = XK_4
	Number5 = XK_5
	Number6 = XK_6
	Number7 = XK_7
	Number8 = XK_8
	Number9 = XK_9
	Colon = XK_colon
	Semicolon = XK_semicolon
	Less = XK_less
	Equal = XK_equal
	Greater = XK_greater
	Question = XK_question
	At = XK_at
	A = XK_A
	B = XK_B
	C = XK_C
	D = XK_D
	E = XK_E
	F = XK_F
	G = XK_G
	H = XK_H
	I = XK_I
	J = XK_J
	K = XK_K
	L = XK_L
	M = XK_M
	N = XK_N
	O = XK_O
	P = XK_P
	Q = XK_Q
	R = XK_R
	S = XK_S
	T = XK_T
	U = XK_U
	V = XK_V
	W = XK_W
	X = XK_X
	Y = XK_Y
	Z = XK_Z
	LeftBracket = XK_bracketleft
	Backslash = XK_backslash
	RightBracket = XK_bracketright
	AsciiCircum = XK_asciicircum
	Underscore = XK_underscore
	Grave = XK_grave
	LeftQuote = XK_quoteleft
	a = XK_a
	b = XK_b
	c = XK_c
	d = XK_d
	e = XK_e
	f = XK_f
	g = XK_g
	h = XK_h
	i = XK_i
	j = XK_j
	k = XK_k
	l = XK_l
	m = XK_m
	n = XK_n
	o = XK_o
	p = XK_p
	q = XK_q
	r = XK_r
	s = XK_s
	t = XK_t
	u = XK_u
	v = XK_v
	w = XK_w
	x = XK_x
	y = XK_y
	z = XK_z
	LeftBrace = XK_braceleft
	Bar = XK_bar
	RightBrace = XK_braceright
	AsciiTilde = XK_asciitilde
	EcuSign = XK_EcuSign
	ColonSign = XK_ColonSign
	CruzeiroSign = XK_CruzeiroSign
	FFrancSign = XK_FFrancSign
	LiraSign = XK_LiraSign
	MillSign = XK_MillSign
	NairaSign = XK_NairaSign
	PesetaSign = XK_PesetaSign
	RupeeSign = XK_RupeeSign
	WonSign = XK_WonSign
	NewSheqelSign = XK_NewSheqelSign
	DongSign = XK_DongSign
	EuroSign = XK_EuroSign
}
