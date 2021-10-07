//
//  Controller.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 01/10/21.
//

import Foundation
/// Returns a controller object to handle the execution of the amusement park.
struct Controller {
    /// `Reception` object for performing operations in the park.
    var reception = Reception()
    /// Returns `String` input read from user.
    ///
    /// Parameter string: String displayed before reading input.
    /// Returns: String value read from input.
    private func getInput(_ string: String = "") -> String {
        var input: String?
        while input == nil {
            print(string)
            input = readLine()
        }
        return input!
    }
    /// Returns `UInt` input read from user.
    ///
    /// Parameter string: String displayed before reading input.
    /// Returns: UInt value read from input.
    private func getIntegerInput(_ string: String = "") -> UInt {
        var input: String?
        while input == nil || UInt(input!) == nil {
            print(string)
            input = readLine()
        }
        return UInt(input!)!
    }
    /// Returns `Float` input read from user.
    ///
    /// Parameter string: String displayed before reading input.
    /// Returns: Float value read from input.
    private func getFloatInput(_ string: String = "") -> Float {
        var input: String?
        while input == nil || Float(input!) == nil {
            print(string)
            input = readLine()
        }
        return Float(input!)!
    }
    /// Returns `Time` input read from user.
    ///
    /// Parameter string: String displayed before reading input.
    /// Returns: Time instance read from input.
    private func getTimeInput(_ string: String = "") -> Time {
        while true {
            print(string)
            let input = readLine()
            do {
                guard input != nil else {
                    print("Invalid input!")
                    continue
                }
                guard input!.contains(":") else {
                    print("Invalid input!")
                    continue
                }
                let splitInput = input!.split(separator: ":")
                guard splitInput.count == 2 && UInt8(splitInput[0]) != nil && UInt8(splitInput[0]) != nil else {
                    print("Invalid input!")
                    continue
                }
                let hours = UInt8(splitInput[0])!
                let minutes = UInt8(splitInput[1])!
                return try Time(hours: hours, minutes: minutes)
            } catch Time.Error.invalidHour {
                print("Invalid hour entered!")
            } catch Time.Error.invalidMinute {
                print("Invalid minute entered!")
            } catch {
                print("Unexpected input entered!")
            }
        }
    }
    /// Returns `Timing` input read from user.
    ///
    /// Parameter string: String displayed before reading input.
    /// Returns: Timing instance read from input.
    private func getTimingInput(_ string: String = "") -> Timing {
        while true {
            do {
                print(string)
                let openingTime = getTimeInput("Enter opening time in HH:MM format: ")
                let closingTime = getTimeInput("Enter closing time in HH:MM format: ")
                return try Timing(opening: openingTime, closing: closingTime)
            } catch Timing.Error.invalidTiming {
                print("Invalid timing!")
            } catch {
                print("Unexpected error occured!")
            }
        }
    }
    /// Creates a background timer and directs user towards the operations present.
    mutating func start() {
        ///Increments one minute per second in `currentTime`
        DispatchQueue.global().async {
            while true {
                sleep(1)
                Reception.currentTime.add(minutes: 1)
            }
        }
        mainLoop:
        while true {
            print("----- Main Window -----")
            print("[1] Create ride")
            print("[2] Check-in")
            print("[3] Check-out")
            print("[4] Add maintenance details")
            print("[5] Create refreshment")
            print("[6] Enter as User")
            print("[7] Check time")
            print("[8] Show checked-in users")
            print("[9] Show checked-out users")
            print("[10] Quit")
            let input = getIntegerInput()
            switch input {
            case 1:
                createRide()
            case 2:
                reception.checkIn()
            case 3:
                reception.checkOut()
            case 4:
                addMaintenance()
            case 5:
                createRefreshment()
            case 6:
                reception.userController()
            case 7:
                print("Current time: \(Reception.currentTime.description)")
            case 8:
                reception.showCheckedInUsers()
            case 9:
                reception.showCheckedOutUsers()
            case 10:
                break mainLoop
            default:
                print("Invalid choice!")
            }
        }
    }
    /// Creates a `Ride` object and appends it to `rides` array in `Reception`
    func createRide() {
        let name = getInput("Enter name: ")
        let cost = getFloatInput("Enter cost: ")
        let duration = getTimeInput("Enter duration in HH:MM format: ")
        let timing = getTimingInput("Enter timing details: ")
        let age = getIntegerInput("Enter minimum age category(<17 for children, >=18 for adults): ")
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
        let minCapacity = getIntegerInput("Enter minimum capacity required to start ride: ")
        let maxCapacity = getIntegerInput("Enter maximum capacity: ")
        Reception.rides.append(
            Ride(
                name: name, cost: cost, duration: duration, timing: timing, ageGroup: ageGroup,
                minimumCapacity: minCapacity, maximumCapacity: maxCapacity
            )
        )
        print("Ride \(name) created!")
    }
    /// Adds maintenance details for a specific `Ride` object
    func addMaintenance() {
        guard reception.showAvailableRidesForMaintenance() else {
            return
        }
        let rideNumber = Int(getIntegerInput("Enter ride number: "))
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
                let maintenanceIdx = getIntegerInput()
                guard maintenanceIdx > 0 && maintenanceIdx <= Maintenance.allCases.count else {
                    print("Invalid number!")
                    return
                }
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    if index + 1 == maintenanceIdx {
                        var maintenanceDuration = getTimeInput("Enter maintenance duration: ")
                        print("Ride \(currentRide.name) is under maintenance for \(maintenanceDuration.hours) hours and \(maintenanceDuration.minutes) minutes due to \(maintenanceType)!")
                        Reception.rides[rideNumber - 1].maintenanceDetails = maintenanceType
                        do {
                            let defaultTime = try Time(hours: 0, minutes: 0)
                            ///Maintenance work goes in background
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
        let name = getInput("Enter name: ")
        let cost = getFloatInput("Enter cost: ")
        Reception.refreshments.append(Refreshment(name: name, cost: cost))
    }
}
