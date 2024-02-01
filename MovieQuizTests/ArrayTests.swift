//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Dmitry on 31.01.2024.
//

import XCTest
@testable import MovieQuiz

class ArrrayTests : XCTestCase {
    func testGetValueInRange() throws {
        // given
        
        let array = [1,1,2,3,5]
        
        //when
        
        let value = array[safe: 2]
        
        //then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
    }
    func testGetValueOutRange() throws {
        
        let array = [1,1,2,3,5]
        
        
        let value = array[safe: 20]
        
        XCTAssertNil(value)
        
    }
}
