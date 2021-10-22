//
//  Ride.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 30/09/21.
//

import Foundation

/// Possible Errors while operating `Ride`
enum RideError: Error {
    case rideNotFound
    enum StartError: Error {
        case rideClosed
        case rideUnderMaintenance
    }
    case rideFull
    case userAlreadyInside
    case alreadyVisitedRide
}
/// Maintenance types as Enumeration
enum Maintenance: String, CaseIterable {
    case waterShortage
    case powerOutage
    case wornOut
}
/// Returns a `Ride` object
class Ride<T: TimeProtocol, U: UserRideProtocol>: CustomStringConvertible {
    let name: String
    let cost: Float
    let duration: T
    let timing: Timing<T>
    let allowedAgeGroup: AgeGroup
    /// Set consisting of `User` instances inside this `Ride`
    var usersInside: Set<U> = []
    let minimumCapacity: UInt
    /// Consists of `Maintenance` object in case the ride is under maintenance
    private var maintenanceDetails: Maintenance?
    /// Boolean variable indicating if the `Ride` is currently running
    var currentlyRunning: Bool = false
    var rideStarted = false
    
    var description: String
    
    init(
        name: String, cost: Float, duration: T, timing: Timing<T>, ageGroup allowedAgeGroup: AgeGroup,
        minimumCapacity: UInt
    ) {
        self.name = name
        self.cost = cost
        self.duration = duration
        self.timing = timing
        self.allowedAgeGroup = allowedAgeGroup
        self.minimumCapacity = minimumCapacity
        description = "\(name)\t$\(cost)\t\(allowedAgeGroup)"
    }
    /// Returns a boolean value based on `maintenanceDetails` property.
    ///
    /// - Returns: A boolean value based on `maintenanceDetails` property.
    func isUnderMaintenance() -> Bool {
        if maintenanceDetails == nil {
            return false
        } else {
            return true
        }
    }
    /// Checks `timing` with `currentTime` and returns `true` if `timing` lies after `currentTime`.
    ///
    /// - Returns: A boolean value based on the `timing`.
    func isOpen() -> Bool {
        let currentTime = Controller.getCurrentTime() as! T
        if ((currentTime + duration) <= timing.closingTime) && (currentTime > timing.openingTime) {
            return true
        } else {
            return false
        }
    }
    /// Starts the ride.
    func start() {
        if currentlyRunning {
            dump("Ride is currently running!")
            dump("Users inside: ")
            for user in usersInside {
                print(user.name, terminator: ", ")
            }
            print("")
            return
        }
        /// Waiting until `usersInside` reach the `minimumCapacity`
        while usersInside.count < minimumCapacity {
            dump("Waiting for Users...")
            sleep(10)
        }
        dump("Ride \(self.name) started...")
        currentlyRunning = true
        /// Running the ride
        for _ in 1...(duration.hours * 60 + duration.minutes) {
            if isUnderMaintenance() {
                break
            }
            sleep(1)
        }
        dump("Ride \(self.name) stopped...")
        currentlyRunning = false
        /// Removing `User` instances from the `Ride`
        for user in usersInside {
            user.removeCurrentRide()
        }
        discardAllUsers()
    }
    /// Adds `user` object to the `usersInside` collection.
    ///
    ///  - Parameter user: `User` object which needs to be added.
    ///  - Throws:
    ///   - `RideError.StartError.rideClosed` if ride is closed.
    ///   - `RideError.StartError.rideUnderMaintenance` if ride is under maintenance.
    ///   - `RideError.rideFull` if ride is full.
    ///   - `RideError.userAlreadyInside` if user is inside the ride.
    func add(user: U) throws {
        if isOpen() == false {
            throw RideError.StartError.rideClosed
        }
        if isUnderMaintenance() {
            throw RideError.StartError.rideUnderMaintenance
        }
        user.setCurrentRide(self)
        guard usersInside.insert(user).inserted else {
            throw RideError.userAlreadyInside
        }
        dump("User: \(user.name) onboarded in \(self.name).")
        if rideStarted == false {
            rideStarted = true
            start()
            rideStarted = false
        }
    }
    
    /// Updates the `maintenanceDetails` variable with `Maintenance` object
    ///
    /// - Parameter maintenance: The `Maintenance` object to be updated
    func add(maintenance: Maintenance) {
        self.maintenanceDetails = maintenance
    }
    
    /// Marks the `maintenanceDetails` variable as `nil`
    func removeMaintenance() {
        self.maintenanceDetails = nil
    }
    
    /// Returns the value in `maintenanceDetails`
    ///
    /// - Returns: `Maintenance` object from `maintenanceDetails`
    func getMaintenanceDetails() -> Maintenance? {
        return self.maintenanceDetails
    }
    
    /// Discards all instances inside `usersInside` collection
    func discardAllUsers() {
        self.usersInside.removeAll()
    }
}

extension Ride: Hashable {
    /// Overloaded `==` operator for two `Ride` objects
    static func ==(lhs: Ride, rhs: Ride) -> Bool {
        return lhs.name == rhs.name
    }
    /// Hash function involving only `name`
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}

class WaterRide<T: TimeProtocol, U: UserRideProtocol>: Ride<T, U> {
    init(
        name: String, duration: T, timing: Timing<T>,
        ageGroup allowedAgeGroup: AgeGroup, minimumCapacity: UInt
    ) {
        super.init(name: name, cost: 25, duration: duration, timing: timing, ageGroup: allowedAgeGroup, minimumCapacity: minimumCapacity)
    }
    /// Starts the `WaterRide`.
    override func start() {
        dump("Starting water ride...")
        super.start()
    }
}

class DryRide<T: TimeProtocol, U: UserRideProtocol>: Ride<T, U> {
    init(
        name: String, duration: T, timing: Timing<T>, ageGroup
        allowedAgeGroup: AgeGroup, minimumCapacity: UInt
    ) {
        super.init(
            name: name, cost: 20, duration: duration, timing: timing,
                   ageGroup: allowedAgeGroup, minimumCapacity: minimumCapacity
        )
    }
    /// Starts the `DryRide`.
    override func start() {
        dump("Starting dry ride...")
        super.start()
    }
}
