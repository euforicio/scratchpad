//
//  Constants.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-02-27.
//

import Foundation

var resourcePath: String {
    if let resourcePath = Bundle.module.resourcePath {
        resourcePath
    } else {
        fatalError("Could not find resource path")
    }
}

let collateral = "\(resourcePath)/collateral"
let testfile = "\(collateral)/testfile.txt"
let lines100 = "\(collateral)/lines_100.txt"
let curswant = "\(collateral)/curswant.txt"

let FALSE = false
let TRUE = true
let OK = true

// C increment operator
postfix operator ++

extension Numeric {
    @discardableResult
    static postfix func ++(n: inout Self) -> Self {
        let valueBeforeIncrement = n
        n += 1
        return valueBeforeIncrement
    }
}

