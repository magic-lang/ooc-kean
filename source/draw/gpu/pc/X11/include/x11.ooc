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

ExposureMask: extern const Long
PointerMotionMask: extern const Long
CopyFromParent: extern const Long
InputOutput: extern const UInt
CWEventMask: extern const ULong

XSetWindowAttributesOoc: cover from XSetWindowAttributes {
	backgroundPixmap: extern(background_pixmap) Long
	backgroundPixel: extern(background_pixel) ULong
	borderPixmap: extern(border_pixmap) Long
	borderPixel: extern(border_pixel) ULong
	bitGravity: extern(bit_gravity) Int
	winGravity: extern(win_gravity) Int
	backingStore: extern(backing_store) Int
	backingPlanes: extern(backing_planes) ULong
	backingPixel: extern(backing_pixel) ULong
	saveUnder: extern(save_under) Bool
	eventMask: extern(event_mask) Long
	doNotPropagateMask: extern(do_not_propagate_mask) Long
	overrideRedirect: extern(override_redirect) Bool
	colormap: extern Long
	cursor: extern Long
}

XOpenDisplay: extern func(displayName: Char*) -> Pointer
XCreateWindow: extern func(display: Pointer, window: Long, x: Int, y: Int,
	width: UInt, height: UInt, borderWidth: UInt, depth: Int, class: UInt, visual: Pointer, valueMask: ULong, attributes: Pointer) -> Long
XMapWindow: extern func(display: Pointer, window: Long) -> Int
XStoreName: extern func(display: Pointer, window: Long, windowName: Char*) -> Int
DefaultRootWindow: extern func(display: Pointer) -> UInt

//XNextEvent: extern func(Pointer, XEvent) -> Int

XKeyEventOoc: cover from XKeyEvent {
	type: extern Int
	serial: extern ULong
	sendEvent: extern(send_event) Bool
	display: extern Pointer
	window: extern ULong
	root: extern ULong
	subwindow: extern ULong
	time: extern ULong
	x: extern Int
	y: extern Int
	xRoot: extern(x_root) Int
	yRoot: extern(y_root) Int
	state: extern UInt
	keycode: extern UInt
	sameScreen: extern(same_screen) Bool
}

XEventOoc: cover from XEvent {
	type: extern Int
	xkey: extern XKeyEventOoc
}

XKeyPressedEventOoc: extern XKeyEventOoc
XKeyReleasedEventOoc: extern XKeyEventOoc

XNextEvent: extern func(display: Pointer, XEvent: Pointer)
XSelectInput: extern func(display: Pointer, window: ULong, eventMask: extern(event_mask) Long)
XPending: extern func(display: Pointer) -> Int
XkbSetDetectableAutoRepeat: extern func(display: Pointer, detectable: Bool, supported_rtrn: Pointer) -> Bool
XLookupKeysym: extern func(keyEvent: extern(key_event) XKeyEventOoc*, index: Int) -> ULong
KeyPress: extern const Int
KeyRelease: extern const Int
KeyPressMask: extern const Long
KeyReleaseMask: extern const Long
ButtonPress: extern const Int
ButtonRelease: extern const Int
ButtonPressMask: extern const Long
ButtonReleaseMask: extern const Long

XK_VoidSymbol                 : extern const ULong
XK_VoidSymbol                 : extern const ULong

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

/*
 * TTY function keys, cleverly chosen to map to ASCII, for convenience of
 * programming, but could have been arbitrary (at the cost of lookup
 * tables in client code).
 */

XK_BackSpace                    : extern const ULong
XK_Tab                          : extern const ULong
XK_Linefeed                     : extern const ULong
XK_Clear                        : extern const ULong
XK_Return                       : extern const ULong
XK_Pause                        : extern const ULong
XK_Scroll_Lock                  : extern const ULong
XK_Sys_Req                      : extern const ULong
XK_Escape                       : extern const ULong
XK_Delete                       : extern const ULong

/* Cursor control & motion */

