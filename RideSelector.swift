//
//  RideSelector.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 13/10/21.
//

import Foundation

/// Returns a `Ride` instance based on the ride type from input.
struct RideSelector {
    static func getRideBasedOnType
    (
        name: String, duration: Time, timing: Timing, ageGroup: AgeGroup,
        minimumCapacity: UInt, maximumCapacity: UInt
    ) -> Ride {
        while true {
            print("Select ride type: ")
            print("[1] Water ride")
            print("[2] Dry ride")
            let input = InputHandler.getIntegerInput()
            switch input {
            case 1:
                return WaterRide(name: name, duration: duration, timing: timing, ageGroup: ageGroup, minimumCapacity: minimumCapacity, maximumCapacity: maximumCapacity)
            case 2:
                return DryRide(name: name, duration: duration, timing: timing, ageGroup: ageGroup, minimumCapacity: minimumCapacity, maximumCapacity: maximumCapacity)
            default:
                print("Invalid number!")
            }
        }
    }
}
