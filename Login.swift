//
//  Login.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 15/10/21.
//

import Foundation

/// Returns a Login object. A utility class consisting of static function
class Login {
    private let windowName: String
    private var commands: Array<(String, () -> Void)> = []
    init(windowName: String) {
        self.windowName = windowName
    }
    /// Prints the login window and `commands`
    ///
    /// - Throws:
    ///   - `PrinterError.windowTitleOverFlow` if the `windowName` exceeds windowSizeLimit
    func createWindow() throws {
    mainLoop:
        while true {
            // Printing the `windowName` in a title format
            try Printer.printWindowTitle(windowName)
            // Printing options in a option format
            Printer.printOption(optionNumber: 0, optionName: "Exit")
            // Printing the commands
            printCommands()
            let input = Int(InputHandler.getIntegerInput("option number"))
            switch input {
            case 0:
                break mainLoop
            case 1...commands.count:
                commands[input - 1].1()
            default:
                Printer.printError("Invalid input")
            }
        }
    }
    
    /// Prints the description of the commands
    private func printCommands() {
        for (number, (name, _)) in commands.enumerated() {
            Printer.printOption(optionNumber: number + 1, optionName: name)
        }
    }
    
    /// Appends the command with description to the `commands` collection
    ///
    /// - Parameters:
    ///   - name: Description of the command
    ///   - command: The function which needs to be stored
    func addCommand(name: String, _ command: @escaping () -> Void) {
        self.commands.append((name, command))
    }
}
