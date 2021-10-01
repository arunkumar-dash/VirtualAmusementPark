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
            user!.checkIn()
            users.insert(user!)
        }
    }
    
    func userController() {
        var user: User? = nil
        print("Attempting to login...")
        let name = getInput("Enter name: ")
        let mobile = getInput("Enter mobile: ")
        let age = UInt8(getInput("Enter age: "))!
        var tempUser: User? = nil
        do {
            tempUser = try User(name: name, age: age, mobile: mobile)
            if tempUser != nil {
                if let idx = users.firstIndex(of: tempUser!) {
                    user = users[idx]
                } else {
                    print("Cannot find user")
                    return
                }
            } else {
                print("Login attempt failed!")
                return
            }
        } catch let error {
            print("Login fsiled!")
            print(error)
            return
        }
    userLoop:
        while true {
            print("[1] Visit ride")
            print("[2] Buy refreshments")
            print("[3] Check-out")
            print("[4] Exit but don't check out")
            let input = getInput()
            if UInt8(input) == nil {
                print("Invalid input!")
                continue userLoop
            }
            switch UInt8(input)! {
            case 1:
                for ride in user!.rides {
                    print(ride.key.description)
                }
                let rideName = getInput("Enter ride name: ")
                for ride in user!.rides {
                    if ride.key.name == rideName {
                        DispatchQueue.global().async {
                            do {
                                try user!.visitRide(ride: ride.key)
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
            case 2:
                for (idx, refreshment) in Reception.refreshments.enumerated() {
                    print("[\(idx + 1)]\t\t\(refreshment.name)")
                }
                let idx = getInput()
                if Int(idx) != nil && Int(idx)! < Reception.refreshments.count {
                    user!.refreshments.append(Reception.refreshments[Int(idx)! - 1])
                }  else {
                    print("Invalid choice!")
                }
            case 3:
                if user!.checkOut() == false {
                    print("Checked out already!")
                    break userLoop
                }
            case 4:
                break userLoop
            default:
                print("Invalid selection!")
            }
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
