//
//  Controller.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 01/10/21.
//

import Foundation
/// Returns a controller object to handle the execution of the amusement park.
class Controller {
    /// A set consisting of `User` instances.
    static var users: Set<User> = []
    /// An array consisting of `User`s checked-out.
    static var usersLog: Array<User> = []
    /// A static array consisting of rides in the park.
    static var rides: Array<Ride> = []
    /// Static variable which stores the time since start of execution.
    private static var currentTime: Time {
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
    private static var currentHour: UInt8 = 0
    /// Static variable which utility for `currentTime`.
    private static var currentMinute: UInt8 = 0
    /// A static array consisting of refreshments in the park.
    private static var refreshments: Array<Refreshment> = []
    /// Starts the currentTime to run asynchronously.
    private func startTimer() {
        ///Increments one minute per second in `currentTime`
        DispatchQueue.global().async {
            while true {
                sleep(1)
                Controller.currentTime.add(minutes: 1)
            }
        }
    }
    
    /// Prints the available rides and returns false if no rides available, else true.
    ///
    /// Returns: Boolean value based on the available rides count.
    @discardableResult
    static func showAvailableRides() -> Bool {
        print("Available rides: ")
        var availableRidesCount = 0
        for (count, ride) in Controller.rides.enumerated() {
            if ride.isUnderMaintenance() == false && ride.currentlyRunning == false {
                print("[\(count + 1)]\t\(ride.description)")
                availableRidesCount += 1
            }
        }
        guard availableRidesCount > 0 else {
            Printer.printError("No rides available")
            return false
        }
        return true
    }
    
    /// Prints the available rides even if it is currently running and returns false if no rides available, else true.
    ///
    /// Returns: Boolean value based on the available rides count.
    @discardableResult
    private static func showAvailableRidesForMaintenance() -> Bool {
        print("Available rides: ")
        var availableRidesCount = 0
        for (count, ride) in Controller.rides.enumerated() {
            if ride.isUnderMaintenance() == false {
                print("[\(count + 1)]\t\(ride.description)")
                availableRidesCount += 1
            }
        }
        guard availableRidesCount > 0 else {
            Printer.printError("No rides available")
            return false
        }
        return true
    }
    /// `Reception` object for performing operations in the park.
    private var reception = Reception()
    private var user: User?
    
    func start() {
        startTimer()
        let mainLogin = Login(windowName: "Main Window")
        mainLogin.addCommand(name: "Admin Login", adminLogin)
        mainLogin.addCommand(name: "User Login", userLogin)
        do {
            try mainLogin.createWindow()
        } catch let error {
            Printer.printError("Error initiating window:", error: error)
            return
        }
    }
    
    private func adminLogin() {
        let adminLogin = Login(windowName: "Admin Login Window")
        adminLogin.addCommand(name: "Create ride", createRide)
        adminLogin.addCommand(name: "Create refreshment", createRefreshment)
        adminLogin.addCommand(name: "Add maintenance details", addMaintenance)
        adminLogin.addCommand(name: "Check time", printCurrentTime)
        adminLogin.addCommand(name: "Show checked-in users", showCheckedInUsers)
        adminLogin.addCommand(name: "Show checked-out users", showCheckedOutUsers)
        adminLogin.addCommand(name: "Adjust current time", adjustCurrentTime)
        do {
            try adminLogin.createWindow()
        } catch let error {
            Printer.printError("Error initiating window:", error: error)
            return
        }
    }
    
    /// Allows users to login
    private func userLogin() {
        user = userAuth()
        if user != nil {
            Printer.printSuccess("Login success")
        } else {
            Printer.printError("Login failed")
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
            Printer.printError("Error initiating window:", error: error)
            return
        }
    }
    
    private func checkOut() {
        if user!.checkOut() == false {
            Printer.printError("Checked out already")
            return
        }
        Controller.users.remove(user!)
        Controller.usersLog.append(user!)
        Printer.printSuccess("Check-out success")
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
            Printer.printError("All rides visited")
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
            Printer.printError("Ride not available")
        }
    }
    
