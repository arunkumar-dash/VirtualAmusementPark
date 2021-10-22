//
//  Timing.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation

/// Returns a `Timing` object consisting of `openingTime` and `closingTime` `Time` objects
struct Timing<T: TimeProtocol>: CustomStringConvertible {
    var description: String
    
    let openingTime: T
    let closingTime: T
    
    enum Error: Swift.Error {
        case invalidTiming
    }
    
    init(opening openingTime: T, closing closingTime: T) throws {
        guard openingTime < closingTime && Timing.isValidTiming(time: openingTime) && Timing.isValidTiming(time: closingTime) else {
            throw Error.invalidTiming
        }
        self.openingTime = openingTime
        self.closingTime = closingTime
        description = "opening hours: \(openingTime.description) to \(closingTime.description)"
    }
    
    /// Static function to check if the `Timing` is valid after modification
    ///
    /// - Parameter time: The `Time` object passed to check if it is valid
    /// - Returns: `true` if the `Time` object is valid, else `false`
    static func isValidTiming(time: T) -> Bool {
        if time.hours < 24 && time.minutes < 60 {
            return true
        } else {
            return false
        }
    }
}
