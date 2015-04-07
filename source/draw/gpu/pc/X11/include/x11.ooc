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

/*
 * TTY function keys, cleverly chosen to map to ASCII, for convenience of
 * programming, but could have been arbitrary (at the cost of lookup
 * tables in client code).
 */

XK_BackSpace                    : extern const ULong
XK_BackSpace                    : extern const ULong
XK_Tab                          : extern const ULong
XK_Tab                          : extern const ULong
XK_Linefeed                     : extern const ULong
XK_Linefeed                     : extern const ULong
XK_Clear                        : extern const ULong
XK_Clear                        : extern const ULong
XK_Return                       : extern const ULong
XK_Return                       : extern const ULong
XK_Pause                        : extern const ULong
XK_Pause                        : extern const ULong
XK_Scroll_Lock                  : extern const ULong
XK_Scroll_Lock                  : extern const ULong
XK_Sys_Req                      : extern const ULong
XK_Sys_Req                      : extern const ULong
XK_Escape                       : extern const ULong
XK_Escape                       : extern const ULong
XK_Delete                       : extern const ULong
XK_Delete                       : extern const ULong

/* Cursor control & motion */

XK_Home                         : extern const ULong
XK_Home                         : extern const ULong
XK_Left                         : extern const ULong
XK_Left                         : extern const ULong
XK_Up                           : extern const ULong
XK_Up                           : extern const ULong
XK_Right                        : extern const ULong
XK_Right                        : extern const ULong
XK_Down                         : extern const ULong
XK_Down                         : extern const ULong
XK_Prior                        : extern const ULong
XK_Prior                        : extern const ULong
XK_Page_Up                      : extern const ULong
XK_Page_Up                      : extern const ULong
XK_Next                         : extern const ULong
XK_Next                         : extern const ULong
XK_Page_Down                    : extern const ULong
XK_Page_Down                    : extern const ULong
XK_End                          : extern const ULong
XK_End                          : extern const ULong
XK_Begin                        : extern const ULong
XK_Begin                        : extern const ULong

/* Misc functions */

XK_Select                       : extern const ULong
XK_Select                       : extern const ULong
XK_Print                        : extern const ULong
XK_Print                        : extern const ULong
XK_Execute                      : extern const ULong
XK_Execute                      : extern const ULong
XK_Insert                       : extern const ULong
XK_Insert                       : extern const ULong
XK_Undo                         : extern const ULong
XK_Undo                         : extern const ULong
XK_Redo                         : extern const ULong
XK_Redo                         : extern const ULong
XK_Menu                         : extern const ULong
XK_Menu                         : extern const ULong
XK_Find                         : extern const ULong
XK_Find                         : extern const ULong
XK_Cancel                       : extern const ULong
XK_Cancel                       : extern const ULong
XK_Help                         : extern const ULong
XK_Help                         : extern const ULong
XK_Break                        : extern const ULong
XK_Break                        : extern const ULong
XK_Mode_switch                  : extern const ULong
XK_Mode_switch                  : extern const ULong
XK_script_switch                : extern const ULong
XK_script_switch                : extern const ULong
XK_Num_Lock                     : extern const ULong
XK_Num_Lock                     : extern const ULong

/* Keypad functions, keypad numbers cleverly chosen to map to ASCII */

