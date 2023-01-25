//
//  Cancelable.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

public protocol Cancelable {
    func cancel()
}

extension Cancelable {
    public func append(into bag: CancelableBag) {
        bag.append(self)
    }
}
