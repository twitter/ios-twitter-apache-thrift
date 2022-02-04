// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  MutableThriftBinaryTests.swift
//  TwitterApacheThriftTests
//
//  Created on 3/27/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation
import XCTest
@testable import TwitterApacheThrift

class MutableThriftBinaryTests: XCTestCase {

    var binary: MutableThriftBinary!

    func testWriteInt32() {
        binary = MutableThriftBinary()
        binary.write(Int32.max - 1)
        XCTAssertEqual(binary.getBuffer(), Data([127, 255, 255, 254]))

        let data2 = Data([128, 0, 0, 1])
        binary = MutableThriftBinary()
        binary.write(Int32.min + 1)
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([0, 0, 0, 0])
        binary = MutableThriftBinary()
        binary.write(Int32(0))
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([0, 0, 75, 148])
        binary = MutableThriftBinary()
        binary.write(Int32(19348))
        XCTAssertEqual(binary.getBuffer(), data4)

        let data5 =  Data([255, 255, 180, 108])
        binary = MutableThriftBinary()
        binary.write(Int32(-19348))
        XCTAssertEqual(binary.getBuffer(), data5)
    }

    func testWriteInt64() {
        let data1 = Data([127, 255, 255, 255, 255, 255, 255, 254])
        binary = MutableThriftBinary()
        binary.write(Int64.max - 1)
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data( [128, 0, 0, 0, 0, 0, 0, 1])
        binary = MutableThriftBinary()
        binary.write(Int64.min + 1)
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([0, 0, 0, 0, 0, 0, 0, 0])
        binary = MutableThriftBinary()
        binary.write(Int64(0))
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([0, 0, 0, 0, 0, 0, 75, 148])
        binary = MutableThriftBinary()
        binary.write(Int64(19348))
        XCTAssertEqual(binary.getBuffer(), data4)

        let data5 =  Data([255, 255, 255, 255, 255, 255, 180, 108])
        binary = MutableThriftBinary()
        binary.write(Int64(-19348))
        XCTAssertEqual(binary.getBuffer(), data5)
    }

    func testWriteInt16() {
        let data1 = Data([127, 254])
        binary = MutableThriftBinary()
        binary.write(Int16.max - 1)
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([128, 1])
        binary = MutableThriftBinary()
        binary.write(Int16.min + 1)
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([0, 0])
        binary = MutableThriftBinary()
        binary.write(Int16(0))
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([0, 57])
        binary = MutableThriftBinary()
        binary.write(Int16(57))
        XCTAssertEqual(binary.getBuffer(), data4)

        let data5 =  Data([255, 199])
        binary = MutableThriftBinary()
        binary.write(Int16(-57))
        XCTAssertEqual(binary.getBuffer(), data5)
    }

    func testWriteByte() {
        let data1 = Data([127])
        binary = MutableThriftBinary()
        binary.write(UInt8(127))
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([0])
        binary = MutableThriftBinary()
        binary.write(UInt8(0))
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([1])
        binary = MutableThriftBinary()
        binary.write(UInt8(1))
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([57])
        binary = MutableThriftBinary()
        binary.write(UInt8(57))
        XCTAssertEqual(binary.getBuffer(), data4)

        let data5 =  Data([255])
        binary = MutableThriftBinary()
        binary.write(UInt8(255))
        XCTAssertEqual(binary.getBuffer(), data5)
    }

    func testWriteDouble() {
        let data1 = Data([67, 224, 0, 0, 0, 0, 0, 0])
        binary = MutableThriftBinary()
        binary.write(Double(Int64.max) + 0.352352345346234)
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([195, 224, 0, 0, 0, 0, 0, 0])
        binary = MutableThriftBinary()
        binary.write(Double(Int64.min) + 0.352352345346234)
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([0, 0, 0, 0, 0, 0, 0, 0])
        binary = MutableThriftBinary()
        binary.write(Double(0))
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([192, 76, 186, 23, 155, 146, 152, 30])
        binary = MutableThriftBinary()
        binary.write(-57.45384545)
        XCTAssertEqual(binary.getBuffer(), data4)

        let data5 =  Data([64, 76, 186, 23, 155, 146, 152, 30])
        binary = MutableThriftBinary()
        binary.write(57.45384545)
        XCTAssertEqual(binary.getBuffer(), data5)
    }

