// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  MutableThriftCompactBinaryTests.swift
//  TwitterApacheThriftTests
//
//  Created on 9/30/21.
//  Copyright © 2021 Twitter. All rights reserved.
//

import Foundation
import XCTest
@testable import TwitterApacheThrift

class MutableThriftCompactBinaryTests: XCTestCase {

    var binary: MutableThriftCompactBinary!

    override func setUp() {
        super.setUp()
        self.binary = MutableThriftCompactBinary()
    }

    func testMapMetadata() {
        binary.writeMapMetadata(keyType: .string, valueType: .string, count: 2)
        //2 items
        //String, String
        XCTAssertEqual(self.binary.getBuffer(), Data([0b10, 0b10001000]))

    }

    func testMapEmptyMetadata() {
        binary.writeMapMetadata(keyType: .string, valueType: .string, count: 0)
        XCTAssertEqual(self.binary.getBuffer(), Data([0]))
    }

    func testListMetadata() {
        binary.writeListMetadata(elementType: .string, count: 1)
        XCTAssertEqual(self.binary.getBuffer(), Data([0b11000]))
    }

    func testListLargeMetadata() {
        binary.writeListMetadata(elementType: .structure, count: 16)
        XCTAssertEqual(self.binary.getBuffer(), Data([0b11111100, 0b10000]))
    }

    func testFieldMetadata() {
        binary.writeFieldBegin(fieldType: .structure, fieldID: 15, previousId: 0)
        XCTAssertEqual(self.binary.getBuffer(), Data([0b11111100]))
    }

    func testFieldMetadataNonsequential() {
        binary.writeFieldBegin(fieldType: .structure, fieldID: 20, previousId: 0)
        XCTAssertEqual(self.binary.getBuffer(), Data([0b1100, 0b0, 0b101000]))
    }

    func testFieldMetadataStop() {
        binary.writeFieldStop()
        XCTAssertEqual(self.binary.getBuffer(), Data([0]))
    }

    func testDecodeDouble() {
        self.binary.write(1.234)
        XCTAssertEqual(self.binary.getBuffer(), Data([0x58, 0x39, 0xb4, 0xc8, 0x76, 0xbe, 0xf3, 0x3f]))
    }

    func testDecodeInt32() {
        binary.write(Int32(1234))
        XCTAssertEqual(self.binary.getBuffer(), Data([0xa4, 0x13]))
    }

    func testDecodeInt64() {
        self.binary.write(Int64(Int32.max) + 1029)
        XCTAssertEqual(self.binary.getBuffer(), Data([0x88, 0x90, 0x80, 0x80, 0x10]))
    }

    func testDecodeInt16() {
        binary.write(Int16(829))
        XCTAssertEqual(self.binary.getBuffer(), Data([0xfa, 0xc]))
    }
}
