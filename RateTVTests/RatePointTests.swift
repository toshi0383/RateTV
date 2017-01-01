//
//  RatePointTests.swift
//  RateTV
//
//  Created by toshi0383 on 2017/01/01.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import XCTest
@testable import RateTV

class RatePointTests: XCTestCase {
    func testSimple() {
        let rp = RatePoint(number: 1, point: 5)
        XCTAssertEqual(rp.number, 1)
        XCTAssertEqual(rp.point, 5)
    }
    func testMoveUp() {
        let rp1 = RatePoint(number: 1, point: 10)
        XCTAssertEqual(rp1.number, 2)
        XCTAssertEqual(rp1.point, 0)
        let rp2 = RatePoint(number: 1, point: 19)
        XCTAssertEqual(rp2.number, 2)
        XCTAssertEqual(rp2.point, 9)
    }
    func testAddition() {
        let rp1 = RatePoint(number: 1, point: 9)
        XCTAssertEqual(rp1.number, 1)
        XCTAssertEqual(rp1.point, 9)
        let rp2 = RatePoint(number: 1, point: 9)
        XCTAssertEqual(rp2.number, 1)
        XCTAssertEqual(rp2.point, 9)
        let added = rp1 + rp2
        XCTAssertEqual(added.number, 3)
        XCTAssertEqual(added.point, 8)
    }
    func testMultiply() {
        let rp = RatePoint(number: 1, point: 9)
        XCTAssertEqual(rp.number, 1)
        XCTAssertEqual(rp.point, 9)
        let multiplied = rp * 2
        XCTAssertEqual(multiplied.number, 3)
        XCTAssertEqual(multiplied.point, 8)
    }
    func testInitFromFloat() {
        let rp1 = RatePoint(float: 1.9999)
        XCTAssertEqual(rp1.number, 1)
        XCTAssertEqual(rp1.point, 9)
        let rp2 = RatePoint(float: 2.1118)
        XCTAssertEqual(rp2.number, 2)
        XCTAssertEqual(rp2.point, 1)
    }
}
