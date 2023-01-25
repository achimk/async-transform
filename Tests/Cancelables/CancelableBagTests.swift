//
//  CancelableBagTests.swift
//  AsyncTransformTests
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation
import XCTest
import AsyncTransform

class CancelableBagTests: XCTestCase {
    
    func test_initialise_shouldNotBeCanceled() {
        let bag = CancelableBag()
        XCTAssertFalse(bag.isCanceled)
    }
    
    func test_cancel_shouldBeCaneled() {
        let bag = CancelableBag()
        bag.cancel()
        XCTAssertTrue(bag.isCanceled)
    }
    
    func test_deinit_shouldCancelAll() {
        let cancelable1 = AnyCancelable { }
        let cancelable2 = AnyCancelable { }
        let cancelable3 = AnyCancelable { }
        
        var bag = CancelableBag()
        bag.append(cancelable1, cancelable2, cancelable3)
        bag = CancelableBag()
        
        XCTAssertTrue(cancelable1.isCanceled)
        XCTAssertTrue(cancelable2.isCanceled)
        XCTAssertTrue(cancelable3.isCanceled)
    }
    
    func test_appendOnCanceled_shouldCancelImmediately() {
        let cancelable1 = AnyCancelable { }
        let cancelable2 = AnyCancelable { }
        let cancelable3 = AnyCancelable { }
        
        let bag = CancelableBag()
        bag.cancel()
        bag.append(cancelable1, cancelable2, cancelable3)
        
        XCTAssertTrue(cancelable1.isCanceled)
        XCTAssertTrue(cancelable2.isCanceled)
        XCTAssertTrue(cancelable3.isCanceled)
    }
    
    func test_appendByVariadicFunction_shouldAppendAll() {
        let cancelable1 = AnyCancelable { }
        let cancelable2 = AnyCancelable { }
        let cancelable3 = AnyCancelable { }
        
        let bag = CancelableBag()
        bag.append(cancelable1, cancelable2, cancelable3)
        bag.cancel()
        
        XCTAssertTrue(cancelable1.isCanceled)
        XCTAssertTrue(cancelable2.isCanceled)
        XCTAssertTrue(cancelable3.isCanceled)
    }
    
    func test_appendByArrayFunction_shouldAppendAll() {
        let cancelable1 = AnyCancelable { }
        let cancelable2 = AnyCancelable { }
        let cancelable3 = AnyCancelable { }
        
        let bag = CancelableBag()
        bag.append([cancelable1, cancelable2, cancelable3])
        bag.cancel()
        
        XCTAssertTrue(cancelable1.isCanceled)
        XCTAssertTrue(cancelable2.isCanceled)
        XCTAssertTrue(cancelable3.isCanceled)
    }
    
    func test_cancelForAppended_shouldInvokeForAll() {
        var isInvoked1 = false
        let cancelable1 = AnyCancelable {
            isInvoked1 = true
        }
        
        var isInvoked2 = false
        let cancelable2 = AnyCancelable {
            isInvoked2 = true
        }
        
        var isInvoked3 = false
        let cancelable3 = AnyCancelable {
            isInvoked3 = true
        }
        
        let bag = CancelableBag()
        bag.append(cancelable1, cancelable2, cancelable3)
        bag.cancel()
        
        XCTAssertTrue(isInvoked1)
        XCTAssertTrue(isInvoked2)
        XCTAssertTrue(isInvoked3)
    }
    
    func test_multipleCancelForAppended_shouldBeInvokedOnceForAll() {
        var invokeCounter1 = 0
        let cancelable1 = AnyCancelable {
            invokeCounter1 += 1
        }
        
        var invokeCounter2 = 0
        let cancelable2 = AnyCancelable {
            invokeCounter2 += 1
        }
        
        var invokeCounter3 = 0
        let cancelable3 = AnyCancelable {
            invokeCounter3 += 1
        }
        
        let bag = CancelableBag()
        bag.append(cancelable1, cancelable2, cancelable3)
        bag.cancel()
        bag.cancel()
        bag.cancel()
        
        XCTAssertEqual(invokeCounter1, 1)
        XCTAssertEqual(invokeCounter2, 1)
        XCTAssertEqual(invokeCounter3, 1)
    }
}
