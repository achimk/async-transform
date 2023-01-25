//
//  AsyncTransformable.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

public protocol AsyncTransformable {
    associatedtype Input
    associatedtype Output
    func transform(_ value: Input, completion: @escaping Completion<Output>) -> Cancelable
}

