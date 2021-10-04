//
//  Ride.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 30/09/21.
//

import Foundation

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

enum Maintenance: CaseIterable {
    case watersShortage
    case powerOutage
    case wornOut
}

class Ride: Hashable, CustomStringConvertible {
    let name: String
    let cost: Float
    let duration: Time
    let timing: Timing
    let allowedAgeGroup: AgeGroup
    var usersInside: Set<User> = []
    let minimumCapacity: UInt
    let maximumCapacity: UInt
    var maintenanceDetails: Maintenance?
    var currentlyRunning: Bool = false
    
    var description: String
    
    init(name: String, cost: Float, duration: Time, timing: Timing, ageGroup allowedAgeGroup: AgeGroup, minimumCapacity: UInt, maximumCapacity: UInt) {
        self.name = name
        self.cost = cost
        self.duration = duration
        self.timing = timing
        self.allowedAgeGroup = allowedAgeGroup
        self.minimumCapacity = minimumCapacity
        self.maximumCapacity = maximumCapacity
        description = "\(name)\t$\(cost)\t\(allowedAgeGroup)"
    }
    
    func isUnderMaintenance() -> Bool {
        if maintenanceDetails == nil {
            return false
        } else {
            return true
        }
    }
    
    func isOpen() -> Bool {
        let currentTime = Reception.currentTime
        if ((currentTime + duration) <= timing.closingTime) && (currentTime > timing.openingTime) {
            return true
        } else {
            return false
        }
    }
    
    func start() throws {
        if currentlyRunning {
            print("Ride is currently running!")
            print("Users inside: ")
            for user in usersInside {
                print(user.name, terminator: ", ")
            }
            print("")
            return
        }
        while usersInside.count < minimumCapacity {
            print("Waiting for Users...")
            sleep(10)
        }
        print("Ride \(self.name) started...")
        currentlyRunning = true
        for _ in 1...(duration.hours * 60 + duration.minutes) {
            if isUnderMaintenance() {
                break
            }
            sleep(1)
        }
        print("Ride \(self.name) stopped...")
        currentlyRunning = false
        for user in usersInside {
            user.visitingRide = nil
        }
        usersInside.removeAll()
    }
    
    func add(user: User) throws {
        if isOpen() == false {
            throw RideError.StartError.rideClosed
        }
        if isUnderMaintenance() {
            throw RideError.StartError.rideUnderMaintenance
        }
        user.visitingRide = self
        if usersInside.count == maximumCapacity {
            throw RideError.rideFull
        }
        guard usersInside.insert(user).inserted else {
            throw RideError.userAlreadyInside
        }
        print("User: \(user.name) onboarded in \(self.name).")
    }
    
    static func == (lhs: Ride, rhs: Ride) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}