XK_Home                         : extern const ULong
XK_Left                         : extern const ULong
XK_Up                           : extern const ULong
XK_Right                        : extern const ULong
XK_Down                         : extern const ULong
XK_Prior                        : extern const ULong
XK_Page_Up                      : extern const ULong
XK_Next                         : extern const ULong
XK_Page_Down                    : extern const ULong
XK_End                          : extern const ULong
XK_Begin                        : extern const ULong

/* Misc functions */

XK_Select                       : extern const ULong
XK_Print                        : extern const ULong
XK_Execute                      : extern const ULong
XK_Insert                       : extern const ULong
XK_Undo                         : extern const ULong
XK_Redo                         : extern const ULong
XK_Menu                         : extern const ULong
XK_Find                         : extern const ULong
XK_Cancel                       : extern const ULong
XK_Help                         : extern const ULong
XK_Break                        : extern const ULong
XK_Mode_switch                  : extern const ULong
XK_script_switch                : extern const ULong
XK_Num_Lock                     : extern const ULong

/* Keypad functions, keypad numbers cleverly chosen to map to ASCII */

XK_KP_Space                     : extern const ULong
XK_KP_Tab                       : extern const ULong
XK_KP_Enter                     : extern const ULong
XK_KP_F1                        : extern const ULong
XK_KP_F2                        : extern const ULong
XK_KP_F3                        : extern const ULong
XK_KP_F4                        : extern const ULong
XK_KP_Home                      : extern const ULong
XK_KP_Left                      : extern const ULong
XK_KP_Up                        : extern const ULong
XK_KP_Right                     : extern const ULong
XK_KP_Down                      : extern const ULong
XK_KP_Prior                     : extern const ULong
XK_KP_Page_Up                   : extern const ULong
XK_KP_Next                      : extern const ULong
XK_KP_Page_Down                 : extern const ULong
XK_KP_End                       : extern const ULong
XK_KP_Begin                     : extern const ULong
XK_KP_Insert                    : extern const ULong
XK_KP_Delete                    : extern const ULong
XK_KP_Equal                     : extern const ULong
XK_KP_Multiply                  : extern const ULong
XK_KP_Add                       : extern const ULong
XK_KP_Separator                 : extern const ULong
XK_KP_Subtract                  : extern const ULong
XK_KP_Decimal                   : extern const ULong
XK_KP_Divide                    : extern const ULong

XK_KP_0                         : extern const ULong
XK_KP_1                         : extern const ULong
XK_KP_2                         : extern const ULong
XK_KP_3                         : extern const ULong
XK_KP_4                         : extern const ULong
XK_KP_5                         : extern const ULong
XK_KP_6                         : extern const ULong
XK_KP_7                         : extern const ULong
XK_KP_8                         : extern const ULong
XK_KP_9                         : extern const ULong

/*
 * Auxiliary functions; note the duplicate definitions for left and right
 * function keys;  Sun keyboards and a few other manufacturers have such
 * function key groups on the left and/or right sides of the keyboard.
 * We've not found a keyboard with more than 35 function keys total.
 */

