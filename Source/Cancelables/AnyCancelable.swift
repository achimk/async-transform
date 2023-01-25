//
//  AnyCancelable.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

public class AnyCancelable: Cancelable {
    private let lock = NSLock()
    private let block: () -> Void
    public private(set) var isCanceled = false
    
    public init(_ block: @escaping () -> Void) {
        self.block = block
    }
    
    public func cancel() {
        if isCanceled {
            return
        }

        lock.lock()
        defer { lock.unlock() }
        
        block()
        isCanceled = true
    }
}
