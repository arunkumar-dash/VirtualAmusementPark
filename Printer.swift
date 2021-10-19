//
//  Printer.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 15/10/21.
//

import Foundation

/// Returns the error caused in `Printer`
enum PrinterError: Error {
    case windowTitleOverFlow
}

/// Returns a `Printer` object used to print contents in specific format
struct Printer {
    
    /// Prints a window title with the `windowName` surrounded by `filler`
    ///
    /// - Parameters:
    ///   - title: The title of the window
    ///   - windowLength: The total allowed size of the window
    ///   - filler: The string to be filled arounf the title
    /// - Throws:
    ///   - `PrinterError.windowTitleOverFlow` when the length of `windowName` is greater than `windowLength`
    static func printWindowTitle(_ title: String, windowLength: Int = 50, filler: String = ".") throws {
        let length = title.count
        if length > windowLength {
            throw PrinterError.windowTitleOverFlow
        }
        let dashesCount = windowLength - length
        let titleFiller = String(repeating: filler, count: dashesCount/2)
        print(titleFiller, title, titleFiller)
        print("Current time: \(Controller.getCurrentTime().description)")
    }
    
    /// Prints a statement to indicating the user to enter the input
    ///
    /// - Parameter input: The description of the input
    static func get(element input: String) {
        if input == "" {
            return
        }
        print("Enter \(input):", terminator: " ")
    }
    
    /// Prints the option in a specific format with the option number
    ///
    ///
    /// - Parameters:
    ///   - number: The option number
    ///   - name: The description of the option
    static func printOption(optionNumber number: Int, optionName name: String) {
        print("[\(number)] \(name)")
    }
    
    /// Prints the error and its description in a specific format
    ///
    /// - Parameters:
    ///   - message: The error message
    ///   - error: The `Error` object
    static func printError(_ message: String, error: Error? = nil) {
        print("😕\(message)!", terminator: "")
        print(error ?? "")
    }
    
    /// Prints the success message in a specific format
    ///
    /// - Parameter message: The success message
    static func printSuccess(_ message: String) {
        print("🥳\(message)!")
    }
}
