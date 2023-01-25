//
//  NoopCancelable.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

// No operation cancelable
public final class NoopCancelable: Cancelable {
    
    public init() { }
    
    public func cancel() {
        // nothing to do
    }
}