XK_F1                           : extern const ULong
XK_F2                           : extern const ULong
XK_F3                           : extern const ULong
XK_F4                           : extern const ULong
XK_F5                           : extern const ULong
XK_F6                           : extern const ULong
XK_F7                           : extern const ULong
XK_F8                           : extern const ULong
XK_F9                           : extern const ULong
XK_F10                          : extern const ULong
XK_F11                          : extern const ULong
XK_L1                           : extern const ULong
XK_F12                          : extern const ULong
XK_L2                           : extern const ULong
XK_F13                          : extern const ULong
XK_L3                           : extern const ULong
XK_F14                          : extern const ULong
XK_L4                           : extern const ULong
XK_F15                          : extern const ULong
XK_L5                           : extern const ULong
XK_F16                          : extern const ULong
XK_L6                           : extern const ULong
XK_F17                          : extern const ULong
XK_L7                           : extern const ULong
XK_F18                          : extern const ULong
XK_L8                           : extern const ULong
XK_F19                          : extern const ULong
XK_L9                           : extern const ULong
XK_F20                          : extern const ULong
XK_L10                          : extern const ULong
XK_F21                          : extern const ULong
XK_R1                           : extern const ULong
XK_F22                          : extern const ULong
XK_R2                           : extern const ULong
XK_F23                          : extern const ULong
XK_R3                           : extern const ULong
XK_F24                          : extern const ULong
XK_R4                           : extern const ULong
XK_F25                          : extern const ULong
XK_R5                           : extern const ULong
XK_F26                          : extern const ULong
XK_R6                           : extern const ULong
XK_F27                          : extern const ULong
XK_R7                           : extern const ULong
XK_F28                          : extern const ULong
XK_R8                           : extern const ULong
XK_F29                          : extern const ULong
XK_R9                           : extern const ULong
XK_F30                          : extern const ULong
XK_R10                          : extern const ULong
XK_F31                          : extern const ULong
XK_R11                          : extern const ULong
XK_F32                          : extern const ULong
XK_R12                          : extern const ULong
XK_F33                          : extern const ULong
XK_R13                          : extern const ULong
XK_F34                          : extern const ULong
XK_R14                          : extern const ULong
XK_F35                          : extern const ULong
XK_R15                          : extern const ULong

/* Modifiers */

XK_Shift_L                      : extern const ULong
XK_Shift_R                      : extern const ULong
XK_Control_L                    : extern const ULong
XK_Control_R                    : extern const ULong
XK_Caps_Lock                    : extern const ULong
XK_Shift_Lock                   : extern const ULong

XK_Meta_L                       : extern const ULong
XK_Meta_R                       : extern const ULong
XK_Alt_L                        : extern const ULong
XK_Alt_R                        : extern const ULong
XK_Super_L                      : extern const ULong
XK_Super_R                      : extern const ULong
XK_Hyper_L                      : extern const ULong
XK_Hyper_R                      : extern const ULong

/*
 * 3270 Terminal Keys
 * Byte 3 = 0xfd
 */

XK_3270_Duplicate               : extern const ULong
XK_3270_FieldMark               : extern const ULong
XK_3270_Right2                  : extern const ULong
XK_3270_Left2                   : extern const ULong
XK_3270_BackTab                 : extern const ULong
XK_3270_EraseEOF                : extern const ULong
XK_3270_EraseInput              : extern const ULong
XK_3270_Reset                   : extern const ULong
XK_3270_Quit                    : extern const ULong
XK_3270_PA1                     : extern const ULong
XK_3270_PA2                     : extern const ULong
XK_3270_PA3                     : extern const ULong
XK_3270_Test                    : extern const ULong
XK_3270_Attn                    : extern const ULong
XK_3270_CursorBlink             : extern const ULong
XK_3270_AltCursor               : extern const ULong
XK_3270_KeyClick                : extern const ULong
XK_3270_Jump                    : extern const ULong
XK_3270_Ident                   : extern const ULong
XK_3270_Rule                    : extern const ULong
XK_3270_Copy                    : extern const ULong
XK_3270_Play                    : extern const ULong
XK_3270_Setup                   : extern const ULong
XK_3270_Record                  : extern const ULong
XK_3270_ChangeScreen            : extern const ULong
XK_3270_DeleteWord              : extern const ULong
XK_3270_ExSelect                : extern const ULong
XK_3270_CursorSelect            : extern const ULong
XK_3270_PrintScreen             : extern const ULong
XK_3270_Enter                   : extern const ULong

/*
 * Latin 1
 * (ISO/IEC 8859-1 = Unicode U+0020..U+00FF)
 * Byte 3 = 0
 */
