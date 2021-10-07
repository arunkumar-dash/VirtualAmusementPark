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
        case userAlreadyExists
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
    var currentRide: Ride?
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
    /// Checks-in the user into the park and returns a Boolean based on `isInside`.
    ///
    /// Returns: Boolean value based on `isInside`.
    @discardableResult
    func checkIn() -> Bool {
        if isInside {
            return false
        }
        isInside = true
        return isInside
    }
    /// Checks-out the user into the park and returns a Boolean based on `isInside`.
    ///
    /// Returns: Boolean value based on `isInside`.
    func checkOut() -> Bool {
        if !isInside {
            return false
        }
        isInside = false
        return true
    }
    /// Adds a `Ride` object to the collection `rides` and returns `true` if success.
    ///
    /// Parameter ride: The `Ride` object to add.
    /// Returns: `true` if `Ride` object is successfully added to the collection `rides`
    /// Throws:
    /// - `Error.UserError.ageGroupUnsatisfied` if age group does not satisfy.
    /// - `Error.UserError.rideAlreadyAdded` if ride already added.
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
    /// Adds a `Refreshment` object to the collection `refreshments`.
    func add(refreshment: Refreshment) {
        refreshments.append(refreshment)
    }
    /// Returns a boolean value to check if a user can check-out.
    ///
    /// Returns: Boolean value based on the rides visited by the user.
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
    /// Returns the value of `isInside`.
    ///
    /// Returns: A `String` value based on `isInside` variable.
    func status() -> String {
        if isInside {
            return "\(name) is inside."
        } else {
            return "\(name) is outside."
        }
    }
    /// Marks the `Ride` object passed as a parameter as visited.
    ///
    /// Parameter ride: `Ride` object which should be visited.
    /// Throws:
    ///  - `RideError.rideNotFound` if ride not found.
    ///  - `RideError.alreadyVisitedRide` if ride object is already marked visited.
    func visitRide(ride: Ride) throws {
        if currentRide != nil {
            dump("You are currently in \(currentRide!.name), visit after ride ends!")
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
                ride.start()
                /// Marking the ride as visited.
                rides[ride] = true
            } catch RideError.StartError.rideClosed {
                dump("Cannot visit ride! Ride already closed.\nRide timings: \(ride.timing.description)")
            } catch RideError.StartError.rideUnderMaintenance {
                dump("Cannot visit ride! Ride is under maintenance.\nMaintenance details: \(ride.maintenanceDetails!)")
            } catch RideError.rideFull {
                dump("Ride full!")
            } catch RideError.userAlreadyInside {
                dump("User already inside!")
            }
        }
        if canCheckOut() {
            dump("All rides visited!\nUser \(name) can check out.")
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
