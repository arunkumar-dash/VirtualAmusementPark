//
//  Time.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation

struct Time: Hashable, Comparable, CustomStringConvertible {
    enum Error: Swift.Error {
        case invalidHour
        case invalidMinute
    }
    
    var hours: UInt8
    var minutes: UInt8
    var description: String
    
    init (hours: UInt8, minutes: UInt8) throws {
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
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.hours == rhs.hours && lhs.minutes == rhs.minutes
    }
    
    static func < (lhs: Time, rhs: Time) -> Bool {
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
    
    mutating func add (hours: UInt8) {
        self.hours = (self.hours + hours) % 24
    }
    
    mutating func add (minutes: UInt8) {
        let extraHours = minutes / 60
        self.minutes += minutes % 60
        add(hours: extraHours)
    }
}