XK_space                        : extern const ULong
XK_exclam                       : extern const ULong
XK_quotedbl                     : extern const ULong
XK_numbersign                   : extern const ULong
XK_dollar                       : extern const ULong
XK_percent                      : extern const ULong
XK_ampersand                    : extern const ULong
XK_apostrophe                   : extern const ULong
XK_quoteright                   : extern const ULong
XK_parenleft                    : extern const ULong
XK_parenright                   : extern const ULong
XK_asterisk                     : extern const ULong
XK_plus                         : extern const ULong
XK_comma                        : extern const ULong
XK_minus                        : extern const ULong
XK_period                       : extern const ULong
XK_slash                        : extern const ULong
XK_0                            : extern const ULong
XK_1                            : extern const ULong
XK_2                            : extern const ULong
XK_3                            : extern const ULong
XK_4                            : extern const ULong
XK_5                            : extern const ULong
XK_6                            : extern const ULong
XK_7                            : extern const ULong
XK_8                            : extern const ULong
XK_9                            : extern const ULong
XK_colon                        : extern const ULong
XK_semicolon                    : extern const ULong
XK_less                         : extern const ULong
XK_equal                        : extern const ULong
XK_greater                      : extern const ULong
XK_question                     : extern const ULong
XK_at                           : extern const ULong
XK_A                            : extern const ULong
XK_B                            : extern const ULong
XK_C                            : extern const ULong
XK_D                            : extern const ULong
XK_E                            : extern const ULong
XK_F                            : extern const ULong
XK_G                            : extern const ULong
XK_H                            : extern const ULong
XK_I                            : extern const ULong
XK_J                            : extern const ULong
XK_K                            : extern const ULong
XK_L                            : extern const ULong
XK_M                            : extern const ULong
XK_N                            : extern const ULong
XK_O                            : extern const ULong
XK_P                            : extern const ULong
XK_Q                            : extern const ULong
XK_R                            : extern const ULong
XK_S                            : extern const ULong
XK_T                            : extern const ULong
XK_U                            : extern const ULong
XK_V                            : extern const ULong
XK_W                            : extern const ULong
XK_X                            : extern const ULong
XK_Y                            : extern const ULong
XK_Z                            : extern const ULong
XK_bracketleft                  : extern const ULong
XK_backslash                    : extern const ULong
XK_bracketright                 : extern const ULong
XK_asciicircum                  : extern const ULong
XK_underscore                   : extern const ULong
XK_grave                        : extern const ULong
XK_quoteleft                    : extern const ULong
XK_a                            : extern const ULong
XK_b                            : extern const ULong
XK_c                            : extern const ULong
XK_d                            : extern const ULong
XK_e                            : extern const ULong
XK_f                            : extern const ULong
XK_g                            : extern const ULong
XK_h                            : extern const ULong
XK_i                            : extern const ULong
XK_j                            : extern const ULong
XK_k                            : extern const ULong
XK_l                            : extern const ULong
XK_m                            : extern const ULong
XK_n                            : extern const ULong
XK_o                            : extern const ULong
XK_p                            : extern const ULong
XK_q                            : extern const ULong
XK_r                            : extern const ULong
XK_s                            : extern const ULong
XK_t                            : extern const ULong
XK_u                            : extern const ULong
XK_v                            : extern const ULong
XK_w                            : extern const ULong
XK_x                            : extern const ULong
XK_y                            : extern const ULong
XK_z                            : extern const ULong
XK_braceleft                    : extern const ULong
XK_bar                          : extern const ULong
XK_braceright                   : extern const ULong
XK_asciitilde                   : extern const ULong

XK_EcuSign                   : extern const ULong
XK_ColonSign                 : extern const ULong
XK_CruzeiroSign              : extern const ULong
XK_FFrancSign                : extern const ULong
XK_LiraSign                  : extern const ULong
XK_MillSign                  : extern const ULong
XK_NairaSign                 : extern const ULong
XK_PesetaSign                : extern const ULong
XK_RupeeSign                 : extern const ULong
XK_WonSign                   : extern const ULong
XK_NewSheqelSign             : extern const ULong
XK_DongSign                  : extern const ULong
XK_EuroSign                     : extern const ULong

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
