//
//  Reception.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation

struct Reception {
    private var users: Set<User> = []
    private var usersLog: Array<User> = []
    static var rides: Array<Ride> = []
    static var currentTime: Time {
        get {
            do {
                return try Time(hours: currentHour, minutes: currentMinute)
            } catch {
                fatalError()
            }
        }
        set {
            currentHour = newValue.hours
            currentMinute = newValue.minutes
            if currentMinute >= 60 {
                currentHour += 1
                currentMinute %= 60
            }
            if currentHour >= 24 {
                currentHour %= 24
            }
        }
    }
    static private var currentHour: UInt8 = 0
    static private var currentMinute: UInt8 = 0
    static var refreshments: Array<Refreshment> = []
    
    @discardableResult
    func showAvailableRides() -> Bool{
        print("Available rides: ")
        var availableRidesCount = 0
        for (count, ride) in Reception.rides.enumerated() {
            if !ride.isUnderMaintenance() {
                print("[\(count + 1)]\t\(ride.description)")
                availableRidesCount += 1
            }
        }
        guard availableRidesCount > 0 else {
            print("No rides available!")
            return false
        }
        return true
    }
    
    private func getInput(_ string: String = "") -> String {
        var input: String? = nil
        while input == nil {
            print(string)
            input = readLine()
        }
        return input!
    }
    
    mutating func checkIn() {
        var user: User? = nil
        print("Enter user details: ")
        let userName: String
        let userAge: UInt8
        var mobile: String
        userName = getInput("Enter name: ")
        var tempUserAge = getInput("Enter age: ")
        while UInt8(tempUserAge) == nil {
            tempUserAge = getInput("Enter a valid age: ")
        }
        userAge = UInt8(tempUserAge)!
        mobile = getInput("Enter mobile(without spaces): ")
        while true {
            do {
                user = try User(name: userName, age: userAge, mobile: mobile)
                users.insert(user!)
                break
            } catch User.Error.invalidMobileFormat {
                mobile = getInput("Enter a 10-digit mobile number: ")
            } catch {
                print("User check-in was unsuccessful.")
                return
            }
        }
        guard showAvailableRides() else {
            return
        }
        var flag = true
        repeat {
            let rideNumber = getInput("Enter ride number: ")
            if let index = Int(rideNumber) {
                if index <= Reception.rides.count {
                    let currentRide = Reception.rides[index - 1]
                    if currentRide.isUnderMaintenance() {
                        print("Ride not available!")
                    } else if user != nil {
                        if user!.add(ride: currentRide) {
                            print("Ride added successfully!")
                        } else {
                            print("Ride already added!")
                        }
                    } else {
                        print("User doesn't exist!")
                    }
                } else {
                    print("Invalid ride number!")
                }
            } else {
                print("Invalid ride number!")
            }
            let response = getInput("Do you want to add another ride? ('y'/'n'): ")
            if response.lowercased() != "y" {
                flag = false
            }
        } while flag
        if user != nil {
            users.insert(user!)
        }
    }
    
    mutating func checkOut() {
        let name = getInput("Enter name: ")
        let mobile = getInput("Enter mobile: ")
        let age = UInt8(getInput("Enter age: "))!
        var tempUser: User? = nil
        do {
            tempUser = try User(name: name, age: age, mobile: mobile)
            if tempUser != nil {
                tempUser!.showReceipt()
                if users.remove(tempUser!) == nil {
                    print("User doesn't exist!")
                } else {
                    usersLog.append(tempUser!)
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    func showCheckedOutUsers() {
        for oldUser in usersLog {
            print("Name: \(oldUser.name)\t\tAge: \(oldUser.age)\t\tMobile: \(oldUser.mobile)")
        }
    }
    
    func showCheckedInUsers() {
        for user in users {
            print("Name: \(user.name)\t\tAge: \(user.age)\t\tMobile: \(user.mobile)")
        }
    }
    
    func totalUsersCheckedIn() -> Int {
        return users.count
    }
}