XK_KP_Space                     : extern const ULong
XK_KP_Space                     : extern const ULong
XK_KP_Tab                       : extern const ULong
XK_KP_Tab                       : extern const ULong
XK_KP_Enter                     : extern const ULong
XK_KP_Enter                     : extern const ULong
XK_KP_F1                        : extern const ULong
XK_KP_F1                        : extern const ULong
XK_KP_F2                        : extern const ULong
XK_KP_F2                        : extern const ULong
XK_KP_F3                        : extern const ULong
XK_KP_F3                        : extern const ULong
XK_KP_F4                        : extern const ULong
XK_KP_F4                        : extern const ULong
XK_KP_Home                      : extern const ULong
XK_KP_Home                      : extern const ULong
XK_KP_Left                      : extern const ULong
XK_KP_Left                      : extern const ULong
XK_KP_Up                        : extern const ULong
XK_KP_Up                        : extern const ULong
XK_KP_Right                     : extern const ULong
XK_KP_Right                     : extern const ULong
XK_KP_Down                      : extern const ULong
XK_KP_Down                      : extern const ULong
XK_KP_Prior                     : extern const ULong
XK_KP_Prior                     : extern const ULong
XK_KP_Page_Up                   : extern const ULong
XK_KP_Page_Up                   : extern const ULong
XK_KP_Next                      : extern const ULong
XK_KP_Next                      : extern const ULong
XK_KP_Page_Down                 : extern const ULong
XK_KP_Page_Down                 : extern const ULong
XK_KP_End                       : extern const ULong
XK_KP_End                       : extern const ULong
XK_KP_Begin                     : extern const ULong
XK_KP_Begin                     : extern const ULong
XK_KP_Insert                    : extern const ULong
XK_KP_Insert                    : extern const ULong
XK_KP_Delete                    : extern const ULong
XK_KP_Delete                    : extern const ULong
XK_KP_Equal                     : extern const ULong
XK_KP_Equal                     : extern const ULong
XK_KP_Multiply                  : extern const ULong
XK_KP_Multiply                  : extern const ULong
XK_KP_Add                       : extern const ULong
XK_KP_Add                       : extern const ULong
XK_KP_Separator                 : extern const ULong
XK_KP_Separator                 : extern const ULong
XK_KP_Subtract                  : extern const ULong
XK_KP_Subtract                  : extern const ULong
XK_KP_Decimal                   : extern const ULong
XK_KP_Decimal                   : extern const ULong
XK_KP_Divide                    : extern const ULong
XK_KP_Divide                    : extern const ULong

XK_KP_0                         : extern const ULong
XK_KP_0                         : extern const ULong
XK_KP_1                         : extern const ULong
XK_KP_1                         : extern const ULong
XK_KP_2                         : extern const ULong
XK_KP_2                         : extern const ULong
XK_KP_3                         : extern const ULong
XK_KP_3                         : extern const ULong
XK_KP_4                         : extern const ULong
XK_KP_4                         : extern const ULong
XK_KP_5                         : extern const ULong
XK_KP_5                         : extern const ULong
XK_KP_6                         : extern const ULong
XK_KP_6                         : extern const ULong
XK_KP_7                         : extern const ULong
XK_KP_7                         : extern const ULong
XK_KP_8                         : extern const ULong
XK_KP_8                         : extern const ULong
XK_KP_9                         : extern const ULong
XK_KP_9                         : extern const ULong

/*
 * Auxiliary functions; note the duplicate definitions for left and right
 * function keys;  Sun keyboards and a few other manufacturers have such
 * function key groups on the left and/or right sides of the keyboard.
 * We've not found a keyboard with more than 35 function keys total.
 */

