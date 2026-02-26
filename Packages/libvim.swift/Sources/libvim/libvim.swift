//
//  libvim.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import clibvim

// TODO: Get rid of
public let FILE_CHANGED = clibvim.FILE_CHANGED

/*
 * Motion types, used for operators and for yank/delete registers.
 */
//public let MCHAR = clibvim.MCHAR /* character-wise movement/register */
public let MLINE = clibvim.MLINE /* line-wise movement/register */
public let MBLOCK = clibvim.MBLOCK /* block-wise register */

let MAUTO = clibvim.MAUTO /* Decide between MLINE/MCHAR */


public func win_setwidth(_ width: Int) {
    clibvim.win_setwidth(CInt(width))
}

public func win_setheight(_ height: Int) {
    clibvim.win_setheight(CInt(height))
}

public func vim_tempname(_ extraChar: Character, _ keep: Bool) -> String {
    let cString = clibvim.vim_tempname(
        CInt(extraChar.asciiValue!),
        CInt(keep)
    )
    return String(cString: cString!)
}

/*
 * vimInit
 *
 * This must be called prior to using any other methods.
 *
 * This expects an `argc` and an `argv` parameters,
 * for the command line arguments for this vim instance.
 */
//void vimInit(int argc, char **argv);
public func vimInit(_ args: String...) {
    clibvim.vimInit(CInt(args.count), args.cCharPointerPointer)
}

// MARK: - Buffer Methods

/*
 * vimBufferOpen
 *
 * Open a buffer and set as current.
 */

//buf_T *vimBufferOpen(char_u *ffname_arg, linenr_T lnum, int flags);

@discardableResult
public func vimBufferOpen(_ ffname: String, _ lnum: Int, _ flags: CInt) -> Vim.Buffer {
    ffname.withMutableCString {
        clibvim.vimBufferOpen($0, lnum, flags)
    }
}

/*
 * vimBufferLoad
 *
 * Load a buffer, but do not change current buffer.
 */

//buf_T *vimBufferLoad(char_u *ffname_arg, linenr_T lnum, int flags);
public func vimBufferLoad(_ ffname: String, _ lnum: Int, _ flags: CInt) -> Vim.Buffer {
    ffname.withMutableCString {
        clibvim.vimBufferLoad($0, lnum, flags)
    }
}

/*
 * vimBufferNew
 *
 * Create a new buffer
 */
//buf_T *vimBufferNew(int flags);

/*
 * vimBufferCheckIfChanged
 *
 * Check if the contents of a buffer have been changed on the filesystem, outside of libvim.
 * Returns 1 if buffer was changed (and changes the buffer contents)
 * Returns 2 if a message was displayed
 * Returns 0 otherwise
 */
//int vimBufferCheckIfChanged(buf_T *buf);
public func vimBufferCheckIfChanged(_ buf: Vim.Buffer) -> Int {
    Int(clibvim.vimBufferCheckIfChanged(buf))
}

//buf_T *vimBufferGetById(int id);
public func vimBufferGetById(_ id: Int) -> Vim.Buffer {
    clibvim.vimBufferGetById(CInt(id))
}
//buf_T *vimBufferGetCurrent(void);
public func vimBufferGetCurrent() -> Vim.Buffer {
    clibvim.vimBufferGetCurrent()
}
//void vimBufferSetCurrent(buf_T *buf);

//char_u *vimBufferGetFilename(buf_T *buf);
//char_u *vimBufferGetFiletype(buf_T *buf);
//int vimBufferGetId(buf_T *buf);
public func vimBufferGetId(_ buf: Vim.Buffer) -> Int {
    Int(clibvim.vimBufferGetId(buf))
}
//long vimBufferGetLastChangedTick(buf_T *buf);

public func vimBufferGetLastChangedTick(_ buf: Vim.Buffer) -> Int {
    clibvim.vimBufferGetLastChangedTick(buf)
}
//char_u *vimBufferGetLine(buf_T *buf, linenr_T lnum);
public func vimBufferGetLine(_ buf: Vim.Buffer!, _ lnum: Int) -> String {
    let ptr = clibvim.vimBufferGetLine(buf, lnum)
    return String(cString: ptr!)
}

//size_t vimBufferGetLineCount(buf_T *buf);

public func vimBufferGetLineCount(_ buf: Vim.Buffer) -> Int {
    clibvim.vimBufferGetLineCount(buf)
}

/*
 * vimBufferSetLines
 *
 * Set a range of lines into the buffer. The start parameter is zero based and inclusive.
 * The end parameter is exclusive. This means you can either replace existing lines, or
 * splice in new lines in-between existing lines.
 *
 * Examples:
 * vimBufferSetLines(buf, 0, 0, ["abc"], 1); // Insert "abc" above the current first line, pushing down all existing lines
 * vimBufferSetLines(buf, 0, 1, ["abc"], 1); // Set line 1 to "abc"
 * vimBufferSetLines(buf, 0, 2, ["abc"], 2); // Set line 1 to "abc", make line 2 empty
 * vimBufferSetLines(buf, 2, 2, ["abc"], 1); // Splice "abc" after the second line, pushing the existing lines from 3 on down
 *
 */
//void vimBufferSetLines(buf_T *buf, linenr_T start, linenr_T end, char_u **lines, int count);
//
public func vimBufferSetLines(_ buf: Vim.Buffer, _ start: Int, _ end: Int, _ lines: [String]) {
    let cLines = lines.cPointerPointer
    clibvim.vimBufferSetLines(buf, start, end, cLines, CInt(lines.count))
}

public func vimBufferSetLines(_ buf: Vim.Buffer, _ start: Int, _ end: Int, _ lines: [String], _ count: Int) {
    let cLines = lines.cPointerPointer
    clibvim.vimBufferSetLines(buf, start, end, cLines, CInt(count))
}

