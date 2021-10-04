//
//  User.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation


enum AgeGroup {
    case adult
    case child
}

class User: Hashable, Equatable {
    enum Error: Swift.Error {
        case invalidMobileFormat
        enum UserError: Swift.Error {
            case ageGroupUnsatisfied
            case rideAlreadyAdded
        }
    }
    
    let name: String
    let age: UInt8
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
    var rides: Dictionary<Ride, Bool> = [:]
    var refreshments: Array<Refreshment> = []
    private var isInside: Bool = false
    var visitingRide: Ride? = nil
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
    
    @discardableResult
    func checkIn() -> Bool {
        if isInside {
            return false
        }
        isInside = true
        return isInside
    }
    
    func checkOut() -> Bool {
        if !isInside {
            return false
        }
        isInside = false
        return true
    }
    
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
    
    func add(refreshment: Refreshment) {
        refreshments.append(refreshment)
    }
    
    func canCheckOut() -> Bool {
        for (ride, isVisited) in rides {
            if !isVisited && !ride.isUnderMaintenance() {
                return false
            }
        }
        return true
    }
    
    func showReceipt() {
        for (ride, isVisited) in rides {
            if isVisited {
                print("\(ride.name)\t\t\(ride.cost)")
            }
        }
        for refreshment in refreshments {
            print("\(refreshment.name)\t\t\(refreshment.cost)")
        }
        print(String(repeating: "-", count: 15))
        print("Total:\t\t\(totalAmountSpent)")
    }
    
    func status() -> String {
        if isInside {
            return "\(name) is inside."
        } else {
            return "\(name) is outside."
        }
    }
    
    func visitRide(ride: Ride) throws {
        if visitingRide != nil {
            print("You are currently in \(visitingRide!.name), visit after ride ends!")
            return
        }
        if rides[ride] == nil {
            throw RideError.rideNotFound
        } else if rides[ride] == true {
            throw RideError.alreadyVisitedRide
        } else {
            rides[ride] = true
            do {
                try ride.add(user: self)
                try ride.start()
            } catch RideError.StartError.rideClosed {
                print("Cannot visit ride! Ride already closed.\nRide timings: \(ride.timing.description)")
            } catch RideError.StartError.rideUnderMaintenance {
                print("Cannot visit ride! Ride is under maintenance.\nMaintenance details: \(ride.maintenanceDetails!)")
            } catch RideError.rideFull {
                print("Ride full!")
            } catch RideError.userAlreadyInside {
                print("User already inside!")
            }
        }
        if canCheckOut() {
            print("All rides visited!\nUser \(name) can check out.")
        }
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name && lhs.mobile == rhs.mobile
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(mobile)
    }
}

