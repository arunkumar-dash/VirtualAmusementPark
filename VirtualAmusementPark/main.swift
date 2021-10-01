//
//  main.swift
//  VirtualAmusementPark
//
//  Created by Arun Kumar on 28/09/21.
//


import Foundation

/*
do {
    var setTest: Set<User> = [try User(name: "arun", age: 12, mobile: "9840372719"), try User(name: "kumar", age: 34, mobile: "2323234334"), try User(name: "dinesh", age: 21, mobile: "0993893234")]
    print(setTest)
    print(setTest.contains(try User(name: "arun", age: 45, mobile: "9840372719")))
    print(setTest.contains(try User(name: "arun", age: 12, mobile: "9840372719")))
    let val1 = try User(name: "arun", age: 29, mobile: "9840372719").hashValue
    let val2 = try User(name: "arun", age: 34, mobile: "9840372719").hashValue
    print(val1 == val2)
    setTest.insert(try User(name: "arun", age: 34, mobile: "9840372719"))
    for i in setTest {
        print(i.hashValue)
    }
} catch let error{
    print(error)
}

*/
var controller = Controller()
controller.start()