XK_F1                           : extern const ULong
XK_F1                           : extern const ULong
XK_F2                           : extern const ULong
XK_F2                           : extern const ULong
XK_F3                           : extern const ULong
XK_F3                           : extern const ULong
XK_F4                           : extern const ULong
XK_F4                           : extern const ULong
XK_F5                           : extern const ULong
XK_F5                           : extern const ULong
XK_F6                           : extern const ULong
XK_F6                           : extern const ULong
XK_F7                           : extern const ULong
XK_F7                           : extern const ULong
XK_F8                           : extern const ULong
XK_F8                           : extern const ULong
XK_F9                           : extern const ULong
XK_F9                           : extern const ULong
XK_F10                          : extern const ULong
XK_F10                          : extern const ULong
XK_F11                          : extern const ULong
XK_F11                          : extern const ULong
XK_L1                           : extern const ULong
XK_L1                           : extern const ULong
XK_F12                          : extern const ULong
XK_F12                          : extern const ULong
XK_L2                           : extern const ULong
XK_L2                           : extern const ULong
XK_F13                          : extern const ULong
XK_F13                          : extern const ULong
XK_L3                           : extern const ULong
XK_L3                           : extern const ULong
XK_F14                          : extern const ULong
XK_F14                          : extern const ULong
XK_L4                           : extern const ULong
XK_L4                           : extern const ULong
XK_F15                          : extern const ULong
XK_F15                          : extern const ULong
XK_L5                           : extern const ULong
XK_L5                           : extern const ULong
XK_F16                          : extern const ULong
XK_F16                          : extern const ULong
XK_L6                           : extern const ULong
XK_L6                           : extern const ULong
XK_F17                          : extern const ULong
XK_F17                          : extern const ULong
XK_L7                           : extern const ULong
XK_L7                           : extern const ULong
XK_F18                          : extern const ULong
XK_F18                          : extern const ULong
XK_L8                           : extern const ULong
XK_L8                           : extern const ULong
XK_F19                          : extern const ULong
XK_F19                          : extern const ULong
XK_L9                           : extern const ULong
XK_L9                           : extern const ULong
XK_F20                          : extern const ULong
XK_F20                          : extern const ULong
XK_L10                          : extern const ULong
XK_L10                          : extern const ULong
XK_F21                          : extern const ULong
XK_F21                          : extern const ULong
XK_R1                           : extern const ULong
XK_R1                           : extern const ULong
XK_F22                          : extern const ULong
XK_F22                          : extern const ULong
XK_R2                           : extern const ULong
XK_R2                           : extern const ULong
XK_F23                          : extern const ULong
XK_F23                          : extern const ULong
XK_R3                           : extern const ULong
XK_R3                           : extern const ULong
XK_F24                          : extern const ULong
XK_F24                          : extern const ULong
XK_R4                           : extern const ULong
XK_R4                           : extern const ULong
XK_F25                          : extern const ULong
XK_F25                          : extern const ULong
XK_R5                           : extern const ULong
XK_R5                           : extern const ULong
XK_F26                          : extern const ULong
XK_F26                          : extern const ULong
XK_R6                           : extern const ULong
XK_R6                           : extern const ULong
XK_F27                          : extern const ULong
XK_F27                          : extern const ULong
XK_R7                           : extern const ULong
XK_R7                           : extern const ULong
XK_F28                          : extern const ULong
XK_F28                          : extern const ULong
XK_R8                           : extern const ULong
XK_R8                           : extern const ULong
XK_F29                          : extern const ULong
XK_F29                          : extern const ULong
XK_R9                           : extern const ULong
XK_R9                           : extern const ULong
XK_F30                          : extern const ULong
XK_F30                          : extern const ULong
XK_R10                          : extern const ULong
XK_R10                          : extern const ULong
XK_F31                          : extern const ULong
XK_F31                          : extern const ULong
XK_R11                          : extern const ULong
XK_R11                          : extern const ULong
XK_F32                          : extern const ULong
XK_F32                          : extern const ULong
XK_R12                          : extern const ULong
XK_R12                          : extern const ULong
XK_F33                          : extern const ULong
XK_F33                          : extern const ULong
XK_R13                          : extern const ULong
XK_R13                          : extern const ULong
XK_F34                          : extern const ULong
XK_F34                          : extern const ULong
XK_R14                          : extern const ULong
XK_R14                          : extern const ULong
XK_F35                          : extern const ULong
XK_F35                          : extern const ULong
XK_R15                          : extern const ULong
XK_R15                          : extern const ULong

/* Modifiers */

XK_Shift_L                      : extern const ULong
XK_Shift_L                      : extern const ULong
XK_Shift_R                      : extern const ULong
XK_Shift_R                      : extern const ULong
XK_Control_L                    : extern const ULong
XK_Control_L                    : extern const ULong
XK_Control_R                    : extern const ULong
XK_Control_R                    : extern const ULong
XK_Caps_Lock                    : extern const ULong
XK_Caps_Lock                    : extern const ULong
XK_Shift_Lock                   : extern const ULong
XK_Shift_Lock                   : extern const ULong

