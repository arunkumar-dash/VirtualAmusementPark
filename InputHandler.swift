//
//  InputHandler.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 12/10/21.
//

import Foundation
struct InputHandler {
    /// Returns `String` input read from user.
    ///
    /// - Parameter string: String displayed before reading input.
    /// - Returns: String value read from input.
    static func getInput(_ string: String = "") -> String {
        var input: String?
        while input == nil {
            Printer.get(element: string)
            input = readLine()
        }
        return input!
    }
    /// Returns `UInt` input read from user.
    ///
    /// - Parameter string: String displayed before reading input.
    /// - Returns: UInt value read from input.
    static func getIntegerInput(_ string: String = "") -> UInt {
        var input: String?
        while input == nil || UInt(input!) == nil {
            Printer.get(element: string)
            input = readLine()
        }
        return UInt(input!)!
    }
    /// Returns `Float` input read from user.
    ///
    /// - Parameter string: String displayed before reading input.
    /// - Returns: Float value read from input.
    static func getFloatInput(_ string: String = "") -> Float {
        var input: String?
        while input == nil || Float(input!) == nil {
            Printer.get(element: string)
            input = readLine()
        }
        return Float(input!)!
    }
    /// Returns `Time` input read from user.
    ///
    /// - Parameter string: String displayed before reading input.
    /// - Returns: Time instance read from input.
    static func getTimeInput(_ string: String = "") -> Time {
        while true {
            Printer.get(element: string)
            let input = readLine()
            do {
                guard input != nil else {
                    Printer.printError("Invalid input")
                    continue
                }
                guard input!.contains(":") else {
                    Printer.printError("Invalid input")
                    continue
                }
                let splitInput = input!.split(separator: ":")
                guard splitInput.count == 2 && UInt8(splitInput[0]) != nil && UInt8(splitInput[1]) != nil else {
                    Printer.printError("Invalid input")
                    continue
                }
                let hours = UInt8(splitInput[0])!
                let minutes = UInt8(splitInput[1])!
                return try Time(hours: hours, minutes: minutes)
            } catch Time.Error.invalidHour {
                Printer.printError("Invalid hour entered")
            } catch Time.Error.invalidMinute {
                Printer.printError("Invalid minute entered")
            } catch {
                Printer.printError("Unexpected input entered")
            }
        }
    }
    /// Returns `Timing` input read from user.
    ///
    /// - Parameter string: String displayed before reading input.
    /// - Returns: Timing instance read from input.
    static func getTimingInput(_ string: String = "") -> Timing<Time> {
        while true {
            do {
                Printer.get(element: string)
                let openingTime = getTimeInput("opening time in HH:MM format")
                let closingTime = getTimeInput("closing time in HH:MM format")
                return try Timing(opening: openingTime, closing: closingTime)
            } catch Timing<Time>.Error.invalidTiming {
                Printer.printError("Invalid timing")
            } catch {
                Printer.printError("Unexpected error occured")
            }
        }
    }
}
