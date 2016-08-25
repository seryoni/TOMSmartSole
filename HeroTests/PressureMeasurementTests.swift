//
//  PressureMeasurementTests.swift
//  Hero
//
//  Created by Nissan Tsafrir on 25.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import XCTest
@testable import Hero

class PressureMeasurementTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let bytes : [UInt8] = [0x00, 0xD5, 0x01, 0, 0]
        
//        var buf: [CUnsignedChar] = Array<CUnsignedChar>(count: 10, repeatedValue: 255)
//
//        ///  value: 469.0
//        //   hex:  00 , D5, 01
//        buf[0] = 0x00
//        buf[1] = 0xD5
//        buf[2] = 0x01
//        buf[3] = 0x00
//        buf[4] = 0x00
        
        let data = NSData(bytes: bytes, length: 5)
        let pressure = PressureMeasurment(data
            : data)
        
        XCTAssertEqual(pressure.pressure, 469)
    }
    
}