XK_Meta_L                       : extern const ULong
XK_Meta_L                       : extern const ULong
XK_Meta_R                       : extern const ULong
XK_Meta_R                       : extern const ULong
XK_Alt_L                        : extern const ULong
XK_Alt_L                        : extern const ULong
XK_Alt_R                        : extern const ULong
XK_Alt_R                        : extern const ULong
XK_Super_L                      : extern const ULong
XK_Super_L                      : extern const ULong
XK_Super_R                      : extern const ULong
XK_Super_R                      : extern const ULong
XK_Hyper_L                      : extern const ULong
XK_Hyper_L                      : extern const ULong
XK_Hyper_R                      : extern const ULong
XK_Hyper_R                      : extern const ULong

/*
 * 3270 Terminal Keys
 * Byte 3 = 0xfd
 */

XK_3270_Duplicate               : extern const ULong
XK_3270_Duplicate               : extern const ULong
XK_3270_FieldMark               : extern const ULong
XK_3270_FieldMark               : extern const ULong
XK_3270_Right2                  : extern const ULong
XK_3270_Right2                  : extern const ULong
XK_3270_Left2                   : extern const ULong
XK_3270_Left2                   : extern const ULong
XK_3270_BackTab                 : extern const ULong
XK_3270_BackTab                 : extern const ULong
XK_3270_EraseEOF                : extern const ULong
XK_3270_EraseEOF                : extern const ULong
XK_3270_EraseInput              : extern const ULong
XK_3270_EraseInput              : extern const ULong
XK_3270_Reset                   : extern const ULong
XK_3270_Reset                   : extern const ULong
XK_3270_Quit                    : extern const ULong
XK_3270_Quit                    : extern const ULong
XK_3270_PA1                     : extern const ULong
XK_3270_PA1                     : extern const ULong
XK_3270_PA2                     : extern const ULong
XK_3270_PA2                     : extern const ULong
XK_3270_PA3                     : extern const ULong
XK_3270_PA3                     : extern const ULong
XK_3270_Test                    : extern const ULong
XK_3270_Test                    : extern const ULong
XK_3270_Attn                    : extern const ULong
XK_3270_Attn                    : extern const ULong
XK_3270_CursorBlink             : extern const ULong
XK_3270_CursorBlink             : extern const ULong
XK_3270_AltCursor               : extern const ULong
XK_3270_AltCursor               : extern const ULong
XK_3270_KeyClick                : extern const ULong
XK_3270_KeyClick                : extern const ULong
XK_3270_Jump                    : extern const ULong
XK_3270_Jump                    : extern const ULong
XK_3270_Ident                   : extern const ULong
XK_3270_Ident                   : extern const ULong
XK_3270_Rule                    : extern const ULong
XK_3270_Rule                    : extern const ULong
XK_3270_Copy                    : extern const ULong
XK_3270_Copy                    : extern const ULong
XK_3270_Play                    : extern const ULong
XK_3270_Play                    : extern const ULong
XK_3270_Setup                   : extern const ULong
XK_3270_Setup                   : extern const ULong
XK_3270_Record                  : extern const ULong
XK_3270_Record                  : extern const ULong
XK_3270_ChangeScreen            : extern const ULong
XK_3270_ChangeScreen            : extern const ULong
XK_3270_DeleteWord              : extern const ULong
XK_3270_DeleteWord              : extern const ULong
XK_3270_ExSelect                : extern const ULong
XK_3270_ExSelect                : extern const ULong
XK_3270_CursorSelect            : extern const ULong
XK_3270_CursorSelect            : extern const ULong
XK_3270_PrintScreen             : extern const ULong
XK_3270_PrintScreen             : extern const ULong
XK_3270_Enter                   : extern const ULong
XK_3270_Enter                   : extern const ULong

/*
 * Latin 1
 * (ISO/IEC 8859-1 = Unicode U+0020..U+00FF)
 * Byte 3 = 0
 */
