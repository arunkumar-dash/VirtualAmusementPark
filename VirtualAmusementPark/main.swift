//
//  main.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 28/09/21.
//


import Foundation

var controller = Controller()
controller.start()

/*
class Test<U: UserProtocol> {
    func a1() {
        var a: U?
        var b: Ride<Time, U>?
        do{
            var a = try User<Time, U> (name: "A", age: 2, mobile: "1111111111")
            var b = Ride<Time, U>(name: "aa", cost: 12, duration: try Time(hours: 1, minutes: 1), timing: try Timing(opening: try Time(hours: 1, minutes: 1), closing: try Time(hours: 23, minutes: 21)), ageGroup: .adult, minimumCapacity: 1)
            if b != nil {
                try a.visit(ride: b as! Ride<U.T, U.U>)
            }
        } catch {
            print("Err")
        }
    }
}
*/
