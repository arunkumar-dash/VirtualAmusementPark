//
//  Printer.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 15/10/21.
//

import Foundation


enum PrinterError: Error {
    case windowTitleOverFlow
}

struct Printer {
    
    static func printWindowTitle(_ title: String, windowLength: Int = 50, filler: String = ".") throws {
        let length = title.count
        if length > windowLength || length < 0 {
            throw PrinterError.windowTitleOverFlow
        }
        let dashesCount = windowLength - length
        let titleFiller = String(repeating: "-", count: dashesCount/2)
        print(titleFiller, title, titleFiller)
    }
    
    static func get(element input: String) {
        print("Enter \(input):", terminator: " ")
    }
    
    static func printOption(optionNumber number: Int, optionName name: String) {
        print("[\(number)] \(name)")
    }
}