//int vimBufferGetModified(buf_T *buf);
public func vimBufferGetModified(_ buf: Vim.Buffer) -> Bool {
    clibvim.vimBufferGetModified(buf)
    |> Bool.init
}
//
//int vimBufferGetModifiable(buf_T *buf);
public func vimBufferGetModifiable(_ buf: Vim.Buffer) -> Bool {
    clibvim.vimBufferGetModifiable(buf)
    |> Bool.init
}
//void vimBufferSetModifiable(buf_T *buf, int modifiable);
public func vimBufferSetModifiable(_ buf: Vim.Buffer, _ modifiable: Bool) {
    clibvim.vimBufferSetModifiable(buf, CInt(modifiable))
}

//
//int vimBufferGetFileFormat(buf_T *buf);
public func vimBufferGetFileFormat(_ buf: Vim.Buffer) -> Vim.EndOfLineFormat {
    Vim.EndOfLineFormat(rawValue: clibvim.vimBufferGetFileFormat(buf))!
}

//void vimBufferSetFileFormat(buf_T *buf, int fileformat);
public func vimBufferSetFileFormat(_ buf: Vim.Buffer, _ fileformat: Vim.EndOfLineFormat) {
    clibvim.vimBufferSetFileFormat(buf, fileformat.rawValue)
}
//
//int vimBufferGetReadOnly(buf_T *buf);
public func vimBufferGetReadOnly(_ buf: Vim.Buffer) -> Bool {
    clibvim.vimBufferGetReadOnly(buf)
    |> Bool.init
}

//void vimBufferSetReadOnly(buf_T *buf, int modifiable);
public func vimBufferSetReadOnly(_ buf: Vim.Buffer, _ readOnly: Bool) {
    clibvim.vimBufferSetReadOnly(buf, CInt(readOnly))
}
//
//void vimSetBufferUpdateCallback(BufferUpdateCallback bufferUpdate);
public typealias BufferUpdateCallback = (_ bufferUpdate: Vim.BufferUpdate) -> Void
var vimBufferUpdateCallback: BufferUpdateCallback?

public func vimSetBufferUpdateCallback(_ callback: BufferUpdateCallback?) {
    vimBufferUpdateCallback = callback
    let cCallback: clibvim.BufferUpdateCallback? = if callback != nil {
        { cBufferUpdate in
            vimBufferUpdateCallback!(Vim.BufferUpdate(rawValue: cBufferUpdate)!)
        }
    } else {
        nil
    }
    clibvim.vimSetBufferUpdateCallback(cCallback)
}

/***
 * Autocommands
 ***/

//void vimSetAutoCommandCallback(AutoCommandCallback autoCommandDispatch);

public typealias AutoCommandCallback = (_ event: Vim.Event, _ buffer: Vim.Buffer?) -> Void
var vimAutoCommandCallback: AutoCommandCallback?

public func vimSetAutoCommandCallback(_ callback: AutoCommandCallback?) {
    vimAutoCommandCallback = callback
    let cCallback: clibvim.AutoCommandCallback? = if callback != nil {
        { cEvent, buffer in
            vimAutoCommandCallback!(Vim.Event(rawValue: cEvent)!, buffer)
        }
    } else {
        nil
    }

    clibvim.vimSetAutoCommandCallback(cCallback)
}

// MARK: - Commandline

//char_u vimCommandLineGetType(void);
public func vimCommandLineGetType() -> Character {
    clibvim.vimCommandLineGetType()
    |> Character.init
}

//char_u *vimCommandLineGetText(void);
public func vimCommandLineGetText() -> String? {
    guard let ptr = clibvim.vimCommandLineGetText() else {
        return nil
    }
    return String(cString: ptr)
}

//int vimCommandLineGetPosition(void);
public func vimCommandLineGetPosition() -> Int {
    Int(clibvim.vimCommandLineGetPosition())
}

//void vimCommandLineGetCompletions(char_u ***completions, int *count);
public func vimCommandLineGetCompletions() -> [String] {
    var cCompletions: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?
    var count: CInt = 0
    clibvim.vimCommandLineGetCompletions(&cCompletions, &count)
    let completions = UnsafeBufferPointer(start: cCompletions, count: Int(count))
    return completions.compactMap { $0.map { String(cString: $0) } }
}
//void vimSetCustomCommandHandler(CustomCommandCallback customCommandHandler);

public typealias CustomCommandCallback = (_ exCommand: Vim.ExCommand) -> Bool
var vimCustomCommandHandler: CustomCommandCallback?

public func vimSetCustomCommandHandler(_ handler: CustomCommandCallback?) {
    vimCustomCommandHandler = handler
    let cHandler: clibvim.CustomCommandCallback? = if handler != nil {
        {
            CInt(
                vimCustomCommandHandler!(
                    Vim.ExCommand(rawValue: $0!.pointee)!
                )
            )
        }
    } else {
        nil
    }
    clibvim.vimSetCustomCommandHandler(cHandler)
}

// MARK: - Eval

/***
 * vimEval
 *
 * Evaluate a string as vim script, and return the result as string.
 * Callee is responsible for freeing the command as well as the result.
 */
//char_u *vimEval(char_u *str);

public func vimEval(_ str: String) -> String? {
    str.withMutableCString {
        guard let result = clibvim.vimEval($0) else {
            return nil
        }
        return String(cString: result)
    }
}

//void vimSetFunctionGetCharCallback(FunctionGetCharCallback callback);
//public typealias FunctionGetCharCallback = (_ mode: Int, _ character: inout Character, _ modMask: inout Int) -> Bool
// TODO: Remove pointers
public typealias FunctionGetCharCallback = (_ mode: Int, _ character: UnsafeMutablePointer<CChar>?, _ modMask: UnsafeMutablePointer<CInt>?) -> Bool
var vimFunctionGetCharCallback: FunctionGetCharCallback?

