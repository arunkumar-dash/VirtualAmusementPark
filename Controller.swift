//
//  Controller.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 01/10/21.
//

import Foundation
/// Returns a controller object to handle the execution of the amusement park.
class Controller {
    /// `Reception` object for performing operations in the park.
    private var reception = Reception()
    private var user: User?
    
    func start() {
        reception.startTimer()
        let mainLogin = Login(windowName: "Main Window")
        mainLogin.addCommand(name: "Admin Login", adminLogin)
        mainLogin.addCommand(name: "User Login", userLogin)
        do {
            try mainLogin.createWindow()
        } catch let error {
            print("Error initiating window:",error)
            return
        }
    }
    
    func adminLogin() {
        let adminLogin = Login(windowName: "Admin Login Window")
        adminLogin.addCommand(name: "Create ride", createRide)
        adminLogin.addCommand(name: "Create refreshment", createRefreshment)
        adminLogin.addCommand(name: "Add maintenance details", addMaintenance)
        adminLogin.addCommand(name: "Check time", printCurrentTime)
        adminLogin.addCommand(name: "Show checked-in users", showCheckedInUsers)
        adminLogin.addCommand(name: "Show checked-out users", showCheckedOutUsers)
        do {
            try adminLogin.createWindow()
        } catch let error {
            print("Error initiating window:",error)
            return
        }
    }
    
    /// Allows users to login
    func userLogin() {
        user = userAuth()
        if user != nil {
            print("Login success!")
        } else {
            print("Login failed!")
            return
        }
        
        /// Access options for user
        let userLogin = Login(windowName: "User Login Window")
        userLogin.addCommand(name: "Visit Ride", visitRide)
        userLogin.addCommand(name: "Buy refreshments", buyRefreshments)
        userLogin.addCommand(name: "Check-out", checkOut)
        do {
            try userLogin.createWindow()
        } catch let error {
            print("Error initiating window:", error)
            return
        }
    }
    
    private func checkOut() {
        if user!.checkOut() == false {
            print("Checked out already!")
            return
        }
        reception.users.remove(user!)
        reception.usersLog.append(user!)
        print("Check-out success!")
        user!.showReceipt()
    }
    
    private func visitRide() {
        var ridesCount = 0
        for ride in user!.rides {
            if ride.value == false {
                ridesCount += 1
                print(ride.key.description)
            }
        }
        if ridesCount == 0 {
            print("All rides visited!")
            return
        }
        let rideName = InputHandler.getInput("Enter ride name: ")
        var isValid = true
        for ride in user!.rides {
            if ride.key.name == rideName {
                DispatchQueue.global().async {
                    do {
                        try self.user!.visitRide(ride: ride.key)
                    } catch let error {
                        print(error)
                    }
                }
                isValid = false
                return
            }
        }
        if isValid {
            print("Ride not available!")
        }
    }
    
    private func buyRefreshments() {
        if Reception.refreshments.isEmpty {
            print("No refreshments available!")
            return
        }
        for (idx, refreshment) in Reception.refreshments.enumerated() {
            print("[\(idx + 1)]\t\t\(refreshment.name)")
        }
        let idx = InputHandler.getInput("Enter refreshment number: ")
        if Int(idx) != nil && Int(idx)! <= Reception.refreshments.count && Int(idx)! > 0{
            user!.refreshments.append(Reception.refreshments[Int(idx)! - 1])
        }  else {
            print("Invalid choice!")
        }
    }
    
    private func userAuth() -> User? {
        print("Attempting to login...")
        let name = InputHandler.getInput("Enter name: ")
        let mobile = InputHandler.getInput("Enter mobile: ")
        var tempUser: User?
        do {
            /// Creating temporary `User` instance to access in O(1) time
            tempUser = try User(name: name, age: 1, mobile: mobile)
            if tempUser != nil {
                if let idx = reception.users.firstIndex(of: tempUser!) {
                    return reception.users[idx]
                } else {
                    print("Cannot find user. Check-In instead!")
                    return reception.checkIn()
                }
            } else {
                print("Inputs invalid!")
                return nil
            }
        } catch let error {
            print(error)
            return nil
        }
    }
    
    /// Creates a `Ride` object and appends it to `rides` array in `Reception`
    func createRide() {
        let name = InputHandler.getInput("Enter ride name: ")
        let duration = InputHandler.getTimeInput("Enter ride duration in HH:MM format: ")
        let timing = InputHandler.getTimingInput("Enter ride timing details: ")
        let age = InputHandler.getIntegerInput("Enter minimum age category(<17 for children, >=18 for adults): ")
        var ageGroup: AgeGroup {
            switch age {
            case ...17:
                return .child
            case 18...:
                return .adult
            default:
                return .adult
            }
        }
        let minCapacity = InputHandler.getIntegerInput("Enter minimum capacity required to start ride: ")
        let maxCapacity = InputHandler.getIntegerInput("Enter maximum capacity: ")
        Reception.rides.append(
            RideSelector.getRideBasedOnType(name: name, duration: duration, timing: timing, ageGroup: ageGroup, minimumCapacity: minCapacity, maximumCapacity: maxCapacity)
        )
        print("Ride \(name) created!")
    }
    /// Adds maintenance details for a specific `Ride` object
    func addMaintenance() {
        guard reception.showAvailableRidesForMaintenance() else {
            return
        }
        let rideNumber = Int(InputHandler.getIntegerInput("Enter ride number: "))
        if rideNumber <= Reception.rides.count && rideNumber > 0 {
            let currentRide = Reception.rides[rideNumber - 1]
            /// Checks if the ride is currently under maintenance
            if currentRide.isUnderMaintenance() {
                print("Ride is already under maintenance!")
            } else {
                print("Select maintenance number: ")
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    print("[\(index + 1)]\t\t\(maintenanceType)")
                }
                let maintenanceIdx = InputHandler.getIntegerInput()
                guard maintenanceIdx > 0 && maintenanceIdx <= Maintenance.allCases.count else {
                    print("Invalid number!")
                    return
                }
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    if index + 1 == maintenanceIdx {
                        var maintenanceDuration = InputHandler.getTimeInput("Enter maintenance duration: ")
                        print("Ride \(currentRide.name) is under maintenance for \(maintenanceDuration.hours) hours and \(maintenanceDuration.minutes) minutes due to \(maintenanceType)!")
                        Reception.rides[rideNumber - 1].maintenanceDetails = maintenanceType
                        do {
                            let defaultTime = try Time(hours: 0, minutes: 0)
                            /// Maintenance work goes in background
                            DispatchQueue(label: "Maintenance").async {
                                while maintenanceDuration > defaultTime {
                                    sleep(1)
                                    maintenanceDuration -= 1
                                }
                                Reception.rides[rideNumber - 1].maintenanceDetails = nil
                                dump("Maintenance work for ride \(currentRide.name) is over!")
                            }
                        } catch {
                            print("Time error")
                        }
                        break
                    }
                }
            }
        } else {
            print("Invalid ride number!")
        }
    }
    /// Creates a `Refreshment` object and appends to `refreshments` array
    func createRefreshment() {
        print("Enter refreshment details: ")
        let name = InputHandler.getInput("Enter name: ")
        let cost = InputHandler.getFloatInput("Enter cost: ")
        Reception.refreshments.append(Refreshment(name: name, cost: cost))
    }
    
    func showCheckedInUsers() {
        reception.showCheckedInUsers()
    }
    
    func showCheckedOutUsers() {
        reception.showCheckedOutUsers()
    }
    
    func printCurrentTime() {
        print("Current time: \(Reception.currentTime.description)")
    }
}
