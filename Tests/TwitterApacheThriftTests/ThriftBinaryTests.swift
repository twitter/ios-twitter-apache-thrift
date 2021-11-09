// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftBinaryTests.swift
//  TwitterApacheThriftTests
//
//  Created on 3/27/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation
import XCTest
@testable import TwitterApacheThrift

class ThriftBinaryTests: XCTestCase {

    var binary: ThriftBinary!

    func testReadInt32() throws {
        let data1 = Data([127, 255, 255, 254])
        binary = ThriftBinary(data: data1)
        XCTAssertEqual(try binary.readInt32(), Int32.max - 1)

        let data2 = Data([128, 0, 0, 1])
        binary = ThriftBinary(data: data2)
        XCTAssertEqual(try binary.readInt32(), Int32.min + 1)

        let data3 = Data([0, 0, 0, 0])
        binary = ThriftBinary(data: data3)
        XCTAssertEqual(try binary.readInt32(), 0)

        let data4 = Data([0, 0, 75, 148])
        binary = ThriftBinary(data: data4)
        XCTAssertEqual(try binary.readInt32(), Int32(19348))

        let data5 =  Data([255, 255, 180, 108])
        binary = ThriftBinary(data: data5)
        XCTAssertEqual(try binary.readInt32(), Int32(-19348))
    }

    func testReadInt64() throws {
        let data1 = Data([127, 255, 255, 255, 255, 255, 255, 254])
        binary = ThriftBinary(data: data1)
        XCTAssertEqual(try binary.readInt64(), Int64.max - 1)

        let data2 = Data( [128, 0, 0, 0, 0, 0, 0, 1])
        binary = ThriftBinary(data: data2)
        XCTAssertEqual(try binary.readInt64(), Int64.min + 1)

        let data3 = Data([0, 0, 0, 0, 0, 0, 0, 0])
        binary = ThriftBinary(data: data3)
        XCTAssertEqual(try binary.readInt64(), 0)

        let data4 = Data([0, 0, 0, 0, 0, 0, 75, 148])
        binary = ThriftBinary(data: data4)
        XCTAssertEqual(try binary.readInt64(), 19348)

        let data5 =  Data([255, 255, 255, 255, 255, 255, 180, 108])
        binary = ThriftBinary(data: data5)
        XCTAssertEqual(try binary.readInt64(), -19348)
    }

    func testReadInt16() throws {
        let data1 = Data([127, 254])
        binary = ThriftBinary(data: data1)
        XCTAssertEqual(try binary.readInt16(), Int16.max - 1)

        let data2 = Data([128, 1])
        binary = ThriftBinary(data: data2)
        XCTAssertEqual(try binary.readInt16(), Int16.min + 1)

        let data3 = Data([0, 0])
        binary = ThriftBinary(data: data3)
        XCTAssertEqual(try binary.readInt16(), 0)

        let data4 = Data([0, 57])
        binary = ThriftBinary(data: data4)
        XCTAssertEqual(try binary.readInt16(), 57)

        let data5 =  Data([255, 199])
        binary = ThriftBinary(data: data5)
        XCTAssertEqual(try binary.readInt16(), -57)
    }

    func testReadByte() throws {
        let data1 = Data([127])
        binary = ThriftBinary(data: data1)
        XCTAssertEqual(try binary.readByte(), 127)

        let data2 = Data([0])
        binary = ThriftBinary(data: data2)
        XCTAssertEqual(try binary.readByte(), 0)

        let data3 = Data([1])
        binary = ThriftBinary(data: data3)
        XCTAssertEqual(try binary.readByte(), 1)

        let data4 = Data([57])
        binary = ThriftBinary(data: data4)
        XCTAssertEqual(try binary.readByte(), 57)

        let data5 =  Data([255])
        binary = ThriftBinary(data: data5)
        XCTAssertEqual(try binary.readByte(), 255)
    }

    func testReadDouble() throws {
        let data1 = Data([67, 224, 0, 0, 0, 0, 0, 0])
        binary = ThriftBinary(data: data1)
        XCTAssertEqual(try binary.readDouble(), Double(Int64.max) + 0.352352345346234)

        let data2 = Data([195, 224, 0, 0, 0, 0, 0, 0])
        binary = ThriftBinary(data: data2)
        XCTAssertEqual(try binary.readDouble(), Double(Int64.min) + 0.352352345346234)

        let data3 = Data([0, 0, 0, 0, 0, 0, 0, 0])
        binary = ThriftBinary(data: data3)
        XCTAssertEqual(try binary.readDouble(), 0)

        let data4 = Data([192, 76, 186, 23, 155, 146, 152, 30])
        binary = ThriftBinary(data: data4)
        XCTAssertEqual(try binary.readDouble(), -57.45384545)

        let data5 =  Data([64, 76, 186, 23, 155, 146, 152, 30])
        binary = ThriftBinary(data: data5)
        XCTAssertEqual(try binary.readDouble(), 57.45384545)
    }

