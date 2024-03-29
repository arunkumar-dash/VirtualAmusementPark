//
//  Time.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation

/// Overloaded `-=` operator for `Time` and `Int`
func -=(lhs: inout Time, rhs: Int) {
    let totalMinutes = Int(lhs.minutes) + Int(lhs.hours) * 60 - rhs
    lhs.hours = UInt8((totalMinutes / 60) % 24)
    lhs.minutes = UInt8(totalMinutes % 60)
}

protocol TimeProtocol: Comparable, Hashable, CustomStringConvertible {
    var hours: UInt8 { get }
    var minutes: UInt8 { get }
    var description: String { get }
    mutating func add(hours: UInt8)
    mutating func add(minutes: UInt8)
    static func <(lhs: Self, rhs: Self) -> Bool
    static func +(lhs: Self, rhs: Self) -> Self
}
/// Returns a `Time` object consisting of hours, minutes
struct Time: TimeProtocol {
    enum Error: Swift.Error {
        case invalidHour
        case invalidMinute
    }
    
    var hours: UInt8
    var minutes: UInt8
    var description: String
    
    init(hours: UInt8, minutes: UInt8) throws {
        guard hours >= 0 && hours < 24 else {
            throw Error.invalidHour
        }
        guard minutes >= 0 && minutes < 60 else {
            throw Error.invalidMinute
        }
        self.hours = hours
        self.minutes = minutes
        description = "\(hours):\(minutes)"
    }
    /// Adds `hours` to the `Time` object
    ///
    /// - Parameter hours: Number of hours to be added as UInt8
    mutating func add(hours: UInt8) {
        self.hours = (self.hours + hours) % 24
    }
    /// Adds `minutes` to the `Time` object
    ///
    /// - Parameter minutes: Number of minutes to be added as UInt8
    mutating func add(minutes: UInt8) {
        let extraHours = (self.minutes + minutes) / 60
        self.minutes = (self.minutes + minutes) % 60
        add(hours: extraHours)
    }
    /// Overloaded `+` operator for two `Time` objects
    static func +(lhs: Time, rhs: Time) -> Time {
        var finalTime = lhs
        finalTime.add(hours: rhs.hours)
        finalTime.add(minutes: rhs.minutes)
        return finalTime
    }
}
/// Conforming to Comparable
extension Time: Comparable{
    /// Overloaded `==` operator for two `Time` objects as a requirement for `Equatable`
    static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.hours == rhs.hours && lhs.minutes == rhs.minutes
    }
    /// Overloaded `<` operator for two `Time` objects
    static func <(lhs: Time, rhs: Time) -> Bool {
        if lhs.hours < rhs.hours {
            return true
        } else if lhs.hours == rhs.hours {
            if lhs.minutes < rhs.minutes {
                return true
            }
            return false
        } else {
            return false
        }
    }
}
