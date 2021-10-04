//
//  Reception.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 29/09/21.
//

import Foundation
/// Main entry to the amusement park.
/// Contains instances of users entered into the park through this reception.
struct Reception {
    /// A set consisting of `User` instances.
    private var users: Set<User> = []
    /// An array consisting of `User`s checked-out.
    private var usersLog: Array<User> = []
    /// A static array consisting of rides in the park.
    static var rides: Array<Ride> = []
    /// Static variable which stores the time since start of execution.
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
    /// Static variable which utility for `currentTime`.
    static private var currentHour: UInt8 = 0
    /// Static variable which utility for `currentTime`.
    static private var currentMinute: UInt8 = 0
    /// A static array consisting of refreshments in the park.
    static var refreshments: Array<Refreshment> = []
    
    /// Function that prints the available rides.
    @discardableResult
    func showAvailableRides() -> Bool{
        print("Available rides: ")
        var availableRidesCount = 0
        for (count, ride) in Reception.rides.enumerated() {
            if ride.isUnderMaintenance() == false && ride.currentlyRunning == false {
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
    
    /// Function that prints the available rides even if it is currently running.
    @discardableResult
    func showAvailableRidesForMaintenance() -> Bool{
        print("Available rides: ")
        var availableRidesCount = 0
        for (count, ride) in Reception.rides.enumerated() {
            if ride.isUnderMaintenance() == false {
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
    
    /// Utility function for getting string input
    private func getInput(_ string: String = "") -> String {
        var input: String? = nil
        while input == nil {
            print(string)
            input = readLine()
        }
        return input!
    }
    
    /// Mutating function used to add `User` objects into `users` set.
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
        /// Error handling mobile number
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
        /// Display available rides
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
                        do {
                            if try user!.add(ride: currentRide) {
                                print("Ride added successfully!")
                            }
                        } catch let error {
                            print(error)
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
    
    /// Function which allows users to login
    func userController() {
        var user: User? = nil
        print("Attempting to login...")
        let name = getInput("Enter name: ")
        let mobile = getInput("Enter mobile: ")
        var tempUser: User? = nil
        do {
            /// Creating temporary `User` instance to access in O(1) time
            tempUser = try User(name: name, age: 1, mobile: mobile)
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
            print("Login failed!")
            print(error)
            return
        }
        print("Login success!")
        /// Access options for user
    userLoop:
        while true {
            print("----- User Window -----")
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
                var isValid = true
                for ride in user!.rides {
                    if ride.key.name == rideName {
                        DispatchQueue.global().async {
                            do {
                                try user!.visitRide(ride: ride.key)
                            } catch let error {
                                print(error)
                            }
                        }
                        isValid = false
                        break userLoop
                    }
                }
                if isValid {
                    print("Ride not available!")
                }
            case 2:
                if Reception.refreshments.isEmpty {
                    print("No refreshments available!")
                    break userLoop
                }
                for (idx, refreshment) in Reception.refreshments.enumerated() {
                    print("[\(idx + 1)]\t\t\(refreshment.name)")
                }
                let idx = getInput("Enter refreshment number: ")
                if Int(idx) != nil && Int(idx)! <= Reception.refreshments.count && Int(idx)! > 0{
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
    
    /// Function which removes `User` object from `users` and adds to `usersLog`.
    mutating func checkOut() {
        let name = getInput("Enter name: ")
        let mobile = getInput("Enter mobile: ")
        var tempUser: User? = nil
        do {
            tempUser = try User(name: name, age: 1, mobile: mobile)
            if tempUser != nil {
                if let oldUser = users.remove(tempUser!) {
                    oldUser.showReceipt()
                    usersLog.append(oldUser)
                } else {
                    print("User doesn't exist!")
                }
            } else {
                print("Invalid details!")
            }
        } catch let error {
            print(error)
        }
    }
    
    /// Prints `usersLog`.
    func showCheckedOutUsers() {
        if usersLog.isEmpty {
            print("No users found!")
            return
        }
        for oldUser in usersLog {
            print("Name: \(oldUser.name)\t\tAge: \(oldUser.age)\t\tMobile: \(oldUser.mobile)")
        }
    }
    
    /// Prints `users`.
    func showCheckedInUsers() {
        if users.isEmpty {
            print("No users found!")
            return
        }
        for user in users {
            print("Name: \(user.name)\t\tAge: \(user.age)\t\tMobile: \(user.mobile)")
        }
    }
    
    /// Prints count of `users`
    func totalUsersCheckedIn() -> Int {
        return users.count
    }
}