public func vimSetFunctionGetCharCallback(_ callback: FunctionGetCharCallback?) {
    vimFunctionGetCharCallback = callback
    let cCallback: clibvim.FunctionGetCharCallback? = if callback != nil {
        { mode, character, modMask in
            vimFunctionGetCharCallback!(
                Int(mode),
                character,
                modMask
            )
            |> CInt.init
        }
    } else {
        nil
    }
    clibvim.vimSetFunctionGetCharCallback(cCallback)
}

// MARK: - Cursor Methods

//colnr_T vimCursorGetColumn(void);
public func vimCursorGetColumn() -> Vim.ColumnNumber {
    clibvim.vimCursorGetColumn()
}

//colnr_T vimCursorGetColumnWant(void);
public func vimCursorGetColumnWant() -> Vim.ColumnNumber {
    clibvim.vimCursorGetColumnWant()
}

//void vimCursorSetColumnWant(colnr_T curswant);
public func vimCursorSetColumnWant(_ column: Vim.ColumnNumber) {
    clibvim.vimCursorSetColumnWant(column)
}

//linenr_T vimCursorGetLine(void);

public func vimCursorGetLine() -> Vim.LineNumber {
    clibvim.vimCursorGetLine()
}

//pos_T vimCursorGetPosition(void);
public func vimCursorGetPosition() -> Vim.Position {
    clibvim.vimCursorGetPosition()
}

//void vimCursorSetPosition(pos_T pos);
public func vimCursorSetPosition(_ pos: Vim.Position) {
    clibvim.vimCursorSetPosition(pos)
}
//void vimSetCursorAddCallback(CursorAddCallback cursorAddCallback);
public typealias CursorAddCallback = (_ cursor: Vim.Position) -> Void
var vimCursorAddCallback: CursorAddCallback?

public func vimSetCursorAddCallback(_ callback: CursorAddCallback?) {
    vimCursorAddCallback = callback
    let cCallback: clibvim.CursorAddCallback? = if callback != nil {
        { cursor in
            vimCursorAddCallback!(cursor)
        }
    } else {
        nil
    }
    clibvim.vimSetCursorAddCallback(cCallback)
}

/***
 * vimCursorGetDesiredColumn
 *
 * Get the column that we'd like to be at - used to stay in the same
 * column for up/down cursor motions.
 */
//colnr_T vimCursorGetDesiredColumn(void);

/***
 * vimSetCursorMoveScreenLineCallback
 *
 * Callback when the cursor will be moved via screen lines (H, M, L).
 * Because the libvim-consumer is responsible for managing the view,
 * libvim needs information about the view to correctly handle these motions.
 */
//void vimSetCursorMoveScreenLineCallback(
//    CursorMoveScreenLineCallback cursorMoveScreenLineCallback);
public typealias CursorMoveScreenLineCallback = (_ motion: Vim.ScreenLineMotion, _ count: Int, _ startLine: Vim.LineNumber) -> Vim.LineNumber
var vimCursorMoveScreenLineCallback: CursorMoveScreenLineCallback?

public func vimSetCursorMoveScreenLineCallback(_ callback: CursorMoveScreenLineCallback?) {
    vimCursorMoveScreenLineCallback = callback
    let cCallback: clibvim.CursorMoveScreenLineCallback? = if callback != nil {
        { motion, count, startLine, destLinePtr in
            destLinePtr!.pointee = vimCursorMoveScreenLineCallback!(
                Vim.ScreenLineMotion(rawValue: motion)!,
                Int(count),
                startLine
            )
        }
    } else {
        nil
    }
    clibvim.vimSetCursorMoveScreenLineCallback(cCallback)
}

/***
 * vimSetCursorMoveScreenLineCallback
 *
 * Callback when the cursor will be moved via screen position (gj, gk).
 * Because the libvim-consumer is responsible for managing the view,
 * libvim needs information about the view to correctly handle these motions.
 */
//void vimSetCursorMoveScreenPositionCallback(
//    CursorMoveScreenPositionCallback cursorMoveScreenPositionCallback);

public typealias CursorMoveScreenPositionCallback = (_ direction: Vim.Direction, _ count: Int, _ srcLine: Vim.LineNumber, _ srcColumn: Vim.ColumnNumber, _ curswant: Vim.ColumnNumber) -> (Vim.LineNumber, Vim.ColumnNumber)
var vimCursorMoveScreenPositionCallback: CursorMoveScreenPositionCallback?

public func vimSetCursorMoveScreenPositionCallback(_ callback: CursorMoveScreenPositionCallback?) {
    vimCursorMoveScreenPositionCallback = callback
    let cCallback: clibvim.CursorMoveScreenPositionCallback? = if callback != nil {
        { direction, count, srcLine, srcColumn, curswant, destLinePtr, destColumnPtr in
            let (destLine, destColumn) = vimCursorMoveScreenPositionCallback!(
                Vim.Direction(rawValue: direction)!,
                Int(count),
                srcLine,
                srcColumn,
                curswant
            )
            destLinePtr!.pointee = destLine
            destColumnPtr!.pointee = destColumn
        }
    } else {
        nil
    }
    clibvim.vimSetCursorMoveScreenPositionCallback(cCallback)
}

/***
 * File I/O
 ***/
//void vimSetFileWriteFailureCallback(FileWriteFailureCallback fileWriteFailureCallback);
public typealias FileWriteFailureCallback = (_ failureReason: Vim.WriteFailureReason, _ buf: Vim.Buffer) -> Void
var vimFileWriteFailureCallback: FileWriteFailureCallback?

public extension Vim {
    typealias WriteFailureReason = writeFailureReason_T
}

