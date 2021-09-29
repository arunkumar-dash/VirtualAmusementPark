//
//  User.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation

class User {
    enum AgeGroup {
        case adult
        case child
    }
    
    enum Error: Swift.Error {
        case invalidMobileFormat
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
    var totalAmountSpent: Double = 0
    
    init (name: String, age: UInt8, mobile: String) throws {
        self.name = name
        self.age = age
        guard mobile.count != 10 else {
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
    func add(ride: Ride) -> Bool{
        if rides.updateValue(false, forKey: ride) == nil {
            return true
        } else {
            return false
        }
    }
    
    func canCheckOut() -> Bool {
        
    }
    
    func showReceipt() -> String {
        
    }
    
    func status() -> String {
        
    }
    
    func visitRide(ride: Ride) throws {
        
    }
}
