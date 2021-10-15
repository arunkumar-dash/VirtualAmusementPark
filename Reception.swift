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
    var users: Set<User> = []
    /// An array consisting of `User`s checked-out.
    var usersLog: Array<User> = []
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
    /// Starts the currentTime to run asynchronously.
    func startTimer() {
        ///Increments one minute per second in `currentTime`
        DispatchQueue.global().async {
            while true {
                sleep(1)
                Reception.currentTime.add(minutes: 1)
            }
        }
    }
    
    /// Prints the available rides and returns false if no rides available, else true.
    ///
    /// Returns: Boolean value based on the available rides count.
    @discardableResult
    func showAvailableRides() -> Bool {
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
    
    /// Prints the available rides even if it is currently running and returns false if no rides available, else true.
    ///
    /// Returns: Boolean value based on the available rides count.
    @discardableResult
    func showAvailableRidesForMaintenance() -> Bool {
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
    
    /// Adds `User` objects into `users` set.
    @discardableResult
    mutating func checkIn() -> User?{
        var user: User?
        return DispatchQueue.global().sync {
            print("Enter user details: ")
            let userName: String
            let userAge: UInt8
            var mobile: String
            userName = InputHandler.getInput("Enter name: ")
            userAge = UInt8(InputHandler.getIntegerInput("Enter age: "))
            mobile = InputHandler.getInput("Enter mobile(without spaces): ")
            /// Error handling mobile number
            while true {
                do {
                    user = try User(name: userName, age: userAge, mobile: mobile)
                    if users.contains(user!) {
                        throw User.Error.userAlreadyExists
                    }
                    user!.checkIn()
                    users.insert(user!)
                    break
                } catch User.Error.invalidMobileFormat {
                    mobile = InputHandler.getInput("Enter a 10-digit mobile number: ")
                } catch let error {
                    print("User check-in was unsuccessful.", error)
                    return nil
                }
            }
            /// Display available rides
            guard showAvailableRides() else {
                return user
            }
            var flag = true
            repeat {
                let index = InputHandler.getIntegerInput("Enter ride number: ")
                if index <= Reception.rides.count && index > 0 {
                    let currentRide = Reception.rides[Int(index) - 1]
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
                let response = InputHandler.getInput("Do you want to add another ride? ('y'/'n'): ")
                if response.lowercased() != "y" {
                    flag = false
                }
            } while flag
            return user
        }
    }
    
    /// Removes `User` object from `users` and adds to `usersLog`.
    mutating func checkOut() {
        DispatchQueue.global().sync {
            let name = InputHandler.getInput("Enter name: ")
            let mobile = InputHandler.getInput("Enter mobile: ")
            var tempUser: User?
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
            print("Name: \(user.name)\t\tAge: \(user.age)\t\tMobile: \(user.mobile)", terminator: " ")
            if user.currentRide != nil {
                print("Currently in \(user.currentRide!.name)")
            }
            print("")
        }
        print("Total user checked-in: \(totalUsersCheckedIn())")
    }
    
    /// Returns count of `users`
    ///
    /// Returns: Count of `users`
    func totalUsersCheckedIn() -> Int {
        return users.count
    }
}