public func vimSetFileWriteFailureCallback(_ callback: FileWriteFailureCallback?) {
    vimFileWriteFailureCallback = callback
    let cCallback: clibvim.FileWriteFailureCallback? = if callback != nil {
        { reason, buf in
            vimFileWriteFailureCallback!(
                reason,
                buf!
            )
        }
    } else {
        nil
    }
    clibvim.vimSetFileWriteFailureCallback(cCallback)
}

/***
 * User Input
 ***/

/***
 * vimInput
 *
 * vimInput(input) passes the string, verbatim, to vim to be processed,
 * without replacing term-codes. This means strings like "<LEFT>" are
 * handled literally. This function handles Unicode text correctly.
 */
//void vimInput(char_u *input);

public func vimInput(_ input: String) {
    input.withMutableCString {
        clibvim.vimInput($0)
    }
}

/***
 * vimKey
 *
 * vimKey(input) passes a string and escapes termcodes - so a
 * a string like "<LEFT>" will first be replaced with the appropriate
 * term-code, and handled.
 */
//void vimKey(char_u *key);

public func vimKey(_ key: String) {
    key.withMutableCString {
        clibvim.vimKey($0)
    }
}

/***
 * vimExecute
 *
 * vimExecute(cmd) executes a command as if it was typed at the command-line.
 *
 * Example: vimExecute("echo 'hello!');
 */
//void vimExecute(char_u *cmd);
public func vimExecute(_ cmd: String) {
    cmd.withMutableCString {
        clibvim.vimExecute($0)
    }
}

//void vimExecuteLines(char_u **lines, int lineCount);
public func vimExecuteLines(_ lines: [String]) {
    clibvim.vimExecuteLines(lines.cPointerPointer, CInt(lines.count))
}

/***
 * Auto-indent
 ***/

public typealias AutoIndentCallback = (_ lnum: Int, _ buf: Vim.Buffer, _ prevLine: String?, _ currentLine: String?) -> Int
var vimAutoIndentCallback: AutoIndentCallback!

//void vimSetAutoIndentCallback(AutoIndentCallback callback);

public func vimSetAutoIndentCallback(_ callback: @escaping AutoIndentCallback) {
    vimAutoIndentCallback = callback
    let cCallback: clibvim.AutoIndentCallback = { lnum, bufferPointer, prevLine, currentLine in
        vimAutoIndentCallback(
            Int(lnum),
            bufferPointer!,
            String?(prevLine),
            String?(currentLine))
        |> CInt.init
    }
    clibvim.vimSetAutoIndentCallback(cCallback)
}

// MARK: - Colorschemes

//void vimColorSchemeSetChangedCallback(ColorSchemeChangedCallback callback);
public typealias ColorSchemeChangedCallback = (_ colorSchemeName: String?) -> Bool
var vimColorSchemeChangedCallback: ColorSchemeChangedCallback?

public func vimColorSchemeSetChangedCallback(_ callback: ColorSchemeChangedCallback?) {
    vimColorSchemeChangedCallback = callback
    let cCallback: clibvim.ColorSchemeChangedCallback? = if callback != nil {
        { colorSchemeName in
            String?(colorSchemeName)
            |> vimColorSchemeChangedCallback!
            |> CInt.init
        }
    } else {
        nil
    }
    clibvim.vimColorSchemeSetChangedCallback(cCallback)
}
//void vimColorSchemeSetCompletionCallback(ColorSchemeCompletionCallback callback);
public typealias ColorSchemeCompletionCallback = (_ context: inout Vim.ColorSchemeCompletionContext) -> Bool
var vimColorSchemeCompletionCallback: ColorSchemeCompletionCallback?

public func vimColorSchemeSetCompletionCallback(_ callback: ColorSchemeCompletionCallback?) {
    vimColorSchemeCompletionCallback = callback
    let cCallback: clibvim.ColorSchemeCompletionCallback? = if callback != nil {
        { filter, count, colorSchemes in
            var context = Vim.ColorSchemeCompletionContext(
                filter: String(cString: filter!),
                numSchemesPointer: count,
                colorSchemesPointer: colorSchemes
            )

            return vimColorSchemeCompletionCallback!(&context) ? 1 : 0
        }
    } else {
        nil
    }

    clibvim.vimColorSchemeSetCompletionCallback(cCallback)
}

// MARK: - Mapping

//void vimSetInputMapCallback(InputMapCallback mapCallback);
//typedef void (*InputMapCallback)(const mapblock_T *mapping);
public typealias InputMapCallback = (_ mapping: Vim.MapBlock) -> Void
var vimInputMapCallback: InputMapCallback?

public func vimSetInputMapCallback(_ mapCallback: InputMapCallback?) {
    vimInputMapCallback = mapCallback
    let cCallback: clibvim.InputMapCallback? = if mapCallback != nil {
        {
            vimInputMapCallback!(Vim.MapBlock(rawValue: $0)!)
        }
    } else {
        nil
    }
    clibvim.vimSetInputMapCallback(cCallback)
}

/*
 * vimSetInputUnmapCallback
 *
 * Called when `unmap` family or `mapclear` is called
 * There are two arguments passed:
 * - `mode`: The mode (`iunmap`, `nunmap`, etc)
 * - `keys`: NULL if `mapclear` was used, or a `char_u*` describing the original keys
 */
//void vimSetInputUnmapCallback(InputUnmapCallback unmapCallback);
//typedef void (*InputUnmapCallback)(int mode, const char_u *orig_lhs);
public typealias InputUnmapCallback = (_ mode: Character, _ origLhs: String?) -> Void
var vimInputUnmapCallback: InputUnmapCallback?

public func vimSetInputUnmapCallback(_ unmapCallback: InputUnmapCallback?) {
    vimInputUnmapCallback = unmapCallback
    let cCallback: clibvim.InputUnmapCallback? = if unmapCallback != nil {
        {
            vimInputUnmapCallback!(Character($0), String?($1))
        }
    } else {
        nil
    }
    clibvim.vimSetInputUnmapCallback(cCallback)
}

