//
//  RatePoint.swift
//  RateTV
//
//  Created by toshi0383 on 2017/01/01.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import Foundation

struct RatePoint: CustomStringConvertible, Comparable {
    static let zero = RatePoint(number: 0, point: 0)
    let number: Int
    let point: Int
    init(number: Int, point: Int) {
        let p = point > 9 ? point%10 : point
        let n = point > 9 ? number+point/10 : number
        self.number = n
        self.point = p
    }
    init(float: Float) {
        self.number = Int(float*10)/10
        self.point = Int(float*10)-self.number*10
    }
    var description: String {
        return "\(number).\(point)"
    }
    var intValue: Int {
        assert(point == 0)
        return number
    }
    static func + (lhs: RatePoint, rhs: RatePoint) -> RatePoint {
        return RatePoint(number: lhs.number+rhs.number, point: lhs.point+rhs.point)
    }
    static func == (lhs: RatePoint, rhs: RatePoint) -> Bool {
        return lhs.number == rhs.number && lhs.point == rhs.point
    }
    static func < (lhs: RatePoint, rhs: RatePoint) -> Bool {
        if lhs.number == rhs.number {
            return lhs.point < rhs.point
        }
        return lhs.number < rhs.number
    }
    static func <= (lhs: RatePoint, rhs: RatePoint) -> Bool {
        return !(lhs.number > rhs.number)
    }
    static func * (left: RatePoint, int: Int) -> RatePoint {
        return RatePoint(number: left.number*int, point: left.point*int)
    }
    static func <= (left: RatePoint, int: Int) -> Bool {
        return !(left > RatePoint(number: int, point: 0))
    }
}
