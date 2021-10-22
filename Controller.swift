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
    private static var checkedInUsers: Set<User<Time, User>> = []
    /// An array consisting of `User`s checked-out.
    private static var checkedOutUsers: Array<User<Time>> = []
    /// A static array consisting of rides in the park.
    private static var rides: Array<Ride<Time, User<Time>>> = []
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
    /// - Returns: Boolean value based on the available rides count.
    @discardableResult
    static func showAvailableRides() -> Bool {
        print("Available rides: ")
        var availableRidesCount = 0
        for (index, ride) in Controller.rides.enumerated() {
            if ride.isUnderMaintenance() == false && ride.currentlyRunning == false {
                Printer.printOption(optionNumber: index + 1, optionName: ride.description)
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
    /// - Returns: Boolean value based on the available rides count.
    @discardableResult
    private static func showAvailableRidesForMaintenance() -> Bool {
        print("Available rides: ")
        var availableRidesCount = 0
        for (index, ride) in Controller.rides.enumerated() {
            if ride.isUnderMaintenance() == false {
                Printer.printOption(optionNumber: index + 1, optionName: ride.description)
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
    private var reception = Reception<User<Time, User>>()
    /// Stores a `User` object
    private var user: User<Time, User, User1>?
    /// Starts the functionality of the `Controller`
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
    /// Allows admin to login
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
        user = authenticateUser()
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
    
    /// Checks out `user`
    private func checkOut() {
        if user!.checkOut() == false {
            Printer.printError("Checked out already")
            return
        }
        Controller.checkedInUsers.remove(user!)
        Controller.checkedOutUsers.append(user!)
        Printer.printSuccess("Check-out success")
        user!.printReceipt()
    }
    
    /// Marks a ride as visited for `user`
    private func visitRide() {
        var ridesCount = 0
        for ride in user!.getRidesVisitedPair() {
            if ride.value == false {
                ridesCount += 1
                print(ride.key.description)
            }
        }
        if ridesCount == 0 {
            Printer.printError("All rides visited")
            return
        }
        let rideName = InputHandler.getInput("ride name")
        var isValid = true
        for ride in user!.getRidesVisitedPair() {
            if ride.key.name == rideName {
                DispatchQueue.global().async {
                    do {
                        try self.user!.visit(ride: ride.key)
                    } catch let error {
                        Printer.printError("Error", error: error)
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
    
    /// Adds `Refreshment` instance to `User`'s `refreshments` collection
    private func buyRefreshments() {
        if Controller.refreshments.isEmpty {
            Printer.printError("No refreshments available")
            return
        }
        for (index, refreshment) in Controller.refreshments.enumerated() {
            Printer.printOption(optionNumber: index + 1, optionName: refreshment.name)
        }
        let index = InputHandler.getInput("refreshment number")
        if Int(index) != nil && Int(index)! <= Controller.refreshments.count && Int(index)! > 0{
            user!.appendRefreshment(Controller.refreshments[Int(index)! - 1])
            Printer.printSuccess("Refreshment added")
        }  else {
            Printer.printError("Invalid choice")
        }
    }
    
    /// Returns a `User` instance based on the details from input
    ///
    /// - Returns: `User` instance from `checkedInUsers`
    private func authenticateUser() -> User<Time>? {
        print("Attempting to login...")
        let name = InputHandler.getInput("name")
        let mobile = InputHandler.getInput("mobile")
        var tempUser: User<Time>?
        do {
            /// Creating temporary `User` instance to access in O(1) time
            tempUser = try User<Time>(name: name, age: 1, mobile: mobile)
            if tempUser != nil {
                if let index = Controller.checkedInUsers.firstIndex(of: tempUser!) {
                    return Controller.checkedInUsers[index]
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
        let name = InputHandler.getInput("ride name")
        let duration = InputHandler.getTimeInput("ride duration in HH:MM format")
        let timing = InputHandler.getTimingInput()
        print("Select minimum age category:")
        Printer.printOption(optionNumber: 1, optionName: "Child")
        Printer.printOption(optionNumber: 2, optionName: "Adult")
        print("Default category: \(AgeGroup.adult)")
        let age = InputHandler.getIntegerInput("option number")
        var ageGroup: AgeGroup {
            switch age {
            case 1:
                return .child
            case 2:
                return .adult
            default:
                return .adult
            }
        }
        let minCapacity = InputHandler.getIntegerInput("minimum capacity required to start ride")
        Controller.rides.append(
            RideSelector.getRideBasedOnType(name: name, duration: duration, timing: timing, ageGroup: ageGroup, minimumCapacity: minCapacity)
        )
        Printer.printSuccess("Ride \(name) created")
    }
    
    /// Adds maintenance details for a specific `Ride` object
    private func addMaintenance() {
        guard Controller.showAvailableRidesForMaintenance() else {
            return
        }
        let rideNumber = Int(InputHandler.getIntegerInput("ride number"))
        if rideNumber <= Controller.rides.count && rideNumber > 0 {
            let currentRide = Controller.rides[rideNumber - 1]
            /// Checks if the ride is currently under maintenance
            if currentRide.isUnderMaintenance() {
                Printer.printError("Ride is already under maintenance")
            } else {
                Printer.get(element: "maintenance number")
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    Printer.printOption(optionNumber: index + 1, optionName: maintenanceType.rawValue)
                }
                let maintenanceIndex = InputHandler.getIntegerInput()
                guard maintenanceIndex > 0 && maintenanceIndex <= Maintenance.allCases.count else {
                    Printer.printError("Invalid number")
                    return
                }
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    if index + 1 == maintenanceIndex {
                        var maintenanceDuration = InputHandler.getTimeInput("maintenance duration")
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
        let name = InputHandler.getInput("refreshment name")
        let cost = InputHandler.getFloatInput("refreshment cost")
        Controller.refreshments.append(Refreshment(name: name, cost: cost))
        Printer.printSuccess("Refreshment created")
    }
    
    /// Returns value stored in `currentTime`
    ///
    /// - Returns: A `Time` instance stored in `currentTime`
    static func getCurrentTime() -> Time {
        return Controller.currentTime
    }
    
    /// Updates the `currentTime` variable with the `Time` object passed in argument
    ///
    ///  - Parameter time: `Time` object to be updated
    private static func setCurrentTime(time: Time) {
        Controller.currentTime = time
    }
    
    /// Prints `currentTime` to stdout
    private func printCurrentTime() {
        print("Current time: \(Controller.getCurrentTime())")
    }
    
    /// Updates `currentTime` with `Time`object collected from input
    private func adjustCurrentTime() {
        let newTime = InputHandler.getTimeInput()
        Controller.setCurrentTime(time: newTime)
    }
    
    /// Prints `checkedOutUsers`.
    private func showCheckedOutUsers() {
        if Controller.checkedOutUsers.isEmpty {
            Printer.printError("No users found")
            return
        }
        for oldUser in Controller.checkedOutUsers {
            print("Name: \(oldUser.name)\t\tAge: \(oldUser.age)\t\tMobile: \(oldUser.mobile)")
        }
    }
    
    /// Prints `checkedInUsers`.
    private func showCheckedInUsers() {
        if Controller.checkedInUsers.isEmpty {
            Printer.printError("No users found")
            return
        }
        for user in Controller.checkedInUsers {
            print("Name: \(user.name)\t\tAge: \(user.age)\t\tMobile: \(user.mobile)", terminator: " ")
            if user.isRiding() {
                print("Currently in \(user.getCurrentRide()!.name)")
            }
            print("")
        }
        print("Total user checked-in: \(totalUsersCheckedIn())")
    }
    
    /// Returns count of `checkedInUsers`
    ///
    /// - Returns: Count of `checkedInUsers`
    private func totalUsersCheckedIn() -> Int {
        return Controller.checkedInUsers.count
    }
    
    /// Returns `rides` variable
    ///
    /// - Returns: An Array object of `Ride` type
    static func getRides() -> Array<Ride<Time, User<Time>>> {
        return Controller.rides
    }
    
    /// - Returns a `Ride` object from the `rides` collection in the given index
    ///
    /// - Parameter index: The index of the `rides` Array
    /// - Returns: A `Ride` object at the given `index`
    static func getRide(index: Int) -> Ride<Time, User<Time>> {
        return Controller.rides[index]
    }
    
    /// Updates the `rides` collection with the given value at the given index
    ///
    /// - Parameters:
    ///   - index: The index of the `rides` array
    ///   - value: `Ride` object to be updated
    static func setRide(index: Int, value: Ride<Time, User<Time>>) {
        Controller.rides[index] = value
    }
    
    
    /// Adds a new `User` object to the `checkedInUsers` collection
    ///
    /// - Parameter user: The `User` object to be inserted
    static func addNewUser(_ user: User<Time>) {
        checkedInUsers.insert(user)
    }
    
    /// Removes and returns the `User` object from the `checkdeInUsers` collection and appends it to the `checkedOutUsers` collection
    ///
    /// - Parameter user: The `User` object to be removed
    /// - Returns: A `User` object which was removed
    static func removeUser(user: User<Time>) -> User<Time>? {
        let oldUser = checkedInUsers.remove(user)
        if oldUser != nil {
            checkedOutUsers.append(oldUser!)
        }
        return oldUser
    }
    
    /// Returns the value in `checkedInUsers` collection
    ///
    /// - Returns: A Set of `User` type stored in `checkedInUsers` collection
    static func getCheckedInUsers() -> Set<User<Time>> {
        return checkedInUsers
    }
}