// MARK: - Messages

//void vimSetMessageCallback(MessageCallback messageCallback);

public typealias MessagePriority = Vim.MessagePriority

public typealias MessageCallback = (_ title: String, _ message: String, _ priority: MessagePriority) -> Void
var vimMessageCallback: MessageCallback?

public func vimSetMessageCallback(_ callback: MessageCallback?) {
    vimMessageCallback = callback
    let cCallback: clibvim.MessageCallback? = if callback != nil {
        {
            message, kind, priority in
            let message = String(cString: message!)
            let kind = String(cString: kind!)
            let priority = MessagePriority(rawValue: priority)!
            vimMessageCallback?(message, kind, priority)
        }
    } else {
        nil
    }
    clibvim.vimSetMessageCallback(cCallback)
}

// MARK: - Misc

// Set a callback for when various entities should be cleared - ie, messages.
//void vimSetClearCallback(ClearCallback clearCallback);
//typedef void (*ClearCallback)(clearRequest_T clearInfo);
public typealias ClearCallback = (_ clearInfo: Vim.ClearRequest) -> Void
var vimClearCallback: ClearCallback?

public func vimSetClearCallback(_ callback: ClearCallback?) {
    vimClearCallback = callback
    let cCallback: clibvim.ClearCallback? = if callback != nil {
        {
            let clearInfo = Vim.ClearRequest(rawValue: $0)!
            vimClearCallback!(clearInfo)
        }
    } else {
        nil
    }
    clibvim.vimSetClearCallback(cCallback)
}

// Set a callback for when output is produced (ie, `:!ls`)
//void vimSetOutputCallback(OutputCallback outputCallback);
//typedef void (*OutputCallback)(char_u *cmd, char_u *output, int isSilent);
public typealias OutputCallback = (_ cmd: String, _ output: String, _ isSilent: Bool) -> Void
var vimOutputCallback: OutputCallback?

public func vimSetOutputCallback(_ callback: OutputCallback?) {
    vimOutputCallback = callback
    let cCallback: clibvim.OutputCallback? = if callback != nil {
        {
            let cmd = String(cString: $0!)
            let output = String(cString: $1!)
            let isSilent = Bool($2)
            vimOutputCallback!(cmd, output, isSilent)
        }
    } else {
        nil
    }
    clibvim.vimSetOutputCallback(cCallback)
}

//
//void vimSetFormatCallback(FormatCallback formatCallback);
//typedef void (*FormatCallback)(formatRequest_T *formatRequest);
public typealias FormatCallback = (_ formatRequest: Vim.FormatRequest) -> Void
var vimFormatCallback: FormatCallback?

public func vimSetFormatCallback(_ callback: FormatCallback?) {
    vimFormatCallback = callback
    let cCallback: clibvim.FormatCallback? = if callback != nil {
        {
            let formatRequest = Vim.FormatRequest(rawValue: $0!.pointee)!
            vimFormatCallback!(formatRequest)
        }
    } else {
        nil
    }
    clibvim.vimSetFormatCallback(cCallback)
}

//void vimSetGotoCallback(GotoCallback gotoCallback);
public typealias GotoCallback = (_ gotoInfo: Vim.GotoRequest) -> Bool
var vimGotoCallback: GotoCallback?

public func vimSetGotoCallback(_ callback: GotoCallback?) {
    vimGotoCallback = callback
    let cCallback: clibvim.GotoCallback? = if callback != nil {
        {
            let gotoInfo = Vim.GotoRequest(rawValue: $0)!
            return vimGotoCallback!(gotoInfo) |> CInt.init
        }
    } else {
        nil
    }
    clibvim.vimSetGotoCallback(cCallback)
}
//void vimSetTabPageCallback(TabPageCallback tabPageCallback);
//void vimSetDirectoryChangedCallback(DirectoryChangedCallback callback);
public typealias DirectoryChangedCallback = (_ directory: String) -> Void
var vimDirectoryChangedCallback: DirectoryChangedCallback?

public func vimSetDirectoryChangedCallback(_ callback: @escaping DirectoryChangedCallback) {
    vimDirectoryChangedCallback = callback
    let cCallback: clibvim.DirectoryChangedCallback? = {
        directory in
        let directory = String(cString: directory!)
        vimDirectoryChangedCallback?(directory)
    }
    clibvim.vimSetDirectoryChangedCallback(cCallback)
}

//void vimSetOptionSetCallback(OptionSetCallback callback);
public typealias OptionSetCallback = (_ optionSet: Vim.OptionSet) -> Void
var vimOptionSetCallback: OptionSetCallback?

public func vimSetOptionSetCallback(_ callback: OptionSetCallback?) {
    vimOptionSetCallback = callback
    let cCallback: clibvim.OptionSetCallback? = if callback != nil {
        {
            let optionSet = Vim.OptionSet(rawValue: $0!.pointee)!
            vimOptionSetCallback!(optionSet)
        }
    } else {
        nil
    }
    clibvim.vimSetOptionSetCallback(cCallback)
}

// MARK: - Operators

//void vimSetToggleCommentsCallback(ToggleCommentsCallback callback);
//typedef int (*ToggleCommentsCallback)(buf_T *buf, linenr_T startLine, linenr_T endLine, linenr_T *outCount, char_u ***outLines);

public typealias ToggleCommentsCallback = (_ buf: Vim.Buffer, _ startLine: Vim.LineNumber, _ endLine: Vim.LineNumber) -> [String]?
var vimToggleCommentsCallback: ToggleCommentsCallback?

