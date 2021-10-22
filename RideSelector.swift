//
//  RideSelector.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 13/10/21.
//

import Foundation

/// Returns a `RideSelector` instance
struct RideSelector<T: TimeProtocol, U: UserProtocol> {
    /// Returns a `Ride` instance based on the ride type from input with the parameters
    ///
    /// - Parameters:
    ///   - name: The name of the `Ride`
    ///   - duration: The `Time` object indicating the duration of the `Ride`
    ///   - timing: The `Timing` of the `Ride`
    ///   - ageGroup: The allowed age group
    ///   - minimumCapacity: Minimum capacity required to start the ride
    /// - Returns: A `Ride` object specific to the ride type
    static func getRideBasedOnType
    (
        name: String, duration: T, timing: Timing<T>,
        ageGroup: AgeGroup, minimumCapacity: UInt
    ) -> Ride<T, U> {
        while true {
            print("Select ride type: ")
            Printer.printOption(optionNumber: 1, optionName: "Water ride")
            Printer.printOption(optionNumber: 2, optionName: "Dry ride")
            let input = InputHandler.getIntegerInput("option number")
            switch input {
            case 1:
                return WaterRide(name: name, duration: duration, timing: timing, ageGroup: ageGroup, minimumCapacity: minimumCapacity)
            case 2:
                return DryRide(name: name, duration: duration, timing: timing, ageGroup: ageGroup, minimumCapacity: minimumCapacity)
            default:
                Printer.printError("Invalid number")
            }
        }
    }
}
