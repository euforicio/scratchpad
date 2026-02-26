//
//  types.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-24.
//

import clibvim

public enum Vim {}

// When defining types in a public extension they are public by default; while
// in the public enum above they would've still been internal by default.
public extension Vim {
    enum EndOfLineFormat: RawRepresentable {
        public typealias RawValue = CInt

        case unknown, // not defined yet
             unix,    // NL
             dos,     // CR NL
             mac      // CR

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case clibvim.EOL_UNKNOWN: .unknown
            case clibvim.EOL_UNIX: .unix
            case clibvim.EOL_DOS: .dos
            case clibvim.EOL_MAC: .mac
            default: nil
            }

            guard let value else { return nil }
            self = value
        }

        public var rawValue: RawValue {
            switch self {
            case .unknown: clibvim.EOL_UNKNOWN
            case .unix: clibvim.EOL_UNIX
            case .dos: clibvim.EOL_DOS
            case .mac: clibvim.EOL_MAC
            }
        }
    }

    // MARK: - Buffer

    // TODO: Wrap in RawRepresentable struct
    typealias Buffer = UnsafeMutablePointer<buf_T>

    struct BufferUpdate: RawRepresentable {
        public typealias RawValue = bufferUpdate_T

        public let buf: Buffer
        public let lnum: LineNumber  // first line with change
        public let lnume: LineNumber // line below last changed line
        public let xtra: Int         // number of extra lines (negative when deleting)

        public init?(rawValue: RawValue) {
            buf = rawValue.buf
            lnum = rawValue.lnum
            lnume = rawValue.lnume
            xtra = Int(rawValue.xtra)
        }

        public var rawValue: RawValue {
            .init(buf: buf,
                  lnum: lnum,
                  lnume: lnume,
                  xtra: CLong(xtra))
        }
    }

    // MARK: - Events for autocommands.

    enum Event: RawRepresentable {
        public typealias RawValue = event_T

        case bufAdd,               // after adding a buffer to the buffer list
             bufDelete,            // deleting a buffer from the buffer list
             bufEnter,             // after entering a buffer
             bufFilePost,          // after renaming a buffer
             bufFilePre,           // before renaming a buffer
             bufHidden,            // just after buffer becomes hidden
             bufLeave,             // before leaving a buffer
             bufNew,               // after creating any buffer
             bufNewFile,           // when creating a buffer for a new file
             bufReadCmd,           // read buffer using command
             bufReadPost,          // after reading a buffer
             bufReadPre,           // before reading a buffer
             bufUnload,            // just before unloading a buffer
             bufWinEnter,          // after showing a buffer in a window
             bufWinLeave,          // just after buffer removed from window
             bufWipeOut,           // just before really deleting a buffer
             bufWriteCmd,          // write buffer using command
             bufWritePost,         // after writing a buffer
             bufWritePre,          // before writing a buffer
             cmdLineChanged,       // command line was modified
             cmdLineEnter,         // after entering the command line
             cmdLineLeave,         // before leaving the command line
             cmdUndefined,         // command undefined
             cmdWinEnter,          // after entering the cmdline window
             cmdWinLeave,          // before leaving the cmdline window
             colorScheme,          // after loading a colorscheme
             colorSchemePre,       // before loading a colorscheme
             completeChanged,      // after completion popup menu changed
             completeDone,         // after finishing insert complete
             cursorHold,           // cursor in same position for a while
             cursorHoldI,          // idem, in Insert mode
             cursorMoved,          // cursor was moved
             cursorMovedI,         // cursor was moved in Insert mode
             diffUpdated,          // after diffs were updated
             dirChanged,           // after user changed directory
             encodingChanged,      // after changing the 'encoding' option
             exitPre,              // before exiting
             fileAppendCmd,        // append to a file using command
             fileAppendPost,       // after appending to a file
             fileAppendPre,        // before appending to a file
             fileChangedRO,        // before first change to read-only file
             fileChangedShell,     // after shell command that changed file
             fileChangedShellPost, // after (not) reloading changed file
             fileReadCmd,          // read from a file using command
             fileReadPost,         // after reading a file
             fileReadPre,          // before reading a file
             fileType,             // new file type detected (user defined)
             fileWriteCmd,         // write to a file using command
             fileWritePost,        // after writing a file
             fileWritePre,         // before writing a file
             filterReadPost,       // after reading from a filter
             filterReadPre,        // before reading from a filter
             filterWritePost,      // after writing to a filter
             filterWritePre,       // before writing to a filter
             focusGained,          // got the focus
             focusLost,            // lost the focus to another app
             funcUndefined,        // if calling a function which doesn't exist
             guiEnter,             // after starting the GUI
             guiFailed,            // after starting the GUI failed
             insertChange,         // when changing Insert/Replace mode
             insertCharPre,        // before inserting a char
             insertEnter,          // when entering Insert mode
             insertLeave,          // when leaving Insert mode
             menuPopup,            // just before popup menu is displayed
             optionSet,            // option was set
             quickFixCmdPost,      // after :make, :grep etc.
             quickFixCmdPre,       // before :make, :grep etc.
             quitPre,              // before :quit
             remoteReply,          // upon string reception from a remote vim
             sessionLoadPost,      // after loading a session file
             shellCmdPost,         // after ":!cmd"
             shellFilterPost,      // after ":1,2!cmd", ":w !cmd", ":r !cmd".
             sourceCmd,            // sourcing a Vim script using command
             sourcePre,            // before sourcing a Vim script
             sourcePost,           // after sourcing a Vim script
             spellFileMissing,     // spell file missing
             stdinReadPost,        // after reading from stdin
             stdinReadPre,         // before reading from stdin
             swapExists,           // found existing swap file
             syntax,               // syntax selected
             tabClosed,            // after closing a tab page
             tabEnter,             // after entering a tab page
             tabLeave,             // before leaving a tab page
             tabNew,               // when entering a new tab page
             termChanged,          // after changing 'term'
             terminalOpen,         // after a terminal buffer was created
             termResponse,         // after setting "v:termresponse"
             textChanged,          // text was modified not in Insert mode
             textChangedI,         // text was modified in Insert mode
             textChangedP,         // TextChangedI with popup menu visible
             textYankPost,         // after some text was yanked
             user,                 // user defined autocommand
             vimEnter,             // after starting Vim
             vimLeave,             // before exiting Vim
             vimLeavePre,          // before exiting Vim and writing .viminfo
             vimResized,           // after Vim window was resized
             winEnter,             // after entering a window
             winLeave,             // before leaving a window
             winNew,               // when entering a new window
             // MUST be the last one
             numEvents

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case EVENT_BUFADD:               .bufAdd
            case EVENT_BUFDELETE:            .bufDelete
            case EVENT_BUFENTER:             .bufEnter
            case EVENT_BUFFILEPOST:          .bufFilePost
            case EVENT_BUFFILEPRE:           .bufFilePre
            case EVENT_BUFHIDDEN:            .bufHidden
            case EVENT_BUFLEAVE:             .bufLeave
            case EVENT_BUFNEW:               .bufNew
            case EVENT_BUFNEWFILE:           .bufNewFile
            case EVENT_BUFREADCMD:           .bufReadCmd
            case EVENT_BUFREADPOST:          .bufReadPost
            case EVENT_BUFREADPRE:           .bufReadPre
            case EVENT_BUFUNLOAD:            .bufUnload
            case EVENT_BUFWINENTER:          .bufWinEnter
            case EVENT_BUFWINLEAVE:          .bufWinLeave
            case EVENT_BUFWIPEOUT:           .bufWipeOut
            case EVENT_BUFWRITECMD:          .bufWriteCmd
            case EVENT_BUFWRITEPOST:         .bufWritePost
            case EVENT_BUFWRITEPRE:          .bufWritePre
            case EVENT_CMDLINECHANGED:       .cmdLineChanged
            case EVENT_CMDLINEENTER:         .cmdLineEnter
            case EVENT_CMDLINELEAVE:         .cmdLineLeave
            case EVENT_CMDUNDEFINED:         .cmdUndefined
            case EVENT_CMDWINENTER:          .cmdWinEnter
            case EVENT_CMDWINLEAVE:          .cmdWinLeave
            case EVENT_COLORSCHEME:          .colorScheme
            case EVENT_COLORSCHEMEPRE:       .colorSchemePre
            case EVENT_COMPLETECHANGED:      .completeChanged
            case EVENT_COMPLETEDONE:         .completeDone
            case EVENT_CURSORHOLD:           .cursorHold
            case EVENT_CURSORHOLDI:          .cursorHoldI
            case EVENT_CURSORMOVED:          .cursorMoved
            case EVENT_CURSORMOVEDI:         .cursorMovedI
            case EVENT_DIFFUPDATED:          .diffUpdated
            case EVENT_DIRCHANGED:           .dirChanged
            case EVENT_ENCODINGCHANGED:      .encodingChanged
            case EVENT_EXITPRE:              .exitPre
            case EVENT_FILEAPPENDCMD:        .fileAppendCmd
            case EVENT_FILEAPPENDPOST:       .fileAppendPost
            case EVENT_FILEAPPENDPRE:        .fileAppendPre
            case EVENT_FILECHANGEDRO:        .fileChangedRO
            case EVENT_FILECHANGEDSHELL:     .fileChangedShell
            case EVENT_FILECHANGEDSHELLPOST: .fileChangedShellPost
            case EVENT_FILEREADCMD:          .fileReadCmd
            case EVENT_FILEREADPOST:         .fileReadPost
            case EVENT_FILEREADPRE:          .fileReadPre
            case EVENT_FILETYPE:             .fileType
            case EVENT_FILEWRITECMD:         .fileWriteCmd
            case EVENT_FILEWRITEPOST:        .fileWritePost
            case EVENT_FILEWRITEPRE:         .fileWritePre
            case EVENT_FILTERREADPOST:       .filterReadPost
            case EVENT_FILTERREADPRE:        .filterReadPre
            case EVENT_FILTERWRITEPOST:      .filterWritePost
            case EVENT_FILTERWRITEPRE:       .filterWritePre
            case EVENT_FOCUSGAINED:          .focusGained
            case EVENT_FOCUSLOST:            .focusLost
            case EVENT_FUNCUNDEFINED:        .funcUndefined
            case EVENT_GUIENTER:             .guiEnter
            case EVENT_GUIFAILED:            .guiFailed
            case EVENT_INSERTCHANGE:         .insertChange
            case EVENT_INSERTCHARPRE:        .insertCharPre
            case EVENT_INSERTENTER:          .insertEnter
            case EVENT_INSERTLEAVE:          .insertLeave
            case EVENT_MENUPOPUP:            .menuPopup
            case EVENT_OPTIONSET:            .optionSet
            case EVENT_QUICKFIXCMDPOST:      .quickFixCmdPost
            case EVENT_QUICKFIXCMDPRE:       .quickFixCmdPre
            case EVENT_QUITPRE:              .quitPre
            case EVENT_REMOTEREPLY:          .remoteReply
            case EVENT_SESSIONLOADPOST:      .sessionLoadPost
            case EVENT_SHELLCMDPOST:         .shellCmdPost
            case EVENT_SHELLFILTERPOST:      .shellFilterPost
            case EVENT_SOURCECMD:            .sourceCmd
            case EVENT_SOURCEPRE:            .sourcePre
            case EVENT_SOURCEPOST:           .sourcePost
            case EVENT_SPELLFILEMISSING:     .spellFileMissing
            case EVENT_STDINREADPOST:        .stdinReadPost
            case EVENT_STDINREADPRE:         .stdinReadPre
            case EVENT_SWAPEXISTS:           .swapExists
            case EVENT_SYNTAX:               .syntax
            case EVENT_TABCLOSED:            .tabClosed
            case EVENT_TABENTER:             .tabEnter
            case EVENT_TABLEAVE:             .tabLeave
            case EVENT_TABNEW:               .tabNew
            case EVENT_TERMCHANGED:          .termChanged
            case EVENT_TERMINALOPEN:         .terminalOpen
            case EVENT_TERMRESPONSE:         .termResponse
            case EVENT_TEXTCHANGED:          .textChanged
            case EVENT_TEXTCHANGEDI:         .textChangedI
            case EVENT_TEXTCHANGEDP:         .textChangedP
            case EVENT_TEXTYANKPOST:         .textYankPost
            case EVENT_USER:                 .user
            case EVENT_VIMENTER:             .vimEnter
            case EVENT_VIMLEAVE:             .vimLeave
            case EVENT_VIMLEAVEPRE:          .vimLeavePre
            case EVENT_VIMRESIZED:           .vimResized
            case EVENT_WINENTER:             .winEnter
            case EVENT_WINLEAVE:             .winLeave
            case EVENT_WINNEW:               .winNew
            case NUM_EVENTS:                 .numEvents
            default:                          nil
            }

            guard let value else { return nil }
            self = value
        }

        public var rawValue: RawValue {
            switch self {
            case .bufAdd:               EVENT_BUFADD
            case .bufDelete:            EVENT_BUFDELETE
            case .bufEnter:             EVENT_BUFENTER
            case .bufFilePost:          EVENT_BUFFILEPOST
            case .bufFilePre:           EVENT_BUFFILEPRE
            case .bufHidden:            EVENT_BUFHIDDEN
            case .bufLeave:             EVENT_BUFLEAVE
            case .bufNew:               EVENT_BUFNEW
            case .bufNewFile:           EVENT_BUFNEWFILE
            case .bufReadCmd:           EVENT_BUFREADCMD
            case .bufReadPost:          EVENT_BUFREADPOST
            case .bufReadPre:           EVENT_BUFREADPRE
            case .bufUnload:            EVENT_BUFUNLOAD
            case .bufWinEnter:          EVENT_BUFWINENTER
            case .bufWinLeave:          EVENT_BUFWINLEAVE
            case .bufWipeOut:           EVENT_BUFWIPEOUT
            case .bufWriteCmd:          EVENT_BUFWRITECMD
            case .bufWritePost:         EVENT_BUFWRITEPOST
            case .bufWritePre:          EVENT_BUFWRITEPRE
            case .cmdLineChanged:       EVENT_CMDLINECHANGED
            case .cmdLineEnter:         EVENT_CMDLINEENTER
            case .cmdLineLeave:         EVENT_CMDLINELEAVE
            case .cmdUndefined:         EVENT_CMDUNDEFINED
            case .cmdWinEnter:          EVENT_CMDWINENTER
            case .cmdWinLeave:          EVENT_CMDWINLEAVE
            case .colorScheme:          EVENT_COLORSCHEME
            case .colorSchemePre:       EVENT_COLORSCHEMEPRE
            case .completeChanged:      EVENT_COMPLETECHANGED
            case .completeDone:         EVENT_COMPLETEDONE
            case .cursorHold:           EVENT_CURSORHOLD
            case .cursorHoldI:          EVENT_CURSORHOLDI
            case .cursorMoved:          EVENT_CURSORMOVED
            case .cursorMovedI:         EVENT_CURSORMOVEDI
            case .diffUpdated:          EVENT_DIFFUPDATED
            case .dirChanged:           EVENT_DIRCHANGED
            case .encodingChanged:      EVENT_ENCODINGCHANGED
            case .exitPre:              EVENT_EXITPRE
            case .fileAppendCmd:        EVENT_FILEAPPENDCMD
            case .fileAppendPost:       EVENT_FILEAPPENDPOST
            case .fileAppendPre:        EVENT_FILEAPPENDPRE
            case .fileChangedRO:        EVENT_FILECHANGEDRO
            case .fileChangedShell:     EVENT_FILECHANGEDSHELL
            case .fileChangedShellPost: EVENT_FILECHANGEDSHELLPOST
            case .fileReadCmd:          EVENT_FILEREADCMD
            case .fileReadPost:         EVENT_FILEREADPOST
            case .fileReadPre:          EVENT_FILEREADPRE
            case .fileType:             EVENT_FILETYPE
            case .fileWriteCmd:         EVENT_FILEWRITECMD
            case .fileWritePost:        EVENT_FILEWRITEPOST
            case .fileWritePre:         EVENT_FILEWRITEPRE
            case .filterReadPost:       EVENT_FILTERREADPOST
            case .filterReadPre:        EVENT_FILTERREADPRE
            case .filterWritePost:      EVENT_FILTERWRITEPOST
            case .filterWritePre:       EVENT_FILTERWRITEPRE
            case .focusGained:          EVENT_FOCUSGAINED
            case .focusLost:            EVENT_FOCUSLOST
            case .funcUndefined:        EVENT_FUNCUNDEFINED
            case .guiEnter:             EVENT_GUIENTER
            case .guiFailed:            EVENT_GUIFAILED
            case .insertChange:         EVENT_INSERTCHANGE
            case .insertCharPre:        EVENT_INSERTCHARPRE
            case .insertEnter:          EVENT_INSERTENTER
            case .insertLeave:          EVENT_INSERTLEAVE
            case .menuPopup:            EVENT_MENUPOPUP
            case .optionSet:            EVENT_OPTIONSET
            case .quickFixCmdPost:      EVENT_QUICKFIXCMDPOST
            case .quickFixCmdPre:       EVENT_QUICKFIXCMDPRE
            case .quitPre:              EVENT_QUITPRE
            case .remoteReply:          EVENT_REMOTEREPLY
            case .sessionLoadPost:      EVENT_SESSIONLOADPOST
            case .shellCmdPost:         EVENT_SHELLCMDPOST
            case .shellFilterPost:      EVENT_SHELLFILTERPOST
            case .sourceCmd:            EVENT_SOURCECMD
            case .sourcePre:            EVENT_SOURCEPRE
            case .sourcePost:           EVENT_SOURCEPOST
            case .spellFileMissing:     EVENT_SPELLFILEMISSING
            case .stdinReadPost:        EVENT_STDINREADPOST
            case .stdinReadPre:         EVENT_STDINREADPRE
            case .swapExists:           EVENT_SWAPEXISTS
            case .syntax:               EVENT_SYNTAX
            case .tabClosed:            EVENT_TABCLOSED
            case .tabEnter:             EVENT_TABENTER
            case .tabLeave:             EVENT_TABLEAVE
            case .tabNew:               EVENT_TABNEW
            case .termChanged:          EVENT_TERMCHANGED
            case .terminalOpen:         EVENT_TERMINALOPEN
            case .termResponse:         EVENT_TERMRESPONSE
            case .textChanged:          EVENT_TEXTCHANGED
            case .textChangedI:         EVENT_TEXTCHANGEDI
            case .textChangedP:         EVENT_TEXTCHANGEDP
            case .textYankPost:         EVENT_TEXTYANKPOST
            case .user:                 EVENT_USER
            case .vimEnter:             EVENT_VIMENTER
            case .vimLeave:             EVENT_VIMLEAVE
            case .vimLeavePre:          EVENT_VIMLEAVEPRE
            case .vimResized:           EVENT_VIMRESIZED
            case .winEnter:             EVENT_WINENTER
            case .winLeave:             EVENT_WINLEAVE
            case .winNew:               EVENT_WINNEW
            case .numEvents:            NUM_EVENTS
            }
        }
    }

    // MARK: - Commandline

    struct ExCommand: RawRepresentable {
        public typealias RawValue = exCommand_T

        public let command: String
        public let forceIt: Bool
        public let regName: Int

        public init?(rawValue: RawValue) {
            command = String(cString: rawValue.cmd)
            forceIt = Bool(rawValue.forceit)
            regName = Int(rawValue.regname)
        }

        public var rawValue: RawValue {
            .init(
                cmd: command.uCString,
                forceit: CInt(forceIt),
                regname: CInt(regName)
            )
        }
    }

    // MARK: - Cursor

    static let MAXCOL = clibvim.MAXCOL

    enum ScreenLineMotion: RawRepresentable {
        case h, l, m

        public init?(rawValue: screenLineMotion_T) {
            let value: Self? = switch rawValue {
            case MOTION_H: .h
            case MOTION_L: .l
            case MOTION_M: .m
            default: nil
            }

            guard let value else { return nil }
            self = value
        }

        public var rawValue: screenLineMotion_T {
            switch self {
            case .h: MOTION_H
            case .l: MOTION_L
            case .m: MOTION_M
            }
        }
    }

    enum Direction: RawRepresentable {
        public typealias RawValue = CInt
        case forward, backward, forwardFile, backwardFile

        public var rawValue: RawValue {
            switch self {
            case .forward: FORWARD
            case .backward: BACKWARD
            case .forwardFile: FORWARD_FILE
            case .backwardFile: BACKWARD_FILE
            }
        }

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case FORWARD: .forward
            case BACKWARD: .backward
            case FORWARD_FILE: .forwardFile
            case BACKWARD_FILE: .backwardFile
            default: nil
            }

            guard let value else { return nil }
            self = value
        }
    }

    typealias ColumnNumber = colnr_T
    typealias LineNumber = linenr_T

    // MARK: - Colorschemes

    // TODO: Replace with simple RawRepresentable proxy struct
    struct ColorSchemeCompletionContext {
        let filter: String

        private var numSchemes: UInt {
            get { UInt(numSchemesPointer!.pointee) }
            set { numSchemesPointer!.pointee = CInt(newValue) }
        }

        public var colorSchemes: [String] {
            get {
                Array(colorSchemesPointer!.pointee!, count: numSchemes)
                    .map { String(cString: $0!) }
            }
            set {
                colorSchemesPointer!.pointee = newValue.cPointerPointer
                numSchemes = UInt(newValue.count)
            }
        }

        let numSchemesPointer: UnsafeMutablePointer<CInt>?
        let colorSchemesPointer: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?>?
    }

    // MARK: - Mapping


    typealias ScriptID = scid_T

    struct ScriptContext: RawRepresentable {
        public typealias RawValue = sctx_T

        public let scriptID: ScriptID
        public let sequence: Int
        public let lineNumber: LineNumber
        public let version: Int

        public init?(rawValue: RawValue) {
            scriptID = rawValue.sc_sid
            sequence = .init(rawValue.sc_seq)
            lineNumber = .init(rawValue.sc_lnum)
            version = .init(rawValue.sc_version)
        }

        public var rawValue: RawValue {
            .init(
                sc_sid: scriptID,
                sc_seq: .init(sequence),
                sc_lnum: lineNumber,
                sc_version: .init(version))
        }
    }

    struct MapBlock: RawRepresentable {
        public typealias RawValue = UnsafePointer<mapblock_T>?
        public let rawValue: RawValue

        public init?(rawValue: RawValue) {
            guard let rawValue else { return nil }
            self.rawValue = rawValue
        }

        public var next: MapBlock? { .init(rawValue: rawValue?.pointee.m_next) }
        public var keys: String { .init(cString: rawValue!.pointee.m_keys) }
        public var originalKeys: String { .init(cString: rawValue!.pointee.m_orig_keys) }
        public var str: String { .init(cString: rawValue!.pointee.m_str) }
        public var originalStr: String { .init(cString: rawValue!.pointee.m_orig_str) }
        public var keylen: Int { .init(rawValue!.pointee.m_keylen) }
        public var mode: State { .init(rawValue: rawValue!.pointee.m_mode) }
        public var noremap: Bool { .init(rawValue!.pointee.m_noremap) }
        public var silent: Bool { .init(rawValue!.pointee.m_silent) }
        public var nowait: Bool { .init(rawValue!.pointee.m_nowait) }
        public var expr: Bool { .init(rawValue!.pointee.m_expr) }
        public var scriptContext: ScriptContext? { .init(rawValue: rawValue!.pointee.m_script_ctx) }
    }

    // MARK: - Messages


    struct Message: RawRepresentable {
        public typealias RawValue = msg_T

        public var contents: String = ""
        public var title: String = ""
        public let priority: MessagePriority

        public var rawValue: RawValue {
            RawValue(
                contents: contents.cString,
                title: title.cString,
                priority: priority.rawValue
            )
        }

        public func send() {
            var rawValue = rawValue
            withUnsafeMutablePointer(to: &rawValue, msg2_send)
        }

        public mutating func put(_ s: String) {
            contents += s
        }

        public init(contents: String = "", title: String = "", priority: MessagePriority) {
            self.contents = contents
            self.title = title
            self.priority = priority
        }

        public init?(rawValue: RawValue) {
            guard let priority = MessagePriority(rawValue: rawValue.priority) else {
                return nil
            }

            self.contents = String(cString: rawValue.contents)
            self.title = String(cString: rawValue.title)
            self.priority = priority
        }
    }

    enum MessagePriority: RawRepresentable {
        public typealias RawValue = msgPriority_T

        case info
        case warning
        case error

        public var rawValue: RawValue {
            switch self {
            case .info: MSG_INFO
            case .warning: MSG_WARNING
            case .error: MSG_ERROR
            }
        }

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case MSG_INFO: .info
            case MSG_WARNING: .warning
            case MSG_ERROR: .error
            default: nil
            }

            guard let value else { return nil }
            self = value
        }
    }

    // MARK: - Misc


    enum GotoTarget: RawRepresentable {
        public typealias RawValue = gotoTarget_T

        case definition
        case declaration
        case implementation
        case typeDefinition
        case hover
        case outline
        case messages

        public var rawValue: RawValue {
            switch self {
            case .definition: DEFINITION
            case .declaration: DECLARATION
            case .implementation: IMPLEMENTATION
            case .typeDefinition: TYPEDEFINITION
            case .hover: HOVER
            case .outline: OUTLINE
            case .messages: MESSAGES
            }
        }

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case DEFINITION: .definition
            case DECLARATION: .declaration
            case IMPLEMENTATION: .implementation
            case TYPEDEFINITION: .typeDefinition
            case HOVER: .hover
            case OUTLINE: .outline
            case MESSAGES: .messages
            default: nil
            }

            guard let value else { return nil }
            self = value
        }
    }

    struct GotoRequest: RawRepresentable {
        public typealias RawValue = gotoRequest_T

        public let count: Int
        public let location: Position
        public let target: GotoTarget

        public var rawValue: RawValue {
            gotoRequest_T(
                count: CInt(count),
                location: location,
                target: target.rawValue
            )
        }

        public init?(rawValue: RawValue) {
            self.count = Int(rawValue.count)
            self.location = rawValue.location
            self.target = GotoTarget(rawValue: rawValue.target)!
        }
    }

    enum FormatRequestType: RawRepresentable {
        public typealias RawValue = formatRequestType_T

        case indentation
        case formatting

        public var rawValue: RawValue {
            switch self {
            case .indentation: INDENTATION
            case .formatting: FORMATTING
            }
        }

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case INDENTATION: .indentation
            case FORMATTING: .formatting
            default: nil
            }

            guard let value else { return nil }
            self = value
        }
    }

    struct FormatRequest: RawRepresentable {
        public typealias RawValue = formatRequest_T

        public let formatType: FormatRequestType
        public let returnCursor: Bool
        public let start: Position
        public let end: Position
        public let buf: Buffer
        public let cmd: String?

        public var rawValue: RawValue {
            RawValue(
                formatType: formatType.rawValue,
                returnCursor: returnCursor ? 1 : 0,
                start: start,
                end: end,
                buf: buf,
                cmd: cmd?.uCString
            )
        }

        public init?(rawValue: RawValue) {
            formatType = FormatRequestType(rawValue: rawValue.formatType)!
            returnCursor = Bool(rawValue.returnCursor)
            start = rawValue.start
            end = rawValue.end
            buf = rawValue.buf
            cmd = Character(rawValue.cmd.pointee) == .nul ? nil : String(cString: rawValue.cmd)
        }
    }

    //    typedef enum
    //    {
    //        CLEAR_MESSAGES
    //    } clearTarget_T;

    enum ClearTarget: RawRepresentable {
        public typealias RawValue = clearTarget_T

        case messages

        public var rawValue: RawValue {
            switch self {
            case .messages: CLEAR_MESSAGES
            }
        }

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case CLEAR_MESSAGES: .messages
            default: nil
            }

            guard let value else { return nil }
            self = value
        }
    }

    //    typedef struct
    //    {
    //        int count;
    //        clearTarget_T target;
    //    } clearRequest_T;
    struct ClearRequest: RawRepresentable {
        public typealias RawValue = clearRequest_T

        public let count: Int
        public let target: ClearTarget

        public var rawValue: RawValue {
            RawValue(
                count: CInt(count),
                target: target.rawValue
            )
        }

        public init?(rawValue: RawValue) {
            count = Int(rawValue.count)
            target = ClearTarget(rawValue: rawValue.target)!
        }
    }

    //    typedef struct
    //    {
    //        char_u *fullname;
    //        char_u *shortname;
    //
    //        // Type can be:
    //        // Number or toggle: 1 -> value is in numval
    //        // String: 0 -> value is in stringval
    //        int type;
    //
    //        long numval;
    //        char_u *stringval;
    //        int opt_flags; // [ OPT_FREE | OPT_LOCAL | OPT_GLOBAL ]
    //        int hidden;
    //    } optionSet_T;
    struct OptionSet: RawRepresentable {
        public typealias RawValue = optionSet_T

        public let fullname: String
        public let shortname: String?
        public let type: Int
        public let numval: Int
        public let stringval: String?
        public let optFlags: Int
        public let hidden: Int

        public var rawValue: RawValue {
            RawValue(
                fullname: fullname.uCString,
                shortname: shortname?.uCString,
                type: CInt(type),
                numval: CLong(numval),
                stringval: stringval?.uCString,
                opt_flags: CInt(optFlags),
                hidden: CInt(hidden)
            )
        }

        public init?(rawValue: RawValue) {
            fullname = String(cString: rawValue.fullname)
            shortname = String?(rawValue.shortname)
            type = Int(rawValue.type)
            numval = Int(rawValue.numval)
            stringval = String?(rawValue.stringval)
            optFlags = Int(rawValue.opt_flags)
            hidden = Int(rawValue.hidden)
        }
    }

    // MARK: - Operators


    enum ScrollDirection: RawRepresentable {
        public typealias RawValue = scrollDirection_T
        case cursorCenterV
        case cursorCenterH
        case cursorTop
        case cursorBottom
        case cursorLeft
        case cursorRight
        case lineUp
        case lineDown
        case halfPageDown
        case halfPageUp
        case pageDown
        case pageUp
        case halfPageLeft
        case halfPageRight
        case columnLeft
        case columnRight

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case SCROLL_CURSOR_CENTERV: .cursorCenterV
            case SCROLL_CURSOR_CENTERH: .cursorCenterH
            case SCROLL_CURSOR_TOP: .cursorTop
            case SCROLL_CURSOR_BOTTOM: .cursorBottom
            case SCROLL_CURSOR_LEFT: .cursorLeft
            case SCROLL_CURSOR_RIGHT: .cursorRight
            case SCROLL_LINE_UP: .lineUp
            case SCROLL_LINE_DOWN: .lineDown
            case SCROLL_HALFPAGE_DOWN: .halfPageDown
            case SCROLL_HALFPAGE_UP: .halfPageUp
            case SCROLL_PAGE_DOWN: .pageDown
            case SCROLL_PAGE_UP: .pageUp
            case SCROLL_HALFPAGE_LEFT: .halfPageLeft
            case SCROLL_HALFPAGE_RIGHT: .halfPageRight
            case SCROLL_COLUMN_LEFT: .columnLeft
            case SCROLL_COLUMN_RIGHT: .columnRight
            default: nil
            }

            guard let value else {
                return nil
            }
            self = value
        }

        public var rawValue: RawValue {
            switch self {
            case .cursorCenterV: SCROLL_CURSOR_CENTERV
            case .cursorCenterH: SCROLL_CURSOR_CENTERH
            case .cursorTop: SCROLL_CURSOR_TOP
            case .cursorBottom: SCROLL_CURSOR_BOTTOM
            case .cursorLeft: SCROLL_CURSOR_LEFT
            case .cursorRight: SCROLL_CURSOR_RIGHT
            case .lineUp: SCROLL_LINE_UP
            case .lineDown: SCROLL_LINE_DOWN
            case .halfPageDown: SCROLL_HALFPAGE_DOWN
            case .halfPageUp: SCROLL_HALFPAGE_UP
            case .pageDown: SCROLL_PAGE_DOWN
            case .pageUp: SCROLL_PAGE_UP
            case .halfPageLeft: SCROLL_HALFPAGE_LEFT
            case .halfPageRight: SCROLL_HALFPAGE_RIGHT
            case .columnLeft: SCROLL_COLUMN_LEFT
            case .columnRight: SCROLL_COLUMN_RIGHT
            }
        }
    }

    // MARK: - Terminal


    //    typedef struct
    //    {
    //        char_u *cmd;
    //        int rows;
    //        int cols;
    //        int curwin;
    //        char finish;
    //        int hidden;
    //    } terminalRequest_t;
    struct TerminalRequest: RawRepresentable {
        public typealias RawValue = terminalRequest_t

        public let cmd: String?
        public let rows: Int
        public let cols: Int
        public let curwin: Int
        public let finish: Character
        public let hidden: Bool

        public var rawValue: RawValue {
            .init(cmd: cmd?.uCString,
                  rows: CInt(rows),
                  cols: CInt(cols),
                  curwin: CInt(curwin),
                  finish: CChar(char: finish),
                  hidden: CInt(hidden))
        }

        public init?(rawValue: RawValue) {
            self.cmd = String?(rawValue.cmd)
            self.rows = Int(rawValue.rows)
            self.cols = Int(rawValue.cols)
            self.curwin = Int(rawValue.curwin)
            self.finish = Character(rawValue.finish)
            self.hidden = Bool(rawValue.hidden)
        }
    }

    // MARK: - Window


    //    typedef enum
    //    {
    //    } windowSplit_T;
    enum WindowSplit: RawRepresentable {
        public typealias RawValue = windowSplit_T

        case horizontal
        case horizontalNew
        case vertical
        case verticalNew
        case tab
        case tabNew

        public var rawValue: RawValue {
            switch self {
            case .horizontal: SPLIT_HORIZONTAL
            case .horizontalNew: SPLIT_HORIZONTAL_NEW
            case .vertical: SPLIT_VERTICAL
            case .verticalNew: SPLIT_VERTICAL_NEW
            case .tab: SPLIT_TAB
            case .tabNew: SPLIT_TAB_NEW
            }
        }

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case SPLIT_HORIZONTAL: .horizontal
            case SPLIT_HORIZONTAL_NEW: .horizontalNew
            case SPLIT_VERTICAL: .vertical
            case SPLIT_VERTICAL_NEW: .verticalNew
            case SPLIT_TAB: .tab
            case SPLIT_TAB_NEW: .tabNew
            default: nil
            }

            guard let value else { return nil }
            self = value
        }
    }

    //    typedef enum
    //    {
    //        WIN_CURSOR_LEFT,           // <C-w>h
    //        WIN_CURSOR_RIGHT,          // <C-w>l
    //        WIN_CURSOR_UP,             // <C-w>k
    //        WIN_CURSOR_DOWN,           // <C-w>j
    //        WIN_MOVE_FULL_LEFT,        // <C-w>H
    //        WIN_MOVE_FULL_RIGHT,       // <C-w>L
    //        WIN_MOVE_FULL_UP,          // <C-w>K
    //        WIN_MOVE_FULL_DOWN,        // <C-w>J
    //        WIN_CURSOR_TOP_LEFT,       // <C-w>t
    //        WIN_CURSOR_BOTTOM_RIGHT,   // <C-w>b
    //        WIN_CURSOR_PREVIOUS,       // <C-w>p
    //        WIN_MOVE_ROTATE_DOWNWARDS, // <C-w>r
    //        WIN_MOVE_ROTATE_UPWARDS,   // <C-w>R
    //    } windowMovement_T;
    enum WindowMovement: RawRepresentable {
        public typealias RawValue = windowMovement_T

        case cursorLeft
        case cursorRight
        case cursorUp
        case cursorDown
        case moveFullLeft
        case moveFullRight
        case moveFullUp
        case moveFullDown
        case cursorTopLeft
        case cursorBottomRight
        case cursorPrevious
        case moveRotateDownwards
        case moveRotateUpwards

        public var rawValue: RawValue {
            switch self {
            case .cursorLeft:
                WIN_CURSOR_LEFT
            case .cursorRight: WIN_CURSOR_RIGHT
            case .cursorUp: WIN_CURSOR_UP
            case .cursorDown: WIN_CURSOR_DOWN
            case .moveFullLeft: WIN_MOVE_FULL_LEFT
            case .moveFullRight: WIN_MOVE_FULL_RIGHT
            case .moveFullUp: WIN_MOVE_FULL_UP
            case .moveFullDown: WIN_MOVE_FULL_DOWN
            case .cursorTopLeft: WIN_CURSOR_TOP_LEFT
            case .cursorBottomRight: WIN_CURSOR_BOTTOM_RIGHT
            case .cursorPrevious: WIN_CURSOR_PREVIOUS
            case .moveRotateDownwards: WIN_MOVE_ROTATE_DOWNWARDS
            case .moveRotateUpwards: WIN_MOVE_ROTATE_UPWARDS
            }
        }

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case WIN_CURSOR_LEFT: .cursorLeft
            case WIN_CURSOR_RIGHT: .cursorRight
            case WIN_CURSOR_UP: .cursorUp
            case WIN_CURSOR_DOWN: .cursorDown
            case WIN_MOVE_FULL_LEFT: .moveFullLeft
            case WIN_MOVE_FULL_RIGHT: .moveFullRight
            case WIN_MOVE_FULL_UP: .moveFullUp
            case WIN_MOVE_FULL_DOWN: .moveFullDown
            case WIN_CURSOR_TOP_LEFT: .cursorTopLeft
            case WIN_CURSOR_BOTTOM_RIGHT: .cursorBottomRight
            case WIN_CURSOR_PREVIOUS: .cursorPrevious
            case WIN_MOVE_ROTATE_DOWNWARDS: .moveRotateDownwards
            case WIN_MOVE_ROTATE_UPWARDS: .moveRotateUpwards
            default: nil
            }

            guard let value else { return nil }
            self = value
        }
    }

    // MARK: - Misc

    struct State: Swift.OptionSet {
        public typealias RawValue = CInt

        public let rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static let normal         = Self(rawValue: clibvim.NORMAL)
        public static let visual         = Self(rawValue: clibvim.VISUAL)
        public static let opPending      = Self(rawValue: clibvim.OP_PENDING)
        public static let cmdLine        = Self(rawValue: clibvim.CMDLINE)
        public static let insert         = Self(rawValue: clibvim.INSERT)
        public static let langMap        = Self(rawValue: clibvim.LANGMAP)
        public static let replaceFlag    = Self(rawValue: clibvim.REPLACE_FLAG)
        public static let replace: Self  = [ .replaceFlag, .insert ]
        public static let vReplaceFlag   = Self(rawValue: clibvim.VREPLACE_FLAG)
        public static let vReplace: Self = [ .replaceFlag, .vReplaceFlag, .insert ]
        public static let lReplace: Self = [ .replaceFlag, .langMap ]
        public static let normalBusy     = Self(rawValue: clibvim.NORMAL_BUSY)
        public static let hitReturn      = Self(rawValue: clibvim.HITRETURN)
        public static let askMore        = Self(rawValue: clibvim.ASKMORE)
        public static let setWSize       = Self(rawValue: clibvim.SETWSIZE)
        public static let abbrev         = Self(rawValue: clibvim.ABBREV)
        public static let externCmd      = Self(rawValue: clibvim.EXTERNCMD)
        public static let showMatch      = Self(rawValue: clibvim.SHOWMATCH)
        public static let confirm        = Self(rawValue: clibvim.CONFIRM)
        public static let selectMode     = Self(rawValue: clibvim.SELECTMODE)
        public static let terminal       = Self(rawValue: clibvim.TERMINAL)
    }

    // Motion types, used for operators and for yank/delete registers.
    enum MotionType: RawRepresentable {
        public typealias RawValue = CInt

        case charWise,  // character-wise movement/register
             lineWise,  // line-wise movement/register
             blockWise, // block-wise register
             auto       // Decide between MLINE/MCHAR

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case clibvim.MCHAR: .charWise
            case clibvim.MLINE: .lineWise
            case clibvim.MBLOCK: .blockWise
            case clibvim.MAUTO: .auto
            default: nil
            }

            guard let value else { return nil }
            self = value
        }

        public var rawValue: RawValue {
            switch self {
            case .charWise: clibvim.MCHAR
            case .lineWise: clibvim.MLINE
            case .blockWise: clibvim.MBLOCK
            case .auto: clibvim.MAUTO
            }
        }
    }

    enum SubMode: RawRepresentable {
        public typealias RawValue = subMode_T
        case none
        case insertLiteral

        public init?(rawValue: RawValue) {
            let value: Self? = switch rawValue {
            case SM_NONE: Vim.SubMode.none
            case SM_INSERT_LITERAL: .insertLiteral
            default: nil
            }

            guard let value else { return nil }
            self = value
        }

        public var rawValue: RawValue {
            switch self {
            case .none: SM_NONE
            case .insertLiteral: SM_INSERT_LITERAL
            }
        }
    }

    struct PendingOperator: RawRepresentable {
        public typealias RawValue = pendingOp_T

        public let opType: Operator
        public let regName: Character
        public let count: Int

        public init?(rawValue: RawValue) {
            guard let opType = Operator(rawValue: rawValue.op_type) else { return nil }
            self.opType = opType
            self.regName = Character(rawValue.regname)
            self.count = Int(rawValue.count)
        }

        public var rawValue: RawValue {
            RawValue(
                op_type: opType.rawValue,
                regname: CInt(regName.asciiValue!),
                count: CLong(count)
            )
        }
    }

    enum Operator: RawRepresentable {
        public typealias RawValue = CInt
        case nop            /* no pending operation */
        case delete         /* "d"  delete operator */
        case yank           /* "y"  yank operator */
        case change         /* "c"  change operator */
        case lshift         /* "<"  left shift operator */
        case rshift         /* ">"  right shift operator */
        case filter         /* "!"  filter operator */
        case tilde          /* "g~" switch case operator */
        case indent         /* "="  indent operator */
        case format         /* "gq" format operator */
        case colon         /* ":"  colon operator */
        case upper         /* "gU" make upper case operator */
        case lower         /* "gu" make lower case operator */
        case join          /* "J"  join operator, only for Visual mode */
        case joinNs       /* "gJ"  join operator, only for Visual mode */
        case rot13         /* "g?" rot-13 encoding */
        case replace       /* "r"  replace chars, only for Visual mode */
        case insert        /* "I"  Insert column, only for Visual mode */
        case append        /* "A"  Append column, only for Visual mode */
        case fold          /* "zf" define a fold */
        case foldopen      /* "zo" open folds */
        case foldopenrec   /* "zO" open folds recursively */
        case foldclose     /* "zc" close folds */
        case foldcloserec  /* "zC" close folds recursively */
        case folddel       /* "zd" delete folds */
        case folddelrec    /* "zD" delete folds recursively */
        case format2       /* "gw" format operator, keeps cursor pos */
        case function      /* "g@" call 'operatorfunc' */
        case nrAdd        /* "<C-A>" Add to the number or alphabetic \ \ \
                           character (OP_ADD conflicts with Perl) */
        case nrSub       /* "<C-X>" Subtract from the number or \ \ \
                          alphabetic character */
        case comment      /* "gc" and "gcc" toggles commented lines */

        public init?(rawValue: CInt) {
            let value: Self? = switch rawValue {
            case OP_NOP: .nop
            case OP_DELETE: .delete
            case OP_YANK: .yank
            case OP_CHANGE: .change
            case OP_LSHIFT: .lshift
            case OP_RSHIFT: .rshift
            case OP_FILTER: .filter
            case OP_TILDE: .tilde
            case OP_INDENT: .indent
            case OP_FORMAT: .format
            case OP_COLON: .colon
            case OP_UPPER: .upper
            case OP_LOWER: .lower
            case OP_JOIN: .join
            case OP_JOIN_NS: .joinNs
            case OP_ROT13: .rot13
            case OP_REPLACE: .replace
            case OP_INSERT: .insert
            case OP_APPEND: .append
            case OP_FOLD: .fold
            case OP_FOLDOPEN: .foldopen
            case OP_FOLDOPENREC: .foldopenrec
            case OP_FOLDCLOSE: .foldclose
            case OP_FOLDCLOSEREC: .foldcloserec
            case OP_FOLDDEL: .folddel
            case OP_FOLDDELREC: .folddelrec
            case OP_FORMAT2: .format2
            case OP_FUNCTION: .function
            case OP_NR_ADD: .nrAdd
            case OP_NR_SUB: .nrSub
            case OP_COMMENT: .comment
            default: nil
            }

            guard let value else { return nil }
            self = value
        }

        public var rawValue: CInt {
            switch self {
            case .nop: OP_NOP
            case .delete: OP_DELETE
            case .yank: OP_YANK
            case .change: OP_CHANGE
            case .lshift: OP_LSHIFT
            case .rshift: OP_RSHIFT
            case .filter: OP_FILTER
            case .tilde: OP_TILDE
            case .indent: OP_INDENT
            case .format: OP_FORMAT
            case .colon: OP_COLON
            case .upper: OP_UPPER
            case .lower: OP_LOWER
            case .join: OP_JOIN
            case .joinNs: OP_JOIN_NS
            case .rot13: OP_ROT13
            case .replace: OP_REPLACE
            case .insert: OP_INSERT
            case .append: OP_APPEND
            case .fold: OP_FOLD
            case .foldopen: OP_FOLDOPEN
            case .foldopenrec: OP_FOLDOPENREC
            case .foldclose: OP_FOLDCLOSE
            case .foldcloserec: OP_FOLDCLOSEREC
            case .folddel: OP_FOLDDEL
            case .folddelrec: OP_FOLDDELREC
            case .format2: OP_FORMAT2
            case .function: OP_FUNCTION
            case .nrAdd: OP_NR_ADD
            case .nrSub: OP_NR_SUB
            case .comment: OP_COMMENT
            }
        }
    }


    struct YankInfo: RawRepresentable {
        public typealias RawValue = yankInfo_T

        public var opChar: Character
        public var extraOpChar: Character
        public var regName: Character
        public var blockType: MotionType
        public var start: Position
        public var end: Position
        public var numLines: Int
        public var lines: [String]

        public init?(rawValue: RawValue) {
            opChar = Character(rawValue.op_char)
            extraOpChar = Character(rawValue.extra_op_char)
            regName = Character(rawValue.regname)
            blockType = MotionType(rawValue: rawValue.blockType)!
            start = rawValue.start
            end = rawValue.end
            numLines = Int(rawValue.numLines)
            lines = [String](rawValue.lines, count: rawValue.numLines)
        }

        public var rawValue: RawValue {
            .init(
                op_char: CInt(char: opChar),
                extra_op_char: CInt(char: extraOpChar),
                regname: CInt(char: regName),
                blockType: blockType.rawValue,
                start: start,
                end: end,
                numLines: CInt(numLines),
                lines: lines.cPointerPointer
            )
        }

        // TODO: Get rid
        public init(_ cYankInfoPointer: UnsafeMutablePointer<RawValue>) {
            self.init(rawValue: cYankInfoPointer.pointee)!
        }
    }


    struct Expand {
        public enum Mode: RawRepresentable {
            public typealias RawValue = CInt

            case free,
                 expandFree,
                 expandKeep,
                 next,
                 prev,
                 all,
                 longest,
                 allKeep

            public init?(rawValue: RawValue) {
                let value: Self? = switch rawValue {
                case WILD_FREE: .free
                case WILD_EXPAND_FREE: .expandFree
                case WILD_EXPAND_KEEP: .expandKeep
                case WILD_NEXT: .next
                case WILD_PREV: .prev
                case WILD_ALL: .all
                case WILD_LONGEST: .longest
                case WILD_ALL_KEEP: .allKeep
                default: nil
                }

                guard let value else { return nil }
                self = value
            }

            public var rawValue: CInt {
                switch self {
                case .free: WILD_FREE
                case .expandFree: WILD_EXPAND_FREE
                case .expandKeep: WILD_EXPAND_KEEP
                case .next: WILD_NEXT
                case .prev: WILD_PREV
                case .all: WILD_ALL
                case .longest: WILD_LONGEST
                case .allKeep: WILD_ALL_KEEP
                }
            }
        }

        public struct Option: Swift.OptionSet {
            public typealias RawValue = CInt

            public init(rawValue: RawValue) {
                self.rawValue = rawValue
            }

            public let rawValue: RawValue
            public static let listNotFound = Option(rawValue: WILD_LIST_NOTFOUND)
            public static let homeReplace = Option(rawValue: WILD_HOME_REPLACE)
            public static let useNL = Option(rawValue: WILD_USE_NL)
            public static let noBeep = Option(rawValue: WILD_NO_BEEP)
            public static let addSlash = Option(rawValue: WILD_ADD_SLASH)
            public static let keepAll = Option(rawValue: WILD_KEEP_ALL)
            public static let silent = Option(rawValue: WILD_SILENT)
            public static let escape = Option(rawValue: WILD_ESCAPE)
            public static let iCase = Option(rawValue: WILD_ICASE)
            public static let allLinks = Option(rawValue: WILD_ALLLINKS)
        }

        public enum Context: RawRepresentable {
            public typealias RawValue = CInt

            case unsuccessful
            case ok
            case nothing
            case commands
            case files
            case directories
            case settings
            case boolSettings
            case tags
            case oldSetting
            case help
            case buffers
            case events
            case menus
            case syntax
            case highlight
            case augroup
            case userVars
            case mappings
            case tagsListfiles
            case functions
            case userFunc
            case expression
            case menuNames
            case userCommands
            case userCmdFlags
            case userNargs
            case userComplete
            case envVars
            case language
            case colors
            case compiler
            case userDefined
            case userList
            case shellCmd
            case cScope
            case sign
            case profile
            case behave
            case fileType
            case filesInPath
            case ownSyntax
            case locales
            case history
            case user
            case synTime
            case userAddrType
            case packAdd
            case messages
            case mapClear
            case argList

            public init?(rawValue: CInt) {
                let value: Self? = switch rawValue {
                case EXPAND_UNSUCCESSFUL: .unsuccessful
                case EXPAND_OK: .ok
                case EXPAND_NOTHING: .nothing
                case EXPAND_COMMANDS: .commands
                case EXPAND_FILES: .files
                case EXPAND_DIRECTORIES: .directories
                case EXPAND_SETTINGS: .settings
                case EXPAND_BOOL_SETTINGS: .boolSettings
                case EXPAND_TAGS: .tags
                case EXPAND_OLD_SETTING: .oldSetting
                case EXPAND_HELP: .help
                case EXPAND_BUFFERS: .buffers
                case EXPAND_EVENTS: .events
                case EXPAND_MENUS: .menus
                case EXPAND_SYNTAX: .syntax
                case EXPAND_HIGHLIGHT: .highlight
                case EXPAND_AUGROUP: .augroup
                case EXPAND_USER_VARS: .userVars
                case EXPAND_MAPPINGS: .mappings
                case EXPAND_TAGS_LISTFILES: .tagsListfiles
                case EXPAND_FUNCTIONS: .functions
                case EXPAND_USER_FUNC: .userFunc
                case EXPAND_EXPRESSION: .expression
                case EXPAND_MENUNAMES: .menuNames
                case EXPAND_USER_COMMANDS: .userCommands
                case EXPAND_USER_CMD_FLAGS: .userCmdFlags
                case EXPAND_USER_NARGS: .userNargs
                case EXPAND_USER_COMPLETE: .userComplete
                case EXPAND_ENV_VARS: .envVars
                case EXPAND_LANGUAGE: .language
                case EXPAND_COLORS: .colors
                case EXPAND_COMPILER: .compiler
                case EXPAND_USER_DEFINED: .userDefined
                case EXPAND_USER_LIST: .userList
                case EXPAND_SHELLCMD: .shellCmd
                case EXPAND_CSCOPE: .cScope
                case EXPAND_SIGN: .sign
                case EXPAND_PROFILE: .profile
                case EXPAND_BEHAVE: .behave
                case EXPAND_FILETYPE: .fileType
                case EXPAND_FILES_IN_PATH: .filesInPath
                case EXPAND_OWNSYNTAX: .ownSyntax
                case EXPAND_LOCALES: .locales
                case EXPAND_HISTORY: .history
                case EXPAND_USER: .user
                case EXPAND_SYNTIME: .synTime
                case EXPAND_USER_ADDR_TYPE: .userAddrType
                case EXPAND_PACKADD: .packAdd
                case EXPAND_MESSAGES: .messages
                case EXPAND_MAPCLEAR: .mapClear
                case EXPAND_ARGLIST: .argList
                default: nil
                }

                guard let value else { return nil }
                self = value
            }

            public var rawValue: CInt {
                switch self {
                case .unsuccessful: EXPAND_UNSUCCESSFUL
                case .ok: EXPAND_OK
                case .nothing: EXPAND_NOTHING
                case .commands: EXPAND_COMMANDS
                case .files: EXPAND_FILES
                case .directories: EXPAND_DIRECTORIES
                case .settings: EXPAND_SETTINGS
                case .boolSettings: EXPAND_BOOL_SETTINGS
                case .tags: EXPAND_TAGS
                case .oldSetting: EXPAND_OLD_SETTING
                case .help: EXPAND_HELP
                case .buffers: EXPAND_BUFFERS
                case .events: EXPAND_EVENTS
                case .menus: EXPAND_MENUS
                case .syntax: EXPAND_SYNTAX
                case .highlight: EXPAND_HIGHLIGHT
                case .augroup: EXPAND_AUGROUP
                case .userVars: EXPAND_USER_VARS
                case .mappings: EXPAND_MAPPINGS
                case .tagsListfiles: EXPAND_TAGS_LISTFILES
                case .functions: EXPAND_FUNCTIONS
                case .userFunc: EXPAND_USER_FUNC
                case .expression: EXPAND_EXPRESSION
                case .menuNames: EXPAND_MENUNAMES
                case .userCommands: EXPAND_USER_COMMANDS
                case .userCmdFlags: EXPAND_USER_CMD_FLAGS
                case .userNargs: EXPAND_USER_NARGS
                case .userComplete: EXPAND_USER_COMPLETE
                case .envVars: EXPAND_ENV_VARS
                case .language: EXPAND_LANGUAGE
                case .colors: EXPAND_COLORS
                case .compiler: EXPAND_COMPILER
                case .userDefined: EXPAND_USER_DEFINED
                case .userList: EXPAND_USER_LIST
                case .shellCmd: EXPAND_SHELLCMD
                case .cScope: EXPAND_CSCOPE
                case .sign: EXPAND_SIGN
                case .profile: EXPAND_PROFILE
                case .behave: EXPAND_BEHAVE
                case .fileType: EXPAND_FILETYPE
                case .filesInPath: EXPAND_FILES_IN_PATH
                case .ownSyntax: EXPAND_OWNSYNTAX
                case .locales: EXPAND_LOCALES
                case .history: EXPAND_HISTORY
                case .user: EXPAND_USER
                case .synTime: EXPAND_SYNTIME
                case .userAddrType: EXPAND_USER_ADDR_TYPE
                case .packAdd: EXPAND_PACKADD
                case .messages: EXPAND_MESSAGES
                case .mapClear: EXPAND_MAPCLEAR
                case .argList: EXPAND_ARGLIST
                }
            }

        }


        public typealias CExpand = expand_T
        private var cExpand = CExpand()

        public var files: [String] {
            get {
                [String](cExpand.xp_files, count: cExpand.xp_numfiles)
            }
        }

        public init() {
            ExpandInit(&cExpand)
        }

        @discardableResult
        public mutating func expandOne(_ pattern: String,
                                       _ original: String?, /* allocated copy of original of expanded string */
                                       _ options: Option,
                                       _ mode: Mode) -> String? {

            cExpand.xp_pattern = pattern.uCString
            cExpand.xp_pattern_len = CInt(pattern.utf8.count)
            cExpand.xp_context = Context.colors.rawValue

            let pattern = addstar(cExpand.xp_pattern, cExpand.xp_pattern_len, cExpand.xp_context);

            return ExpandOne(&cExpand,
                             pattern,
                             original?.uCString,
                             options.rawValue,
                             mode.rawValue)
            |> String?.init
        }
    }



    typealias Position = pos_T
    typealias SearchHighlight = searchHighlight_T
}

extension Vim.Position: Equatable {
    public static func == (lhs: Vim.Position, rhs: Vim.Position) -> Bool {
        lhs.lnum == rhs.lnum && lhs.col == rhs.col
    }
}

extension Vim.SearchHighlight: Equatable {
    public static func == (lhs: Vim.SearchHighlight, rhs: Vim.SearchHighlight) -> Bool {
        lhs.start == rhs.start && lhs.end == rhs.end
    }
}

