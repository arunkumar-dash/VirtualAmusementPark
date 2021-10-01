//
//  Timing.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation

struct Timing: CustomStringConvertible {
    var description: String
    
    let openingTime: Time
    let closingTime: Time
    
    enum Error: Swift.Error {
        case invalidTiming
    }
    
    init(opening openingTime: Time, closing closingTime: Time) throws {
        guard openingTime < closingTime && Timing.isValidTiming(time: openingTime) && Timing.isValidTiming(time: closingTime) else {
            throw Error.invalidTiming
        }
        self.openingTime = openingTime
        self.closingTime = closingTime
        description = "opening hours: \(openingTime.description) to \(closingTime.description)"
    }
    
    static func isValidTiming(time: Time) -> Bool {
        if time.hours < 24 && time.minutes < 60 {
            return true
        } else {
            return false
        }
    }
}
