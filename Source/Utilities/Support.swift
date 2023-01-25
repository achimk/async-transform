//
//  Support.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

func abstractMethod(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Subclasses should override method!", file: file, line: line)
}
