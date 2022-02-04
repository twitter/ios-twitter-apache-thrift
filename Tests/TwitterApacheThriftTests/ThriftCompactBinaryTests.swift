// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftCompactBinaryTests.swift
//  TwitterApacheThriftTests
//
//  Created on 9/30/21.
//  Copyright © 2021 Twitter. All rights reserved.
//

import Foundation
import XCTest
@testable import TwitterApacheThrift

class ThriftCompactBinaryTests: XCTestCase {

    var binary: ThriftCompactBinary!

    func testMapMetadata() throws {
        //2 items
        //String, String
        self.binary = ThriftCompactBinary(data: Data([0b10, 0b10001000]))
        let value = try binary.readMapMetadata()
        XCTAssertEqual(value.keyType, .string)
        XCTAssertEqual(value.valueType, .string)
        XCTAssertEqual(value.size, 2)
    }

    func testMapEmptyMetadata() throws {
        self.binary = ThriftCompactBinary(data: Data([0]))
        let value = try binary.readMapMetadata()
        XCTAssertEqual(value.keyType, .stop)
        XCTAssertEqual(value.valueType, .stop)
        XCTAssertEqual(value.size, 0)
    }

    func testListMetadata() throws {
        self.binary = ThriftCompactBinary(data: Data([0b00011000]))
        let value = try binary.readListMetadata()
        XCTAssertEqual(value.elementType, .string)
        XCTAssertEqual(value.size, 1)
    }

    func testListLargeMetadata() throws {
        self.binary = ThriftCompactBinary(data: Data([0b11111100, 0b10000]))
        let value = try binary.readListMetadata()
        XCTAssertEqual(value.elementType, .structure)
        XCTAssertEqual(value.size, 16)
    }

    func testFieldMetadata() throws {
        self.binary = ThriftCompactBinary(data: Data([0b11111100]))
        let value = try binary.readFieldMetadata(previousId: 0)
        XCTAssertEqual(value.type, .structure)
        XCTAssertEqual(value.id, 15)
    }

    func testFieldMetadataNonsequential() throws {
        self.binary = ThriftCompactBinary(data: Data([0b1100, 0, 0b101000]))
        let value = try binary.readFieldMetadata(previousId: 0)
        XCTAssertEqual(value.type, .structure)
        XCTAssertEqual(value.id, 20)
    }

    func testFieldMetadataStop() throws {
        self.binary = ThriftCompactBinary(data: Data([0]))
        let value = try binary.readFieldMetadata(previousId: 0)
        XCTAssertEqual(value.type, .stop)
        XCTAssertEqual(value.id, nil)
    }

    func testDecodeDouble() throws {
        self.binary = ThriftCompactBinary(data: Data([0x58, 0x39, 0xb4, 0xc8, 0x76, 0xbe, 0xf3, 0x3f]))
        let value = try binary.readDouble()
        XCTAssertEqual(value, 1.234)
    }

    func testDecodeInt32() throws {
        self.binary = ThriftCompactBinary(data: Data([0xa4, 0x13]))
        let value = try binary.readInt32()
        XCTAssertEqual(value, 1234)
    }

    func testDecodeInt64() throws {
        self.binary = ThriftCompactBinary(data: Data([0x88, 0x90, 0x80, 0x80, 0x10]))
        let value = try binary.readInt64()
        XCTAssertEqual(value, Int64(Int32.max) + 1029)
    }

    func testDecodeInt16() throws {
        self.binary = ThriftCompactBinary(data: Data([0xfa, 0xc]))
        let value = try binary.readInt16()
        XCTAssertEqual(value, 829)
    }
}
