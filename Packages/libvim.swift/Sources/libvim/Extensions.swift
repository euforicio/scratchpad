//
//  Extensions.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-06.
//

import clibvim

public typealias CString = UnsafeMutablePointer<char_u>?

extension Character {
    init(_ cUnsignedChar: CUnsignedChar) {
        self.init(
            cUnsignedChar |> Unicode.Scalar.init
        )
    }

    init(_ cInt: CInt) {
        let scalar = Unicode.Scalar(Int(cInt))
        self.init(scalar!)
    }

    init(_ cChar: CChar) {
        self.init(
            cChar |> CUnsignedChar.init
        )
    }
}

extension SignedInteger {
    init(char: Character) {
        self = Self(char.asciiValue!)
    }
}

extension Array where Element == String {
    var cPointerPointer: UnsafeMutablePointer<UnsafeMutablePointer<CUnsignedChar>?> {
        cCharPointerPointer.withMemoryRebound(to: UnsafeMutablePointer<CUnsignedChar>?.self, capacity: count) { $0 }
    }

    var cCharPointerPointer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?> {
        // Convert each string to null-terminated UTF-8 representation
        let utf8Arrays = map { $0.utf8CString }

        // Create an array of pointers to these null-terminated UTF-8 representations
        var pointers: [UnsafeMutablePointer<CChar>?] = utf8Arrays.map {
            let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: $0.count)
            $0.enumerated().forEach { (index, element) in
                pointer.advanced(by: index).pointee = element
            }
            pointer.advanced(by: $0.count - 1).pointee = 0 // Null-terminate the string
            return pointer
        }

        // Append a nil pointer to mark the end of the array
        pointers.append(nil)

        // Convert the array of pointers to UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>?
        let pointerArray = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: pointers.count)
        pointerArray.initialize(from: &pointers, count: pointers.count)

        return pointerArray
    }

    init(_ cPointer: UnsafeMutablePointer<UnsafeMutablePointer<CUnsignedChar>?>, count: CInt) {
        self.init()

        // Iterate over the C array and convert each null-terminated string to Swift String
        for i in 0..<count {
            // Safely access the C string pointer
            let cString = cPointer.advanced(by: Int(i)).pointee

            // Convert the C string to Swift String
            let swiftString = String(cString: cString!)
            self.append(swiftString)
        }
    }
}

extension Array {
    init(_ cPointer: UnsafeMutablePointer<Element>?) {
        self.init()

        var cPointer = cPointer
        // Iterate over the elements until reaching the end
        while let value = cPointer?.pointee {
            append(value)
            cPointer = cPointer?.advanced(by: 1)
        }
    }

    init(_ cPointer: UnsafeMutablePointer<Element>, count: UInt) {
        self.init()

        // Iterate over the C array and convert each null-terminated string to Swift String
        for i in 0..<count {
            append(cPointer.advanced(by: Int(i)).pointee)
        }
    }
}

extension String {
    func withMutableCString<Result>(_ body: (UnsafeMutablePointer<Int8>) throws -> Result) rethrows -> Result {
        try withCString {
            try body(UnsafeMutablePointer(mutating: $0))
        }
    }

    var uCString: UnsafeMutablePointer<UInt8> {
        cString.withMemoryRebound(to: UInt8.self, capacity: count) { $0 }
    }

    var cString: UnsafeMutablePointer<CChar> {
        let cString = UnsafeMutablePointer<CChar>.allocate(capacity: utf8.count + 1)
        cString.initialize(from: Array(utf8CString), count: utf8.count + 1)
        return cString
    }
}

extension Optional where Wrapped == String {
    init(_ cString: UnsafePointer<UInt8>?) {
        self = if let cString {
            String(cString: cString)
        } else {
            nil
        }
    }

    init(_ cString: UnsafeMutablePointer<UInt8>?) {
        self = if let cString {
            String(cString: cString)
        } else {
            nil
        }
    }
}

extension Bool {
    init(_ cInt: some Numeric) {
        self = cInt != 0
    }
}

extension Numeric {
    init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}

// Function Composition
precedencegroup SingleForwardPipe {
    associativity: left
    higherThan: BitwiseShiftPrecedence
}

infix operator |> : SingleForwardPipe

func |> <A, B>(x: A, f: (A) -> B) -> B {
    f(x)
}

let CFalse = CInt(0)
let CTrue = CInt(1)
