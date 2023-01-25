//
//  TransformerState.swift
//  AsyncTransform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation
import AsyncTransform

enum TransformerState<Input, Output> {
    case idle
    case invoked(Input, Completion<Output>)
    case success(Output)
    case failure(Error)
    case canceled
    
    var isIdle: Bool {
        if case .idle = self {
            return true
        }
        return false
    }
    
    var isInvoked: Bool {
        if case .invoked = self {
            return true
        }
        return false
    }
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var isFailure: Bool {
        if case .failure = self {
            return true
        }
        return false
    }
    
    var isCanceled: Bool {
        if case .canceled = self {
            return true
        }
        return false
    }
    
    var input: Input? {
        if case .invoked(let value, _) = self {
            return value
        }
        return nil
    }
    
    var output: Output? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
    
    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
