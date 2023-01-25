//
//  CancelableBag.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

public class CancelableBag: Cancelable {
    private let lock = NSLock()
    private var cancelables: [Cancelable] = []
    public private(set) var isCanceled = false
    
    deinit {
        cancel()
    }
    
    public init() { }
    
    public func append(_ cancelables: Cancelable...) {
        appendOrCancel(cancelables)
    }
    
    public func append(_ cancelables: [Cancelable]) {
        appendOrCancel(cancelables)
    }
    
    public func cancel() {
        if isCanceled {
            return
        }

        lock.lock()
        defer { lock.unlock() }

        cancelables.forEach { $0.cancel() }
        cancelables = []
        isCanceled = true
    }
    
    private func appendOrCancel(_ cancelables: [Cancelable]) {
        if isCanceled {
            cancelables.forEach { $0.cancel() }
        } else {
            self.cancelables.append(contentsOf: cancelables)
        }
    }
}
