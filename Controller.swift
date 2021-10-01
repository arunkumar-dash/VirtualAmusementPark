//
//  Controller.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 01/10/21.
//

import Foundation

struct Controller {
    var reception = Reception()
    private func getInput(_ string: String = "") -> String {
        var input: String? = nil
        while input == nil {
            print(string)
            input = readLine()
        }
        return input!
    }

    private func getIntegerInput(_ string: String = "") -> UInt {
        var input: String? = nil
        while input == nil || UInt(input!) == nil {
            print(string)
            input = readLine()
        }
        return UInt(input!)!
    }

    private func getFloatInput(_ string: String = "") -> Float {
        var input: String? = nil
        while input == nil || Float(input!) == nil {
            print(string)
            input = readLine()
        }
        return Float(input!)!
    }

    private func getTimeInput(_ string: String = "") -> Time {
        while true {
            print(string)
            let input = readLine()
            let splitInput = input!.split(separator: ":")
            let hours = UInt8(splitInput[0])!
            let minutes = UInt8(splitInput[1])!
            do {
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
    
    mutating func start() {
        //async increment Reception.currentTime.minutes
        while true {
            print("[1] Check In")
            print("[2] Check Out")
            print("[3] Create ride")
            print("[4] Add maintenance details")
            print("[5] Create refreshment")
            let input = getIntegerInput()
            switch input {
            case 1:
                checkIn()
            case 2:
                checkOut()
            case 3:
                createRide()
            case 4:
                addMaintenance()
            case 5:
                createRefreshment()
            default:
                print("Invalid choice!")
            }
        }
    }
    
    mutating func checkIn() {
        reception.checkIn()
    }
    
    mutating func checkOut() {
        reception.checkOut()
    }

    func createRide() {
        let name = getInput("Enter name: ")
        let cost = getFloatInput("Enter cost: ")
        let duration = getTimeInput("Enter duration in HH:MM format: ")
        let timing = getTimingInput("Enter timing details: ")
        let age = getIntegerInput("Enter minimum age allowed(1 for children, 18 for adults): ")
        var ageGroup: AgeGroup {
            switch age {
            case 1:
                return .child
            case 18:
                return .adult
            default:
                print("Age other than 1 or 18 entered! Considering as Adult...")
                return .adult
            }
        }
        let minCapacity = getIntegerInput("Enter minimum capacity required to start ride: ")
        let maxCapacity = getIntegerInput("Enter maximum capacity: ")
        Reception.rides.append(Ride(name: name, cost: cost, duration: duration, timing: timing, ageGroup: ageGroup, minimumCapacity: minCapacity, maximumCapacity: maxCapacity))
    }
    
    func addMaintenance() {
        guard reception.showAvailableRides() else {
            return
        }
        let rideNumber = Int(getIntegerInput("Enter ride number: "))
        if rideNumber <= Reception.rides.count {
            let currentRide = Reception.rides[rideNumber - 1]
            if currentRide.isUnderMaintenance() {
                print("Ride is already under maintenance!")
            } else {
                print("Select maintenance type: ")
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    print("[\(index + 1)]\t\t\(maintenanceType)")
                }
                let maintenanceIdx = getIntegerInput()
                guard maintenanceIdx > 0 && maintenanceIdx <= Maintenance.allCases.count else {
                    return
                }
                for (index, maintenanceType) in Maintenance.allCases.enumerated() {
                    if index + 1 == maintenanceIdx {
                        Reception.rides[rideNumber - 1].maintenanceDetails = maintenanceType
                        var maintenanceDuration = getTimeInput("Enter maintenance duration: ")
                        //async code to wait until duration ends
                        maintenanceDuration -= 1
                        //
                        Reception.rides[rideNumber - 1].maintenanceDetails = nil
                        break
                    }
                }
            }
        } else {
            print("Invalid ride number!")
        }
    }
    
    func createRefreshment() {
        print("Enter refreshment details: ")
        let name = getInput("Enter name: ")
        let cost = getFloatInput("Enter cost: ")
        Reception.refreshments.append(Refreshment(name: name, cost: cost))
    }
}
