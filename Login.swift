//
//  Login.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 15/10/21.
//

import Foundation

class Login {
    private let windowName: String
    private var commands: Array<(String, () -> Void)> = []
    init(windowName: String) {
        self.windowName = windowName
    }
    
    func createWindow() throws {
    mainLoop:
        while true {
            try Printer.printWindowTitle(windowName)
            Printer.printOption(optionNumber: 0, optionName: "Exit")
            printCommands()
            Printer.get(element: "option number")
            let input = Int(InputHandler.getIntegerInput())
            switch input {
            case 0:
                break mainLoop
            case 1...commands.count:
                commands[input - 1].1()
            default:
                print("Invalid input!")
            }
        }
    }
    
    private func printCommands() {
        for (number, (name, _)) in commands.enumerated() {
            Printer.printOption(optionNumber: number + 1, optionName: name)
        }
    }
    
    func addCommand(name: String, _ command: @escaping () -> Void) {
        self.commands.append((name, command))
    }
}