    func testWriteString() {
        let data1 = Data([0, 0, 0, 4, 97, 98, 99, 100])
        binary = MutableThriftBinary()
        binary.write("abcd")
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([0, 0, 0, 1, 97])
        binary = MutableThriftBinary()
        binary.write("a")
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([0, 0, 0, 0])
        binary = MutableThriftBinary()
        binary.write("")
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([0, 0, 0, 4, 240, 159, 152, 128])
        binary = MutableThriftBinary()
        binary.write("😀")
        XCTAssertEqual(binary.getBuffer(), data4)
    }

    func testWriteBinary() {
        let data1 = Data([0, 0, 0, 4, 1, 1, 2, 3])
        binary = MutableThriftBinary()
        binary.write(Data([1, 1, 2, 3]))
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([0, 0, 0, 1, 97])
        binary = MutableThriftBinary()
        binary.write(Data([97]))
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([0, 0, 0, 0])
        binary = MutableThriftBinary()
        binary.write(Data())
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([0, 0, 0, 4, 240, 159, 152, 128])
        binary = MutableThriftBinary()
        binary.write(Data([240, 159, 152, 128]))
        XCTAssertEqual(binary.getBuffer(), data4)
    }

    func testWriteBool() {
        let data1 = Data([0])
        binary = MutableThriftBinary()
        binary.write(false)
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([1])
        binary = MutableThriftBinary()
        binary.write(true)
        XCTAssertEqual(binary.getBuffer(), data2)
    }

    func testWriteMapMetadata() {
        let data1 = Data([10, 11, 0, 0, 0, 6])
        binary = MutableThriftBinary()
        binary.writeMapMetadata(keyType: .int64, valueType: .string, count: 6)
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([11, 12, 0, 0, 0, 2])
        binary = MutableThriftBinary()
        binary.writeMapMetadata(keyType: .string, valueType: .structure, count: 2)
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([6, 14, 0, 0, 0, 1])
        binary = MutableThriftBinary()
        binary.writeMapMetadata(keyType: .int16, valueType: .set, count: 1)
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([8, 15, 127, 255, 255, 255])
        binary = MutableThriftBinary()
        binary.writeMapMetadata(keyType: .int32, valueType: .list, count: Int(Int32.max))
        XCTAssertEqual(binary.getBuffer(), data4)
    }

    func testWriteSetMetadata() {
        let data1 = Data([11, 0, 0, 0, 6])
        binary = MutableThriftBinary()
        binary.writeSetMetadata(elementType: .string, count: 6)
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([12, 0, 0, 0, 2])
        binary = MutableThriftBinary()
        binary.writeSetMetadata(elementType: .structure, count: 2)
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([14, 0, 0, 0, 1])
        binary = MutableThriftBinary()
        binary.writeSetMetadata(elementType: .set, count: 1)
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([15, 127, 255, 255, 255])
        binary = MutableThriftBinary()
        binary.writeSetMetadata(elementType: .list, count: Int(Int32.max))
        XCTAssertEqual(binary.getBuffer(), data4)
    }

    func testWriteListMetadata() {
        let data1 = Data([11, 0, 0, 0, 6])
        binary = MutableThriftBinary()
        binary.writeListMetadata(elementType: .string, count: 6)
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([12, 0, 0, 0, 2])
        binary = MutableThriftBinary()
        binary.writeListMetadata(elementType: .structure, count: 2)
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([14, 0, 0, 0, 1])
        binary = MutableThriftBinary()
        binary.writeListMetadata(elementType: .set, count: 1)
        XCTAssertEqual(binary.getBuffer(), data3)

        let data4 = Data([15, 127, 255, 255, 255])
        binary = MutableThriftBinary()
        binary.writeListMetadata(elementType: .list, count: Int(Int32.max))
        XCTAssertEqual(binary.getBuffer(), data4)
    }

    func testWriteFieldMetadata() {
        let data1 = Data([10, 0, 6])
        binary = MutableThriftBinary()
        binary.writeFieldBegin(fieldType: .int64, fieldID: 6, previousId: 0)
        XCTAssertEqual(binary.getBuffer(), data1)

        let data2 = Data([11, 0, 2])
        binary = MutableThriftBinary()
        binary.writeFieldBegin(fieldType: .string, fieldID: 2, previousId: 0)
        XCTAssertEqual(binary.getBuffer(), data2)

        let data3 = Data([6, 0, 1])
        binary = MutableThriftBinary()
        binary.writeFieldBegin(fieldType: .int16, fieldID: 1, previousId: 0)
        XCTAssertEqual(binary.getBuffer(), data3)
    }

    func testWriteStop() {
        let data1 = Data([0])
        binary = MutableThriftBinary()
        binary.writeFieldStop()
        XCTAssertEqual(binary.getBuffer(), data1)
    }
}
