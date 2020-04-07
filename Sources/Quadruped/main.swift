//
//  main.swift
//  
//
//  Created by Michel Anderson Lutz Teixeira on 06/04/20.
//

#if os(Linux)

import Glibc

#elseif os(macOS)

import Darwin

#endif

import SwiftyGPIO
import Foundation

print("Servo Controller with Swift \n")

//guard let pwms = SwiftyGPIO.hardwarePWMs(for: .RaspberryPi2),
//      let firstPwm = pwms[0] else { fatalError("No PWM") }
//
//if let pwm = firstPwm[.P18] {
//
//    let s1 = SG90Servo(pwm)
//    s1.enable()
//
//    for _  in 0...5 {
//        print("<- Left")
//        s1.move(to: .left)
//        sleep(1)
//
//        print("^  Middle")
//        s1.move(to: .middle)
//        sleep(1)
//
//        print("-> Right")
//        s1.move(to: .right)
//        sleep(1)
//    }
//
//    s1.disable()
//}


print("Starting the PCA9685Module example (fade in channel 0 and 1)")

// Initialize the communication bus
guard let smBus = try? SMBus(busNumber: 1) else {
    fatalError("It has not been possible to open the System Managed/I2C bus")
}

// Initialize the module and led channels
guard let module = try? PCA9685Module(smBus: smBus, address: 0x40),
    let _ = try? module.set(pwmFrequency: 1000),
    let redLedChannel = PCA9685Module.Channel(rawValue: 0),
    let yellowLedChannel = PCA9685Module.Channel(rawValue: 1) else {
        fatalError("Failed to setup the module or the led channels")
}

defer {
    // Reset the module
    guard let _ = try? module.resetAllChannels(),
        let _ = try? module.softReset() else {
            fatalError("Failed to reset the module")
    }
}

let exampleDuration: TimeInterval = 5.0
let cycleDuration: TimeInterval = 0.01
let numberExampleCycles = exampleDuration / cycleDuration

// Fade the leds in
for index in 0 ... Int(numberExampleCycles) {

    let dutyCycle = 1.0 / numberExampleCycles * Double(index)
    guard let _ = try? module.write(channel: redLedChannel, dutyCycle: dutyCycle),
        let _ = try? module.write(channel: yellowLedChannel, dutyCycle: dutyCycle) else {
            fatalError("Failed to set the values for the given channels")
    }
    print("cycleDuration: \(UInt32(cycleDuration))")
    sleep(UInt32(cycleDuration))
}

// Wait still a bit when duty cycle 100%
sleep(3)
