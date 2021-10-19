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
    
    /// Adds `User` objects into `checkedInUsers` set
    ///
    /// - Returns: A `User` object which checked in
    @discardableResult
    mutating func checkIn() -> User?{
        var user: User?
        return DispatchQueue.global(qos: .userInteractive).sync {
            let userName: String
            let userAge: UInt8
            var mobile: String
            userName = InputHandler.getInput("user name")
            userAge = UInt8(InputHandler.getIntegerInput("user age"))
            mobile = InputHandler.getInput("user mobile(without spaces)")
            /// Error handling mobile number
            while true {
                do {
                    user = try User(name: userName, age: userAge, mobile: mobile)
                    if Controller.getCheckedInUsers().contains(user!) {
                        throw User.Error.userAlreadyExists
                    }
                    user!.checkIn()
                    Controller.addNewUser(user!)
                    break
                } catch User.Error.invalidMobileFormat {
                    mobile = InputHandler.getInput("a 10-digit mobile number")
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
                let index = InputHandler.getIntegerInput("ride number")
                if index <= Controller.getRides().count && index > 0 {
                    let currentRide = Controller.getRide(index: Int(index) - 1)
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
                print("Do you want to add another ride?")
                let response = InputHandler.getInput("('y'/'n')")
                if response.lowercased() != "y" {
                    flag = false
                }
            } while flag
            return user
        }
    }
    
    /// Removes `User` object from `checkedInUsers` and adds to `checkedOutUsers`.
    mutating func checkOut() {
        DispatchQueue.global().sync {
            let name = InputHandler.getInput("name")
            let mobile = InputHandler.getInput("mobile")
            var tempUser: User?
            do {
                tempUser = try User(name: name, age: 1, mobile: mobile)
                if tempUser != nil {
                    if let oldUser = Controller.removeUser(user: tempUser!) {
                        oldUser.printReceipt()
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
}