    func testReadString() throws {
        let data1 = Data([0, 0, 0, 4, 97, 98, 99, 100])
        binary = ThriftBinary(data: data1)
        XCTAssertEqual(try binary.readString(), "abcd")

        let data2 = Data([0, 0, 0, 1, 97])
        binary = ThriftBinary(data: data2)
        XCTAssertEqual(try binary.readString(), "a")

        let data3 = Data([0, 0, 0, 0])
        binary = ThriftBinary(data: data3)
        XCTAssertEqual(try binary.readString(), "")

        let data4 = Data([0, 0, 0, 4, 240, 159, 152, 128])
        binary = ThriftBinary(data: data4)
        XCTAssertEqual(try binary.readString(), "😀")

        let data5 =  Data([0, 0, 0, 2, 192, 97])
        binary = ThriftBinary(data: data5)
        var didThrow = false
        do {
            _ = try binary.readString()
        } catch ThriftDecoderError.nonUTF8StringData(let stringData) {
            didThrow = true
            XCTAssertEqual(Data([192, 97]), stringData)
        }
        XCTAssertTrue(didThrow)
    }

    func testReadBinary() throws {
        let data1 = Data([0, 0, 0, 4, 1, 1, 2, 3])
        binary = ThriftBinary(data: data1)
        XCTAssertEqual(try binary.readBinary(), Data([1, 1, 2, 3]))

        let data2 = Data([0, 0, 0, 1, 97])
        binary = ThriftBinary(data: data2)
        XCTAssertEqual(try binary.readBinary(), Data([97]))

        let data3 = Data([0, 0, 0, 0])
        binary = ThriftBinary(data: data3)
        XCTAssertEqual(try binary.readBinary(), Data())

        let data4 = Data([0, 0, 0, 4, 240, 159, 152, 128])
        binary = ThriftBinary(data: data4)
        XCTAssertEqual(try binary.readBinary(), Data([240, 159, 152, 128]))
    }

    func testReadBool() throws {
        let data1 = Data([0])
        binary = ThriftBinary(data: data1)
        XCTAssertFalse(try binary.readBool())

        let data2 = Data([1])
        binary = ThriftBinary(data: data2)
        XCTAssertTrue(try binary.readBool())

        let data3 = Data([255])
        binary = ThriftBinary(data: data3)
        XCTAssertFalse(try binary.readBool())
    }

    func testReadMapMetadata() throws {
        let data1 = Data([10, 11, 0, 0, 0, 6])
        binary = ThriftBinary(data: data1)
        let value1 = try binary.readMapMetadata()
        XCTAssertEqual(value1.keyType, .int64)
        XCTAssertEqual(value1.valueType, .string)
        XCTAssertEqual(value1.size, 6)

        let data2 = Data( [11, 12, 0, 0, 0, 2])
        binary = ThriftBinary(data: data2)
        let value2 = try binary.readMapMetadata()
        XCTAssertEqual(value2.keyType, .string)
        XCTAssertEqual(value2.valueType, .structure)
        XCTAssertEqual(value2.size, 2)

        let data3 = Data([6, 14, 0, 0, 0, 1])
        binary = ThriftBinary(data: data3)
        let value3 = try binary.readMapMetadata()
        XCTAssertEqual(value3.keyType, .int16)
        XCTAssertEqual(value3.valueType, .set)
        XCTAssertEqual(value3.size, 1)

        let data4 = Data([6, 15, 127, 255, 255, 255])
        binary = ThriftBinary(data: data4)
        let value4 = try binary.readMapMetadata()
        XCTAssertEqual(value4.keyType, .int16)
        XCTAssertEqual(value4.valueType, .list)
        XCTAssertEqual(value4.size, Int(Int32.max))
    }

