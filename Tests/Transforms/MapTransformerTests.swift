//
//  MapTransformerTests.swift
//  AsyncTransform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation
import XCTest
import AsyncTransform

class MapTransformerTests: XCTestCase {
    private var token: Cancelable?
    
    override func tearDown() {
        token = nil
        super.tearDown()
    }
    
    func test_mapSuccess_shouldTransformWithoutError() {
        let transformer = MapTransformer<Int, String>(toStringSuccess)
        
        var result: String? = "0"
        token = transformer.transform(1) { result = try? $0.get() }
        
        XCTAssertEqual(result, "1")
    }
    
    func test_mapFailure_shouldTransformWithError() {
        let transformer = MapTransformer<Int, String>(toStringFailure)
        
        var result: String? = "0"
        token = transformer.transform(1) { result = try? $0.get() }
        
        XCTAssertNil(result)
    }
    
    func test_performSuccess_shouldTransformWithoutError() {
        let spy = SpyTransformer<Int, String>()
        let transformer = MapTransformer<Int, String>(spy.transform)
        
        var result: String? = "0"
        token = transformer.transform(1) { result = try? $0.get() }
        spy.success(with: "2")
        
        XCTAssertTrue(spy.state.isSuccess)
        XCTAssertEqual(result, "2")
    }
    
    func test_performFailure_shouldTransformWithError() {
        let spy = SpyTransformer<Int, String>()
        let transformer = MapTransformer<Int, String>(spy.transform)
        
        var result: String? = "0"
        token = transformer.transform(1) { result = try? $0.get() }
        spy.failure()
        
        XCTAssertTrue(spy.state.isFailure)
        XCTAssertNil(result)
    }
    
    func test_performCancel_shouldTransformWithError() {
        let spy = SpyTransformer<Int, String>()
        let transformer = MapTransformer<Int, String>(spy.transform)
        
        var result: String? = "0"
        token = transformer.transform(1) { result = try? $0.get() }
        token?.cancel()
        
        XCTAssertTrue(spy.state.isCanceled)
        XCTAssertNil(result)
    }
}

fileprivate func toStringSuccess<T>(_ value: T) throws -> String {
    return String(describing: value)
}

fileprivate func toStringFailure<T>(_ value: T) throws -> String {
    throw NSError(domain: "Test", code: 0, userInfo: nil)
}
