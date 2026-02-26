//
//  Character+ascii.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-24.
//

import clibvim

public extension Character {
    // We generally prefer to use the constants defined in C code (in this
    // case ascii.h), but these were defined as single-quoted octals (i.e '\001')
    // which Swift seems to ignore.
    static let nul: Self            = "\u{0000}" // Null character
    static let bell: Self           = "\u{0007}" // Bell character (BEL)
    static let backspace: Self      = "\u{0008}" // Backspace character (BS)
    static let tab: Self            = "\u{0009}" // Horizontal tab character (TAB)
    static let newLine: Self        = "\u{000A}" // Newline character (LF)
    static let formFeed: Self       = "\u{000C}" // Form feed character (FF)
    static let carriageReturn: Self = "\u{000D}" // Carriage return character (CR)
    static let escape: Self         = "\u{001B}" // Escape character (ESC)
    static let delete: Self         = "\u{007F}" // Delete character (DEL)
    static let pound: Self          = "\u{00A3}" // Pound sign (#)

    static let controlAt                 = Self(clibvim.Ctrl_AT)
    static let controlA                  = Self(clibvim.Ctrl_A)
    static let controlB                  = Self(clibvim.Ctrl_B)
    static let controlC                  = Self(clibvim.Ctrl_C)
    static let controlD                  = Self(clibvim.Ctrl_D)
    static let controlE                  = Self(clibvim.Ctrl_E)
    static let controlF                  = Self(clibvim.Ctrl_F)
    static let controlG                  = Self(clibvim.Ctrl_G)
    static let controlH                  = Self(clibvim.Ctrl_H)
    static let controlI                  = Self(clibvim.Ctrl_I)
    static let controlJ                  = Self(clibvim.Ctrl_J)
    static let controlK                  = Self(clibvim.Ctrl_K)
    static let controlL                  = Self(clibvim.Ctrl_L)
    static let controlM                  = Self(clibvim.Ctrl_M)
    static let controlN                  = Self(clibvim.Ctrl_N)
    static let controlO                  = Self(clibvim.Ctrl_O)
    static let controlP                  = Self(clibvim.Ctrl_P)
    static let controlQ                  = Self(clibvim.Ctrl_Q)
    static let controlR                  = Self(clibvim.Ctrl_R)
    static let controlS                  = Self(clibvim.Ctrl_S)
    static let controlT                  = Self(clibvim.Ctrl_T)
    static let controlU                  = Self(clibvim.Ctrl_U)
    static let controlV                  = Self(clibvim.Ctrl_V)
    static let controlW                  = Self(clibvim.Ctrl_W)
    static let controlX                  = Self(clibvim.Ctrl_X)
    static let controlY                  = Self(clibvim.Ctrl_Y)
    static let controlZ                  = Self(clibvim.Ctrl_Z)
    static let controlBackslash          = Self(clibvim.Ctrl_BSL)
    static let controlRightSquareBracket = Self(clibvim.Ctrl_RSB)
    static let controlHat                = Self(clibvim.Ctrl_HAT)
    static let controlUnderscore         = Self(clibvim.Ctrl__)
}
