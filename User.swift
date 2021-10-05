//
//  User.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation

/// Enumeration for specific age categories
enum AgeGroup {
    case adult
    case child
}
/// Returns an `User` instance
class User {
    /// Enumeration consisting of Errors possible due to user input
    enum Error: Swift.Error {
        case invalidMobileFormat
        enum UserError: Swift.Error {
            case ageGroupUnsatisfied
            case rideAlreadyAdded
        }
    }
    
    let name: String
    let age: UInt8
    /// Computed property of `AgeGroup` type
    var ageGroup: AgeGroup {
        get {
            if age < 18 {
                return .child
            } else {
                return .adult
            }
        }
    }
    let mobile: String
    /// Dictionary to check if the user has visited the ride
    var rides: Dictionary<Ride, Bool> = [:]
    /// Array consisting of `Refreshment` objects
    var refreshments: Array<Refreshment> = []
    /// Helper variable which stores the status of the `User`
    private var isInside: Bool = false
    /// Stores the `Ride` instance which is currently being visited by the `User`
    var visitingRide: Ride?
    /// Computed property which returns the total amount spent by the user.
    var totalAmountSpent: Float {
        get {
            var sum: Float = 0
            for (ride, isVisited) in rides {
                if isVisited {
                    sum += ride.cost
                }
            }
            return sum
        }
    }
    
    init(name: String, age: UInt8, mobile: String) throws {
        self.name = name
        self.age = age
        guard mobile.count == 10 else {
            throw Error.invalidMobileFormat
        }
        self.mobile = mobile
    }
    /// Function which checks-in the user into the park.
    @discardableResult
    func checkIn() -> Bool {
        if isInside {
            return false
        }
        isInside = true
        return isInside
    }
    /// Function which checks-out the user from the park.
    func checkOut() -> Bool {
        if !isInside {
            return false
        }
        isInside = false
        return true
    }
    /// Function to add a `Ride` object to the collection.
    @discardableResult
    func add(ride: Ride) throws -> Bool {
        if ageGroup == .child && ride.allowedAgeGroup == .adult {
            print("Not allowed")
            throw Error.UserError.ageGroupUnsatisfied
        }
        if rides.updateValue(false, forKey: ride) == nil {
            return true
        } else {
            throw Error.UserError.rideAlreadyAdded
        }
    }
    /// Function to add a `Refreshment` object to the collection.
    func add(refreshment: Refreshment) {
        refreshments.append(refreshment)
    }
    /// Boolean function to check if a user can check-out
    func canCheckOut() -> Bool {
        for (ride, isVisited) in rides {
            if !isVisited && !ride.isUnderMaintenance() {
                return false
            }
        }
        return true
    }
    /// Prints a receipt listing the amount spent
    func showReceipt() {
        for (ride, isVisited) in rides {
            if ride.isUnderMaintenance() == false {
                print("\(ride.name)\t\t\(ride.cost)", terminator: " ")
                if isVisited == false {
                    print("- Ride wasn't visited!")
                }
                print("")
            }
        }
        for refreshment in refreshments {
            print("\(refreshment.name)\t\t\(refreshment.cost)")
        }
        print(String(repeating: "-", count: 15))
        print("Total:\t\t\(totalAmountSpent)")
    }
    /// Returns the value of `isInside`
    func status() -> String {
        if isInside {
            return "\(name) is inside."
        } else {
            return "\(name) is outside."
        }
    }
    /// Function to visit a `Ride`
    func visitRide(ride: Ride) throws {
        if visitingRide != nil {
            print("[You are currently in \(visitingRide!.name), visit after ride ends!]")
            return
        }
        if rides[ride] == nil {
            throw RideError.rideNotFound
        } else if rides[ride] == true {
            throw RideError.alreadyVisitedRide
        } else {
            do {
                try ride.add(user: self)
                /// Starts the ride to function
                try ride.start()
                /// Marking the ride as visited.
                rides[ride] = true
            } catch RideError.StartError.rideClosed {
                print("[Cannot visit ride! Ride already closed.\nRide timings: \(ride.timing.description)]")
            } catch RideError.StartError.rideUnderMaintenance {
                print("[Cannot visit ride! Ride is under maintenance.\nMaintenance details: \(ride.maintenanceDetails!)]")
            } catch RideError.rideFull {
                print("[Ride full!]")
            } catch RideError.userAlreadyInside {
                print("[User already inside!]")
            }
        }
        if canCheckOut() {
            print("[All rides visited!\nUser \(name) can check out.]")
        }
    }
}

extension User: Equatable {
    /// Overloaded `==` operator for two `User` objects
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name && lhs.mobile == rhs.mobile
    }
}

extension User: Hashable {
    /// Hash function involving only `name` and `mobile`
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(mobile)
    }
}