    private func buyRefreshments() {
        if Controller.refreshments.isEmpty {
            Printer.printError("No refreshments available")
            return
        }
        for (idx, refreshment) in Controller.refreshments.enumerated() {
            print("[\(idx + 1)]\t\t\(refreshment.name)")
        }
        let idx = InputHandler.getInput("Enter refreshment number: ")
        if Int(idx) != nil && Int(idx)! <= Controller.refreshments.count && Int(idx)! > 0{
            user!.refreshments.append(Controller.refreshments[Int(idx)! - 1])
            Printer.printSuccess("Refreshment added")
        }  else {
            Printer.printError("Invalid choice")
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
                if let idx = Controller.users.firstIndex(of: tempUser!) {
                    return Controller.users[idx]
                } else {
                    print("Cannot find user. Check-In instead!")
                    return reception.checkIn()
                }
            } else {
                Printer.printError("Inputs invalid")
                return nil
            }
        } catch let error {
            Printer.printError("Error", error: error)
            return nil
        }
    }
    
    /// Creates a `Ride` object and appends it to `rides` array in `Reception`
    private func createRide() {
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
        Controller.rides.append(
            RideSelector.getRideBasedOnType(name: name, duration: duration, timing: timing, ageGroup: ageGroup, minimumCapacity: minCapacity, maximumCapacity: maxCapacity)
        )
        Printer.printSuccess("Ride \(name) created")
    }
    /// Adds maintenance details for a specific `Ride` object
    private func addMaintenance() {
        guard Controller.showAvailableRidesForMaintenance() else {
            return
        }
        let rideNumber = Int(InputHandler.getIntegerInput("Enter ride number: "))
        if rideNumber <= Controller.rides.count && rideNumber > 0 {
            let currentRide = Controller.rides[rideNumber - 1]
            /// Checks if the ride is currently under maintenance
            if currentRide.isUnderMaintenance() {
                Printer.printError("Ride is already under maintenance")
            } else {
                print("Select maintenance number: ")
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    print("[\(index + 1)]\t\t\(maintenanceType)")
                }
                let maintenanceIdx = InputHandler.getIntegerInput()
                guard maintenanceIdx > 0 && maintenanceIdx <= Maintenance.allCases.count else {
                    Printer.printError("Invalid number")
                    return
                }
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    if index + 1 == maintenanceIdx {
                        var maintenanceDuration = InputHandler.getTimeInput("Enter maintenance duration: ")
                        Controller.rides[rideNumber - 1].add(maintenance: maintenanceType)
                        print("Ride \(currentRide.name) is under maintenance for \(maintenanceDuration.hours) hours and \(maintenanceDuration.minutes) minutes due to \(maintenanceType)!")
                        do {
                            let defaultTime = try Time(hours: 0, minutes: 0)
                            /// Maintenance work goes in background
                            DispatchQueue(label: "Maintenance").async {
                                while maintenanceDuration > defaultTime {
                                    sleep(1)
                                    maintenanceDuration -= 1
                                }
                                Controller.rides[rideNumber - 1].removeMaintenance()
                                dump("Maintenance work for ride \(currentRide.name) is over!")
                            }
                        } catch {
                            Printer.printError("Time error")
                        }
                        break
                    }
                }
            }
        } else {
            Printer.printError("Invalid ride number")
        }
    }
    /// Creates a `Refreshment` object and appends to `refreshments` array
    private func createRefreshment() {
        print("Enter refreshment details: ")
        let name = InputHandler.getInput("Enter name: ")
        let cost = InputHandler.getFloatInput("Enter cost: ")
        Controller.refreshments.append(Refreshment(name: name, cost: cost))
    }
    
    private func showCheckedInUsers() {
        reception.showCheckedInUsers()
    }
    
    private func showCheckedOutUsers() {
        reception.showCheckedOutUsers()
    }
    
    static func getCurrentTime() -> Time {
        return Controller.currentTime
    }
    
    private static func setCurrentTime(time: Time) {
        Controller.currentTime = time
    }
    
    private func printCurrentTime() {
        print("Current time: \(Controller.getCurrentTime())")
    }
    
    private func adjustCurrentTime() {
        let newTime = InputHandler.getTimeInput()
        Controller.setCurrentTime(time: newTime)
    }
}