public func vimSetToggleCommentsCallback(_ callback: ToggleCommentsCallback?) {
    vimToggleCommentsCallback = callback
    let cCallback: clibvim.ToggleCommentsCallback? = if callback != nil {
        { buf, startLine, endLine, outCount, outLines in
            guard let lines = vimToggleCommentsCallback!(buf!, startLine, endLine) else { return 0 }

            outLines!.pointee = lines.cPointerPointer
            outCount!.pointee = Vim.LineNumber(lines.count)

            return 1
        }
    } else {
        nil
    }
    clibvim.vimSetToggleCommentsCallback(cCallback)
}

/*
 * vimSetQuitCallback
 *
 * Called when a `:q`, `:qa`, `:q!` is called
 *
 * It is up to the libvim consumer how to handle the 'quit' call.
 * There are two arguments passed:
 * - `buffer`: the buffer quit was requested for
 * - `force`: a boolean if the command was forced (ie, if `q!` was used)
 */
//void vimSetQuitCallback(QuitCallback callback);
public typealias QuitCallback = (_ buffer: Vim.Buffer?, _ force: Bool) -> Void
var vimQuitCallback: QuitCallback?

public func vimSetQuitCallback(_ callback: QuitCallback?) {
    vimQuitCallback = callback
    let cCallback: clibvim.QuitCallback? = if callback != nil {
        {
            let buffer = $0
            let force = Bool($1)
            vimQuitCallback!(buffer, force)
        }
    } else {
        nil
    }
    clibvim.vimSetQuitCallback(cCallback)
}

/*
 * vimSetScrollCallback
 *
 * Called when the window should be scrolled (ie, `C-Y`, `zz`, etc).
 *
 */
//void vimSetScrollCallback(ScrollCallback callback);
//typedef void (*ScrollCallback)(scrollDirection_T dir, long count);
public typealias ScrollCallback = (_ dir: Vim.ScrollDirection, _ count: Int) -> Void
var vimScrollCallback: ScrollCallback?

public func vimSetScrollCallback(_ callback: ScrollCallback?) {
    vimScrollCallback = callback
    let cCallback: clibvim.ScrollCallback? = if callback != nil {
        {
            let dir = Vim.ScrollDirection(rawValue: $0)!
            let count = Int($1)
            vimScrollCallback!(dir, count)
        }
    } else {
        nil
    }
    clibvim.vimSetScrollCallback(cCallback)
}

/*
 * vimSetUnhandledEscapeCallback
 *
 * Called when <esc> is pressed in normal mode, but there is no
 * pending operator or action.
 *
 * This is intended for UI's to pick up and handle (for example,
 * to clear messages or alerts).
 */
//void vimSetUnhandledEscapeCallback(VoidCallback callback);
public typealias VoidCallback = () -> Void
var vimUnhandledEscapeCallback: VoidCallback?

public func vimSetUnhandledEscapeCallback(_ callback: VoidCallback?) {
    vimUnhandledEscapeCallback = callback
    let cCallback: clibvim.VoidCallback? = if callback != nil {
        {
            vimUnhandledEscapeCallback!()
        }
    } else {
        nil
    }
    clibvim.vimSetUnhandledEscapeCallback(cCallback)
}

// MARK: - Macros

//void vimMacroSetStartRecordCallback(MacroStartRecordCallback callback);
//typedef void (*MacroStartRecordCallback)(int regname);
public typealias MacroStartRecordCallback = (_ regName: Character) -> Void
var vimMacroStartRecordCallback: MacroStartRecordCallback?

public func vimMacroSetStartRecordCallback(_ callback: MacroStartRecordCallback?) {
    vimMacroStartRecordCallback = callback
    let cCallback: clibvim.MacroStartRecordCallback? = if callback != nil {
        {
            vimMacroStartRecordCallback!(Character($0))
        }
    } else {
        nil
    }
    clibvim.vimMacroSetStartRecordCallback(cCallback)
}
//void vimMacroSetStopRecordCallback(MacroStopRecordCallback callback);
//typedef void (*MacroStopRecordCallback)(int regname, char_u *regvalue);
public typealias MacroStopRecordCallback = (_ regName: Character, _ regValue: String) -> Void
var vimMacroStopRecordCallback: MacroStopRecordCallback?

public func vimMacroSetStopRecordCallback(_ callback: MacroStopRecordCallback?) {
    vimMacroStopRecordCallback = callback
    let cCallback: clibvim.MacroStopRecordCallback? = if callback != nil {
        {
            vimMacroStopRecordCallback!(Character($0), String(cString: $1!))
        }
    } else {
        nil
    }
    clibvim.vimMacroSetStopRecordCallback(cCallback)
}

// MARK: - Options

// TODO: get rid
public let p_enc = String(cString: clibvim.p_enc)

public func chartabsize(_ c: Character, _ col: Vim.ColumnNumber) -> Int {
    var c = CUnsignedChar(c.asciiValue!)
    return Int(clibvim.chartabsize(&c, col))
}

//void vimOptionSetTabSize(int tabSize);
public func vimOptionSetTabSize(_ tabSize: Int) {
    clibvim.vimOptionSetTabSize(CInt(tabSize))
}

//void vimOptionSetInsertSpaces(int insertSpaces);
public func vimOptionSetInsertSpaces(_ insertSpaces: Bool) {
    clibvim.vimOptionSetInsertSpaces(insertSpaces ? 1 : 0)
}

//int vimOptionGetInsertSpaces(void);
public func vimOptionGetInsertSpaces() -> Bool {
    Bool(clibvim.vimOptionGetInsertSpaces())
}

//int vimOptionGetTabSize(void);
public func vimOptionGetTabSize() -> Int {
    Int(clibvim.vimOptionGetTabSize())
}

// MARK: - Registers

//void vimRegisterGet(int reg_name, int *num_lines, char_u ***lines);
public func vimRegisterGet(_ regName: Int) -> [String] {
    let numLines = UnsafeMutablePointer<CInt>.allocate(capacity: 1)
    let lines = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?>.allocate(capacity: 1)
    clibvim.vimRegisterGet(CInt(regName), numLines, lines)
    let result = Array(lines.pointee!, count: UInt(numLines.pointee))
        .map { String(cString: $0!) }
    return result
}

