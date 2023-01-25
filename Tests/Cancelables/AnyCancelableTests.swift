//
//  AnyCancelableTests.swift
//  AsyncTransformTests
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation
import XCTest
import AsyncTransform

class AnyCancelableTests: XCTestCase {
    
    func test_initialise_shouldNotBeCanceled() {
        let cancelable = AnyCancelable { }
        XCTAssertFalse(cancelable.isCanceled)
    }
    
    func test_cancel_shouldBeCaneled() {
        let cancelable = AnyCancelable { }
        cancelable.cancel()
        XCTAssertTrue(cancelable.isCanceled)
    }
    
    func test_cancel_shouldBeInvoked() {
        var isInvoked = false
        let cancelable = AnyCancelable {
            isInvoked = true
        }
        
        cancelable.cancel()
        
        XCTAssertTrue(isInvoked)
    }
    
    func test_multipleCancel_shouldBeInvokedOnce() {
        var invokeCounter = 0
        let cancelable = AnyCancelable {
            invokeCounter += 1
        }
        
        cancelable.cancel()
        cancelable.cancel()
        cancelable.cancel()
        
        XCTAssertEqual(invokeCounter, 1)
    }
}
