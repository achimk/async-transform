//
//  AsyncTransformableTests.swift
//  AsyncTransformTests
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation
import XCTest
import AsyncTransform

class AsyncTransformableTests: XCTestCase {
    private var token: Cancelable?
    
    override func tearDown() {
        token = nil
        super.tearDown()
    }
    
    func test_makeTransformerFromMapClosure_shouldCreateCorrectBehaviour() {
        let map: (Int) throws -> String = {
            String(describing: $0)
        }
        
        var result: String?
        token = make(map).transform(1, completion: { result = try? $0.get() })
        
        XCTAssertEqual(result, "1")
    }
    
    func test_makeTransformerFromBlock_shouldCreateCorrectBehaviour() {
        let increment: AsyncTransformBlock<Int, Int> = { (value, completion) in
            completion(.success(value + 1))
            return NoopCancelable()
        }
        
        var result: Int?
        token = make(increment).transform(1, completion: { result = try? $0.get() })
        
        XCTAssertEqual(result, 2)
    }
    
    func test_pipeTransformer_shouldProduceCorrectResult() {
        let initial: AsyncTransformBlock<Int, Int> = { (value, completion) in
            completion(.success(value))
            return NoopCancelable()
        }
        
        let increment: AsyncTransformBlock<Int, Int> = { (value, completion) in
            completion(.success(value + 1))
            return NoopCancelable()
        }
        
        var result: Int?
        token = make(initial).then(increment).transform(1, completion: { result = try? $0.get() })
        
        XCTAssertEqual(result, 2)
    }
    
    func test_pipelineTransformers_shouldCompleteWithCorrectResult() {
        let increment: AsyncTransformBlock<Int, Int> = { (value, completion) in
            completion(.success(value + 1))
            return NoopCancelable()
        }
        
        let multiply: AsyncTransformBlock<Int, Int> = { (value, completion) in
            completion(.success(value * value))
            return NoopCancelable()
        }
        
        let decrement: AsyncTransformBlock<Int, Int> = { (value, completion) in
            completion(.success(value - 1))
            return NoopCancelable()
        }
        
        var result: Int? = nil
        token = make(increment)
            .then(multiply)
            .then(decrement)
            .transform(1) { result = try? $0.get() }
        
        XCTAssertEqual(result, 3)
    }
    
    func test_pipelineTransformers_shouldCompleteWithCorrectOrder() {
        let transform1 = SpyTransformer<Int, Int>()
        let transform2 = SpyTransformer<Int, Int>()
        let transform3 = SpyTransformer<Int, Int>()
        
        var order: [Int] = []
        transform1.onSuccess = { order.append($0) }
        transform2.onSuccess = { order.append($0) }
        transform3.onSuccess = { order.append($0) }
        
        token = transform1
            .then(transform2)
            .then(transform3)
            .transform(0, completion: { _ in })
        
        transform1.success(with: 1)
        transform2.success(with: 2)
        transform3.success(with: 3)
        
        XCTAssertEqual(order, [1, 2, 3])
    }
    
    func test_successfulPipeline_shouldCompleteWithValue() {
        let transform1 = SpyTransformer<Int, Int>()
        let transform2 = SpyTransformer<Int, Int>()
        let transform3 = SpyTransformer<Int, Int>()
        
        var result: Result<Int, Error>?
        token = transform1
            .then(transform2)
            .then(transform3)
            .transform(0, completion: { result = $0 })
        
        transform1.success(with: 1)
        transform2.success(with: 2)
        transform3.success(with: 3)
        
        XCTAssertTrue(isSuccess(result))
    }
    
    func test_failurePipeline_shouldCompleteWithError() {
        let transform1 = SpyTransformer<Int, Int>()
        let transform2 = SpyTransformer<Int, Int>()
        let transform3 = SpyTransformer<Int, Int>()
        
        var result: Result<Int, Error>?
        token = transform1
            .then(transform2)
            .then(transform3)
            .transform(0, completion: { result = $0 })
        
        transform1.success(with: 1)
        transform2.failure()
        transform3.success(with: 3)
        
        XCTAssertTrue(isFailure(result))
    }
    
    func test_canceledPipeline_shouldCompleteWithError() {
        let transform1 = SpyTransformer<Int, Int>()
        let transform2 = SpyTransformer<Int, Int>()
        let transform3 = SpyTransformer<Int, Int>()
        
        var result: Result<Int, Error>?
        token = transform1
            .then(transform2)
            .then(transform3)
            .transform(0, completion: { result = $0 })
        
        transform1.success(with: 1)
        transform2.cancel()
        transform3.success(with: 3)
        
        XCTAssertTrue(isCancel(result))
    }
}

fileprivate func isSuccess<T, E: Error>(_ result: Result<T, E>?) -> Bool {
    guard let result = result else {
        return false
    }
    switch result {
    case .success: return true
    case .failure: return false
    }
}

fileprivate func isFailure<T, E: Error>(_ result: Result<T, E>?) -> Bool {
    guard let result = result else {
        return false
    }
    switch result {
    case .success: return false
    case .failure: return true
    }
}

fileprivate func isCancel<T, E: Error>(_ result: Result<T, E>?) -> Bool {
    guard let result = result else {
        return false
    }
    switch result {
    case .success: return false
    case .failure(let error): return (error as? CancelError) != nil
    }
}


