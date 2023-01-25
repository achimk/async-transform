//
//  AsyncTransformer.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

open class AsyncTransformer<Input, Output>: AsyncTransformable {
    
    public init() { }
    
    public func transform(_ value: Input, completion: @escaping Completion<Output>) -> Cancelable {
        abstractMethod()
    }
}