    func testReadSetMetadata() throws {
        let data1 = Data([11, 0, 0, 0, 6])
        binary = ThriftBinary(data: data1)
        let value1 = try binary.readSetMetadata()
        XCTAssertEqual(value1.elementType, .string)
        XCTAssertEqual(value1.size, 6)

        let data2 = Data( [12, 0, 0, 0, 2])
        binary = ThriftBinary(data: data2)
        let value2 = try binary.readSetMetadata()
        XCTAssertEqual(value2.elementType, .structure)
        XCTAssertEqual(value2.size, 2)

        let data3 = Data([14, 0, 0, 0, 1])
        binary = ThriftBinary(data: data3)
        let value3 = try binary.readSetMetadata()
        XCTAssertEqual(value3.elementType, .set)
        XCTAssertEqual(value3.size, 1)

        let data4 = Data([15, 127, 255, 255, 255])
        binary = ThriftBinary(data: data4)
        let value4 = try binary.readSetMetadata()
        XCTAssertEqual(value4.elementType, .list)
        XCTAssertEqual(value4.size, Int(Int32.max))
    }

    func testReadListMetadata() throws {
        let data1 = Data([11, 0, 0, 0, 6])
        binary = ThriftBinary(data: data1)
        let value1 = try binary.readListMetadata()
        XCTAssertEqual(value1.elementType, .string)
        XCTAssertEqual(value1.size, 6)

        let data2 = Data( [12, 0, 0, 0, 2])
        binary = ThriftBinary(data: data2)
        let value2 = try binary.readListMetadata()
        XCTAssertEqual(value2.elementType, .structure)
        XCTAssertEqual(value2.size, 2)

        let data3 = Data([14, 0, 0, 0, 1])
        binary = ThriftBinary(data: data3)
        let value3 = try binary.readListMetadata()
        XCTAssertEqual(value3.elementType, .set)
        XCTAssertEqual(value3.size, 1)

        let data4 = Data([15, 127, 255, 255, 255])
        binary = ThriftBinary(data: data4)
        let value4 = try binary.readListMetadata()
        XCTAssertEqual(value4.elementType, .list)
        XCTAssertEqual(value4.size, Int(Int32.max))
    }

    func testReadFieldMetadata() throws {
        let data1 = Data([10, 0, 6])
        binary = ThriftBinary(data: data1)
        let value1 = try binary.readFieldMetadata()
        XCTAssertEqual(value1.type, .int64)
        XCTAssertEqual(value1.id, 6)

        let data2 = Data([11, 0, 2])
        binary = ThriftBinary(data: data2)
        let value2 = try binary.readFieldMetadata()
        XCTAssertEqual(value2.type, .string)
        XCTAssertEqual(value2.id, 2)

        let data3 = Data([6, 0, 1])
        binary = ThriftBinary(data: data3)
        let value3 = try binary.readFieldMetadata()
        XCTAssertEqual(value3.type, .int16)
        XCTAssertEqual(value3.id, 1)

        let data4 = Data([0])
        binary = ThriftBinary(data: data4)
        let value4 = try binary.readFieldMetadata()
        XCTAssertEqual(value4.type, .stop)
        XCTAssertNil(value4.id)
    }

    func testOverflowRead() {
        let data1 = Data([10])
        binary = ThriftBinary(data: data1)
        var didThrow = false
        do {
            _ = try binary.readInt64()
        } catch ThriftDecoderError.readBufferOverflow {
            didThrow = true
        } catch {
            XCTFail()
        }
        XCTAssertTrue(didThrow)

        let data2 = Data([10])
        binary = ThriftBinary(data: data2)
        binary.moveReadCursorBackAfterTypeAndFieldID()
        didThrow = false
        do {
            _ = try binary.readInt64()
        } catch ThriftDecoderError.readBufferOverflow {
            didThrow = true
        } catch {
            XCTFail()
        }

        XCTAssertTrue(didThrow)
    }
}

#if !canImport(ObjectiveC)
extension ThriftBinaryTests {
    static var allTests : [(String, ((ThriftBinaryTests) -> () throws -> Void))] {
        return [
            ("testReadInt32", testReadInt32),
            ("testReadInt64", testReadInt64),
            ("testReadInt16", testReadInt16),
            ("testReadByte", testReadByte),
            ("testReadDouble", testReadDouble),
            ("testReadString", testReadString),
            ("testReadBinary", testReadBinary),
            ("testReadBool", testReadBool),
            ("testReadMapMetadata", testReadMapMetadata),
            ("testReadSetMetadata", testReadSetMetadata),
            ("testReadListMetadata", testReadListMetadata),
            ("testReadFieldMetadata", testReadFieldMetadata),
            ("testOverflowRead", testOverflowRead)
        ]
    }
}
#endif
