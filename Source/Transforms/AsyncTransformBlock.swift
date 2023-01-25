//
//  AsyncTransformBlock.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

public typealias AsyncTransformBlock<Input, Output> = (Input, @escaping Completion<Output>) -> Cancelable