XK_space                        : extern const ULong
XK_space                        : extern const ULong
XK_exclam                       : extern const ULong
XK_exclam                       : extern const ULong
XK_quotedbl                     : extern const ULong
XK_quotedbl                     : extern const ULong
XK_numbersign                   : extern const ULong
XK_numbersign                   : extern const ULong
XK_dollar                       : extern const ULong
XK_dollar                       : extern const ULong
XK_percent                      : extern const ULong
XK_percent                      : extern const ULong
XK_ampersand                    : extern const ULong
XK_ampersand                    : extern const ULong
XK_apostrophe                   : extern const ULong
XK_apostrophe                   : extern const ULong
XK_quoteright                   : extern const ULong
XK_quoteright                   : extern const ULong
XK_parenleft                    : extern const ULong
XK_parenleft                    : extern const ULong
XK_parenright                   : extern const ULong
XK_parenright                   : extern const ULong
XK_asterisk                     : extern const ULong
XK_asterisk                     : extern const ULong
XK_plus                         : extern const ULong
XK_plus                         : extern const ULong
XK_comma                        : extern const ULong
XK_comma                        : extern const ULong
XK_minus                        : extern const ULong
XK_minus                        : extern const ULong
XK_period                       : extern const ULong
XK_period                       : extern const ULong
XK_slash                        : extern const ULong
XK_slash                        : extern const ULong
XK_0                            : extern const ULong
XK_0                            : extern const ULong
XK_1                            : extern const ULong
XK_1                            : extern const ULong
XK_2                            : extern const ULong
XK_2                            : extern const ULong
XK_3                            : extern const ULong
XK_3                            : extern const ULong
XK_4                            : extern const ULong
XK_4                            : extern const ULong
XK_5                            : extern const ULong
XK_5                            : extern const ULong
XK_6                            : extern const ULong
XK_6                            : extern const ULong
XK_7                            : extern const ULong
XK_7                            : extern const ULong
XK_8                            : extern const ULong
XK_8                            : extern const ULong
XK_9                            : extern const ULong
XK_9                            : extern const ULong
XK_colon                        : extern const ULong
XK_colon                        : extern const ULong
XK_semicolon                    : extern const ULong
XK_semicolon                    : extern const ULong
XK_less                         : extern const ULong
XK_less                         : extern const ULong
XK_equal                        : extern const ULong
XK_equal                        : extern const ULong
XK_greater                      : extern const ULong
XK_greater                      : extern const ULong
XK_question                     : extern const ULong
XK_question                     : extern const ULong
XK_at                           : extern const ULong
XK_at                           : extern const ULong
XK_A                            : extern const ULong
XK_A                            : extern const ULong
XK_B                            : extern const ULong
XK_B                            : extern const ULong
XK_C                            : extern const ULong
XK_C                            : extern const ULong
XK_D                            : extern const ULong
XK_D                            : extern const ULong
XK_E                            : extern const ULong
XK_E                            : extern const ULong
XK_F                            : extern const ULong
XK_F                            : extern const ULong
XK_G                            : extern const ULong
XK_G                            : extern const ULong
XK_H                            : extern const ULong
XK_H                            : extern const ULong
XK_I                            : extern const ULong
XK_I                            : extern const ULong
XK_J                            : extern const ULong
XK_J                            : extern const ULong
XK_K                            : extern const ULong
XK_K                            : extern const ULong
XK_L                            : extern const ULong
XK_L                            : extern const ULong
XK_M                            : extern const ULong
XK_M                            : extern const ULong
XK_N                            : extern const ULong
XK_N                            : extern const ULong
XK_O                            : extern const ULong
XK_O                            : extern const ULong
XK_P                            : extern const ULong
XK_P                            : extern const ULong
XK_Q                            : extern const ULong
XK_Q                            : extern const ULong
XK_R                            : extern const ULong
XK_R                            : extern const ULong
XK_S                            : extern const ULong
XK_S                            : extern const ULong
XK_T                            : extern const ULong
XK_T                            : extern const ULong
XK_U                            : extern const ULong
XK_U                            : extern const ULong
XK_V                            : extern const ULong
XK_V                            : extern const ULong
XK_W                            : extern const ULong
XK_W                            : extern const ULong
XK_X                            : extern const ULong
XK_X                            : extern const ULong
XK_Y                            : extern const ULong
XK_Y                            : extern const ULong
XK_Z                            : extern const ULong
XK_Z                            : extern const ULong
XK_bracketleft                  : extern const ULong
XK_bracketleft                  : extern const ULong
XK_backslash                    : extern const ULong
XK_backslash                    : extern const ULong
XK_bracketright                 : extern const ULong
XK_bracketright                 : extern const ULong
XK_asciicircum                  : extern const ULong
XK_asciicircum                  : extern const ULong
XK_underscore                   : extern const ULong
XK_underscore                   : extern const ULong
XK_grave                        : extern const ULong
XK_grave                        : extern const ULong
XK_quoteleft                    : extern const ULong
XK_quoteleft                    : extern const ULong
XK_a                            : extern const ULong
XK_a                            : extern const ULong
XK_b                            : extern const ULong
XK_b                            : extern const ULong
XK_c                            : extern const ULong
XK_c                            : extern const ULong
XK_d                            : extern const ULong
XK_d                            : extern const ULong
XK_e                            : extern const ULong
XK_e                            : extern const ULong
XK_f                            : extern const ULong
XK_f                            : extern const ULong
XK_g                            : extern const ULong
XK_g                            : extern const ULong
XK_h                            : extern const ULong
XK_h                            : extern const ULong
XK_i                            : extern const ULong
XK_i                            : extern const ULong
XK_j                            : extern const ULong
XK_j                            : extern const ULong
XK_k                            : extern const ULong
XK_k                            : extern const ULong
XK_l                            : extern const ULong
XK_l                            : extern const ULong
XK_m                            : extern const ULong
XK_m                            : extern const ULong
XK_n                            : extern const ULong
XK_n                            : extern const ULong
XK_o                            : extern const ULong
XK_o                            : extern const ULong
XK_p                            : extern const ULong
XK_p                            : extern const ULong
XK_q                            : extern const ULong
XK_q                            : extern const ULong
XK_r                            : extern const ULong
XK_r                            : extern const ULong
XK_s                            : extern const ULong
XK_s                            : extern const ULong
XK_t                            : extern const ULong
XK_t                            : extern const ULong
XK_u                            : extern const ULong
XK_u                            : extern const ULong
XK_v                            : extern const ULong
XK_v                            : extern const ULong
XK_w                            : extern const ULong
XK_w                            : extern const ULong
XK_x                            : extern const ULong
XK_x                            : extern const ULong
XK_y                            : extern const ULong
XK_y                            : extern const ULong
XK_z                            : extern const ULong
XK_z                            : extern const ULong
XK_braceleft                    : extern const ULong
XK_braceleft                    : extern const ULong
XK_bar                          : extern const ULong
XK_bar                          : extern const ULong
XK_braceright                   : extern const ULong
XK_braceright                   : extern const ULong
XK_asciitilde                   : extern const ULong
XK_asciitilde                   : extern const ULong

XK_EcuSign                   : extern const ULong
XK_EcuSign                   : extern const ULong
XK_ColonSign                 : extern const ULong
XK_ColonSign                 : extern const ULong
XK_CruzeiroSign              : extern const ULong
XK_CruzeiroSign              : extern const ULong
XK_FFrancSign                : extern const ULong
XK_FFrancSign                : extern const ULong
XK_LiraSign                  : extern const ULong
XK_LiraSign                  : extern const ULong
XK_MillSign                  : extern const ULong
XK_MillSign                  : extern const ULong
XK_NairaSign                 : extern const ULong
XK_NairaSign                 : extern const ULong
XK_PesetaSign                : extern const ULong
XK_PesetaSign                : extern const ULong
XK_RupeeSign                 : extern const ULong
XK_RupeeSign                 : extern const ULong
XK_WonSign                   : extern const ULong
XK_WonSign                   : extern const ULong
XK_NewSheqelSign             : extern const ULong
XK_NewSheqelSign             : extern const ULong
XK_DongSign                  : extern const ULong
XK_DongSign                  : extern const ULong
XK_EuroSign                     : extern const ULong
XK_EuroSign                     : extern const ULong
