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
/// To conform to `IndividualUserProtocol`, implement `name`, `age`, `ageGroup`,
/// `mobile`, `totalAmountSpent`.
protocol IndividualUserProtocol {
    var name: String { get }
    var age: UInt8 { get }
    var ageGroup: AgeGroup { get }
    var mobile: String { get }
    var totalAmountSpent: Float { get }
}
/// To conform to `UserRideProtocol`, implement`add(ride:)`, `visit(ride:)`,
/// `getCurrentRide()`, `setCurrentRide()`, `setCurrentRide(ride:)`,
/// `removeCurrentRide()`. `getRidesVisitedPair()`,
protocol UserRideProtocol {
    associatedtype T: TimeProtocol
    associatedtype U: UserProtocol
    func add(ride: Ride<T, U>) throws -> Bool
    func visit(ride: Ride<T, U>) throws
    func getCurrentRide() -> Ride<T, U>?
    func setCurrentRide(_ ride: Ride<T, U>)
    func removeCurrentRide()
    func getRidesVisitedPair() -> Dictionary<Ride<T, U>, Bool>
}
/// To conform to `UserProtocol`, implement `isRiding()`, `checkIn()`, `checkOut()`,
/// `add(refreshment:)`, `canCheckOut()`, `printReceipt()`,
/// `appendRefreshment(refreshment:)`and conform to
/// `IndividualUserProtocol`, `UserRideProtocol` and `Hashable` protocol
protocol UserProtocol: IndividualUserProtocol, UserRideProtocol, Hashable {
    func isRiding() -> Bool
    @discardableResult
    func checkIn() -> Bool
    func checkOut() -> Bool
    func add(refreshment: Refreshment)
    func canCheckOut() -> Bool
    func printReceipt()
    func appendRefreshment(_ refreshment: Refreshment)
}
/// Returns an `User` instance
class User<T: TimeProtocol, U: UserProtocol>: UserProtocol {
    typealias T = T
    
    typealias U = U
    
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
    private var rides: Dictionary<Ride<T, U>, Bool> = [:]
    /// Array consisting of `Refreshment` objects
    private var refreshments: Array<Refreshment> = []
    /// Helper variable which stores the status of the `User`
    private var isInside: Bool = false
    /// Stores the `Ride` instance which is currently being visited by the `User`
    private var currentRide: Ride<T, U>?
    /// Returns true if user is currently in aride, else false
    func isRiding() -> Bool {
        if getCurrentRide() == nil {
            return false
        } else {
            return true
        }
    }
    /// Computed property which returns the total amount spent by the user.
    var totalAmountSpent: Float {
        get {
            var sum: Float = 0
            for (ride, isVisited) in rides {
                if isVisited {
                    sum += ride.cost
                }
            }
            for refreshment in refreshments {
                sum += refreshment.cost
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
    /// - Returns: Boolean value based on `isInside`.
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
    /// - Returns: Boolean value based on `isInside`.
    func checkOut() -> Bool {
        if !isInside {
            return false
        }
        isInside = false
        return true
    }
    /// Adds a `Ride` object to the collection `rides` and returns `true` if success.
    ///
    /// - Parameter ride: The `Ride` object to add.
    /// - Returns: `true` if `Ride` object is successfully added to the collection `rides`
    /// - Throws:
    ///   - `Error.UserError.ageGroupUnsatisfied` if age group does not satisfy.
    ///   - `Error.UserError.rideAlreadyAdded` if ride already added.
    @discardableResult
    func add(ride: Ride<T, U>) throws -> Bool {
        if ageGroup == .child && ride.allowedAgeGroup == .adult {
            Printer.printError("Not allowed")
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
    /// - Returns: Boolean value based on the rides visited by the user.
    func canCheckOut() -> Bool {
        for (ride, isVisited) in rides {
            if !isVisited && !ride.isUnderMaintenance() {
                return false
            }
        }
        return true
    }
    /// Prints a receipt listing the amount spent
    func printReceipt() {
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
        print(String(repeating: "-", count: 20))
        print("Total:\t\t\(totalAmountSpent)")
    }
    /// Marks the `Ride` object passed as a parameter as visited.
    ///
    /// - Parameter ride: `Ride` object which should be visited.
    /// - Throws:
    ///   - `RideError.rideNotFound` if ride not found.
    ///   - `RideError.alreadyVisitedRide` if ride object is already marked visited.
    func visit(ride: Ride<T, U>) throws {
        if getCurrentRide() != nil {
            dump("You are currently in \(getCurrentRide()!.name), visit after ride ends!")
            return
        }
        if rides[ride] == nil {
            throw RideError.rideNotFound
        } else if rides[ride] == true {
            throw RideError.alreadyVisitedRide
        } else {
            do {
                // Adding user into the ride
                try ride.add(user: U.self as! U)
                // Marking the ride as visited
                rides[ride] = true
            } catch RideError.StartError.rideClosed {
                dump("Cannot visit ride! Ride already closed.\nRide timings: \(ride.timing.description)")
            } catch RideError.StartError.rideUnderMaintenance {
                dump("Cannot visit ride! Ride is under maintenance.\nMaintenance details: \(ride.getMaintenanceDetails()!)")
            } catch RideError.rideFull {
                dump("Ride full!")
            } catch RideError.userAlreadyInside {
                dump("User already inside!")
            }
        }
        if canCheckOut() {
            dump("All rides visited! User \(name) can check out.")
        }
    }
    
    /// Returns the `Ride` object which the user is currently visiting
    ///
    /// - Returns: The `Ride` object which the user is currently visiting
    func getCurrentRide() -> Ride<T, U>? {
        return currentRide
    }
    
    /// Updates the `currentRide` variable with the `Ride` object passed
    ///
    /// - Parameter ride: The `Ride` object to be updated with
    func setCurrentRide(_ ride: Ride<T, U>) {
        currentRide = ride
    }
    
    /// Updates the `currentRide` variable to `nil`
    func removeCurrentRide() {
        currentRide = nil
    }
    
    func getRidesVisitedPair() -> Dictionary<Ride<T, U>, Bool> {
        return rides
    }
    
    func appendRefreshment(_ refreshment: Refreshment) {
        refreshments.append(refreshment)
    }
}

extension User: Equatable {
    /// Overloaded `==` operator for two `User` objects
    static func ==(lhs: User, rhs: User) -> Bool {
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