public func vimRegisterGet(_ regName: Character) -> [String] {
    vimRegisterGet(Int(char: regName))
}

// MARK: - Undo

//int vimUndoSaveCursor(void);
//int vimUndoSaveRegion(linenr_T start_lnum, linenr_T end_lnum);
@discardableResult
public func vimUndoSaveRegion(_ startLnum: Vim.LineNumber, _ endLnum: Vim.LineNumber) -> Bool {
    Bool(clibvim.vimUndoSaveRegion(startLnum, endLnum))
}

/*
 * vimUndoSync(force)
 *
 * Create a sync point (a new undo level) - stop adding to current
 * undo entry, and start a new one.
 */
//void vimUndoSync(int force);
public func vimUndoSync(_ force: Bool) {
    clibvim.vimUndoSync(CInt(force))
}

// MARK: - Visual Mode

//int vimVisualGetType(void);
public func vimVisualGetType() -> Character {
    .init(clibvim.vimVisualGetType())
}

//void vimVisualSetType(int);
//int vimVisualIsActive(void);
public func vimVisualIsActive() -> Bool {
    clibvim.vimVisualIsActive() != 0
}
//int vimSelectIsActive(void);
public func vimSelectIsActive() -> Bool {
    clibvim.vimSelectIsActive() != 0
}

/*
 * vimVisualGetRange
 *
 * If in visual mode or select mode, returns the current range.
 * If not in visual or select mode, returns the last visual range.
 */
//void vimVisualGetRange(pos_T *startPos, pos_T *endPos);

public func vimVisualGetRange() -> (start: Vim.Position, end: Vim.Position) {
    var (start, end) = (Vim.Position(), Vim.Position())
    clibvim.vimVisualGetRange(&start, &end)
    return (start, end)
}

/*
 * vimVisualSetStart
 *
 * If in visual mode or select mode, set the visual start position.
 * The visual range is the range from this start position to the cursor position
 *
 * Only has an effect in visual or select modes.
 */
//void vimVisualSetStart(pos_T startPos);

public func vimVisualSetStart(_ startPos: Vim.Position) {
    clibvim.vimVisualSetStart(startPos)
}

// MARK: - Search

/*
 * vimSearchGetMatchingPair
 *
 * Returns the position of a matching pair,
 * based on the current buffer and cursor position
 *
 * result is NULL if no match found.
 */
//pos_T *vimSearchGetMatchingPair(int initc);
public func vimSearchGetMatchingPair(_ initc: Int) -> Vim.Position? {
    clibvim.vimSearchGetMatchingPair(CInt(initc))?.pointee
}

public func vimSearchGetMatchingPair(_ initc: Character) -> Vim.Position? {
    vimSearchGetMatchingPair(Int(char: initc))
}

/*
 * vimSearchGetHighlights
 *
 * Get highlights for the current search
 */
//void vimSearchGetHighlights(buf_T *buf, linenr_T start_lnum, linenr_T end_lnum,
//                            int *num_highlights,
//                            searchHighlight_T **highlights);
public func vimSearchGetHighlights(_ buf: Vim.Buffer, _ startLnum: UInt, _ endLnum: UInt) -> [Vim.SearchHighlight] {
    var numHighlights: CInt = 0
    var highlights: UnsafeMutablePointer<Vim.SearchHighlight>?
    clibvim.vimSearchGetHighlights(buf, linenr_T(startLnum), linenr_T(endLnum), &numHighlights, &highlights)
    return Array(UnsafeBufferPointer(start: highlights, count: Int(numHighlights)))
}

/*
 * vimSearchGetPattern
 *
 * Get the current search pattern
 */
//char_u *vimSearchGetPattern();
public func vimSearchGetPattern() -> String {
    clibvim.vimSearchGetPattern() |> {
        String(cString: $0)
    }
}

//void vimSetStopSearchHighlightCallback(VoidCallback callback);
var vimStopSearchHighlightCallback: VoidCallback?

public func vimSetStopSearchHighlightCallback(_ callback: VoidCallback?) {
    vimStopSearchHighlightCallback = callback
    let cCallback: clibvim.VoidCallback? = if callback != nil {
        {
            vimStopSearchHighlightCallback!()
        }
    } else {
        nil
    }
    clibvim.vimSetStopSearchHighlightCallback(cCallback)
}

// MARK: - Terminal

//void vimSetTerminalCallback(TerminalCallback callback);
public typealias TerminalCallback = (_ terminalRequest: Vim.TerminalRequest) -> Void
var vimTerminalCallback: TerminalCallback?

public func vimSetTerminalCallback(_ callback: TerminalCallback?) {
    vimTerminalCallback = callback
    let cCallback: clibvim.TerminalCallback? = if callback != nil {
        {
            vimTerminalCallback!(Vim.TerminalRequest(rawValue: $0!.pointee)!)
        }
    } else {
        nil
    }
    clibvim.vimSetTerminalCallback(cCallback)
}

// MARK: - Window

//int vimWindowGetWidth(void);
public func vimWindowGetWidth() -> Int {
    Int(clibvim.vimWindowGetWidth())
}
//int vimWindowGetHeight(void);
public func vimWindowGetHeight() -> Int {
    Int(clibvim.vimWindowGetHeight())
}
//int vimWindowGetTopLine(void);
public func vimWindowGetTopLine() -> Int {
    Int(clibvim.vimWindowGetTopLine())
}

