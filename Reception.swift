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
                    if Controller.users.contains(user!) {
                        throw User.Error.userAlreadyExists
                    }
                    user!.checkIn()
                    Controller.users.insert(user!)
                    break
                } catch User.Error.invalidMobileFormat {
                    mobile = InputHandler.getInput("Enter a 10-digit mobile number: ")
                } catch let error {
                    Printer.printError("User check-in was unsuccessful", error: error)
                    return nil
                }
            }
            /// Display available rides
            guard Controller.showAvailableRides() else {
                return user
            }
            var flag = true
            repeat {
                let index = InputHandler.getIntegerInput("Enter ride number: ")
                if index <= Controller.rides.count && index > 0 {
                    let currentRide = Controller.rides[Int(index) - 1]
                    if currentRide.isUnderMaintenance() {
                        Printer.printError("Ride not available")
                    } else if user != nil {
                        do {
                            if try user!.add(ride: currentRide) {
                                Printer.printSuccess("Ride added successfully!")
                            }
                        } catch let error {
                            Printer.printError("Error", error: error)
                        }
                    } else {
                        Printer.printError("User doesn't exist")
                    }
                } else {
                    Printer.printError("Invalid ride number")
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
                    if let oldUser = Controller.users.remove(tempUser!) {
                        oldUser.showReceipt()
                        Controller.usersLog.append(oldUser)
                    } else {
                        Printer.printError("User doesn't exist")
                    }
                } else {
                    Printer.printError("Invalid details")
                }
            } catch let error {
                Printer.printError("Error", error: error)
            }
        }
    }
    
    /// Prints `usersLog`.
    func showCheckedOutUsers() {
        if Controller.usersLog.isEmpty {
            Printer.printError("No users found")
            return
        }
        for oldUser in Controller.usersLog {
            print("Name: \(oldUser.name)\t\tAge: \(oldUser.age)\t\tMobile: \(oldUser.mobile)")
        }
    }
    
    /// Prints `users`.
    func showCheckedInUsers() {
        if Controller.users.isEmpty {
            Printer.printError("No users found")
            return
        }
        for user in Controller.users {
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
        return Controller.users.count
    }
}