//int vimWindowGetLeftColumn(void);
//
//void vimWindowSetWidth(int width);
public func vimWindowSetWidth(_ width: Int) {
    clibvim.vimWindowSetWidth(CInt(width))
}
//void vimWindowSetHeight(int height);
public func vimWindowSetHeight(_ height: Int) {
    clibvim.vimWindowSetHeight(CInt(height))
}
//void vimWindowSetTopLeft(int top, int left);
public func vimWindowSetTopLeft(_ top: Int, _ left: Int) {
    clibvim.vimWindowSetTopLeft(CInt(top), CInt(left))
}
//
//void vimSetWindowSplitCallback(WindowSplitCallback callback);
//typedef void (*WindowSplitCallback)(windowSplit_T splitType, char_u *fname);
public typealias WindowSplitCallback = (_ splitType: Vim.WindowSplit, _ fname: String) -> Void
var vimWindowSplitCallback: WindowSplitCallback?

public func vimSetWindowSplitCallback(_ callback: WindowSplitCallback?) {
    vimWindowSplitCallback = callback
    let cCallback: clibvim.WindowSplitCallback? = if callback != nil {
        {
            let splitType = Vim.WindowSplit(rawValue: $0)!
            let fname = String(cString: $1!)
            vimWindowSplitCallback!(splitType, fname)
        }
    } else {
        nil
    }
    clibvim.vimSetWindowSplitCallback(cCallback)
}

//void vimSetWindowMovementCallback(WindowMovementCallback callback);
//typedef void (*WindowMovementCallback)(windowMovement_T movementType, int count);
public typealias WindowMovementCallback = (_ movementType: Vim.WindowMovement, _ count: Int) -> Void
var vimWindowMovementCallback: WindowMovementCallback?

public func vimSetWindowMovementCallback(_ callback: WindowMovementCallback?) {
    vimWindowMovementCallback = callback
    let cCallback: clibvim.WindowMovementCallback? = if callback != nil {
        {
            let movementType = Vim.WindowMovement(rawValue: $0)!
            let count = Int($1)
            vimWindowMovementCallback!(movementType, count)
        }
    } else {
        nil
    }
    clibvim.vimSetWindowMovementCallback(cCallback)
}

// MARK: - Misc


//void vimSetClipboardGetCallback(ClipboardGetCallback callback);
//typedef int (*ClipboardGetCallback)(int regname, int *num_lines, char_u ***lines, int *blockType /* MLINE, MCHAR, MBLOCK */);
public typealias ClipboardGetCallback = (_ regName: Character) -> (lines: [String], blockType: Vim.MotionType)?

var vimClipboardGetCallback: ClipboardGetCallback?


public func vimSetClipboardGetCallback(_ callback: ClipboardGetCallback?) {
    vimClipboardGetCallback = callback
    let cCallback: clibvim.ClipboardGetCallback? = if callback != nil {
        { regName, numLines, cLines, cBlockType in
            guard let result = vimClipboardGetCallback!(Character(regName)) else {
                return CFalse
            }

            numLines!.pointee = CInt(result.lines.count)
            cLines!.pointee = result.lines.cPointerPointer
            cBlockType!.pointee = result.blockType.rawValue

            return CTrue
        }
    } else {
        nil
    }
    clibvim.vimSetClipboardGetCallback(cCallback)
}
//
//int vimGetMode(void);

public func vimGetMode() -> Vim.State {
    Vim.State(rawValue: clibvim.vimGetMode())
}

/* There are some modal input experiences that aren't considered
 full-fledged modes, but are nevertheless a modal input state.
 Examples include insert-literal (C-V, C-G), search w/ confirmation, etc.
 */
//subMode_T vimGetSubMode(void);

public func vimGetSubMode() -> Vim.SubMode {
    (clibvim.vimGetSubMode() |> Vim.SubMode.init)!
}
//
//int vimGetPendingOperator(pendingOp_T *pendingOp);
public func vimGetPendingOperator() -> Vim.PendingOperator? {
    var cPendingOp = Vim.PendingOperator.RawValue()
    guard Bool(clibvim.vimGetPendingOperator(&cPendingOp)) else {
        return nil
    }
    return Vim.PendingOperator(rawValue: cPendingOp)
}
//
//void vimSetYankCallback(YankCallback callback);

public typealias YankCallback = (_ yankInfo: Vim.YankInfo) -> Void
var vimYankCallback: YankCallback?

public func vimSetYankCallback(_ callback: YankCallback?) {
    vimYankCallback = callback
    let cCallback: clibvim.YankCallback? = if callback != nil {
        { yankInfoPointer in
            let yankInfo = Vim.YankInfo(yankInfoPointer!)
            vimYankCallback?(yankInfo)
        }
    } else {
        nil
    }
    clibvim.vimSetYankCallback(cCallback)
}

/* Callbacks for when the `:intro` and `:version` commands are used

 The Vim license has some specific requirements when implementing these methods:

 3) A message must be added, at least in the output of the ":version"
 command and in the intro screen, such that the user of the modified Vim
 is able to see that it was modified.  When distributing as mentioned
 under 2)e) adding the message is only required for as far as this does
 not conflict with the license used for the changes.
 */
//void vimSetDisplayIntroCallback(VoidCallback callback);
var vimDisplayIntroCallback: VoidCallback?

public func vimSetDisplayIntroCallback(_ callback: VoidCallback?) {
    vimDisplayIntroCallback = callback
    let cCallback: clibvim.VoidCallback? = if callback != nil {
        {
            vimDisplayIntroCallback!()
        }
    } else {
        nil
    }
    clibvim.vimSetDisplayIntroCallback(cCallback)
}

//void vimSetDisplayVersionCallback(VoidCallback callback);
var vimDisplayVersionCallback: VoidCallback?

public func vimSetDisplayVersionCallback(_ callback: VoidCallback?) {
    vimDisplayVersionCallback = callback
    let cCallback: clibvim.VoidCallback? = if callback != nil {
        {
            vimDisplayVersionCallback!()
        }
    } else {
        nil
    }
    clibvim.vimSetDisplayVersionCallback(cCallback)
}

/* vim: set ft=c : */
