// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftEncoderCompactTests.swift
//  TwitterApacheThriftTests
//
//  Created on 9/29/21.
//  Copyright © 2021 Twitter. All rights reserved.
//

import Foundation
import XCTest
@testable import TwitterApacheThrift

class ThriftCompactEncoderTests: XCTestCase {

    var thriftEncoder: ThriftEncoder!

    override func setUp() {
        self.thriftEncoder = ThriftEncoder()
        self.thriftEncoder.specification = .compact
        super.setUp()
    }

    func testEncodeFoundationTypes() throws {
        let value = Fixtures.foundationThriftStruct
        let data = try thriftEncoder.encode(value)
        XCTAssertEqual(data.base64EncodedString(), "EhdYObTIdr7zPxSAAhUuFoqfDBgLc29tZSBzdHJpbmcA")
    }

    func testOptionalTypes() throws {
        let data = try thriftEncoder.encode(Fixtures.optionalThriftStruct)
        XCTAssertEqual(data.base64EncodedString(), "FBgRAA==")

        let dataWithNil = try thriftEncoder.encode(Fixtures.optionalThriftStruct.with(int16Value: nil))
        XCTAssertEqual(dataWithNil.base64EncodedString(), "IQA=")
    }

    func testStructsTypes() throws {
        let data = try thriftEncoder.encode(Fixtures.subobjectThriftStruct)
        XCTAssertEqual(data.base64EncodedString(), "HBQYEQAUZAA=")

        let dataWithNil = try thriftEncoder.encode(Fixtures.subobjectThriftStruct.with(value: nil))
        XCTAssertEqual(dataWithNil.base64EncodedString(), "JGQA")

        let dataWithNilInSubObject = try thriftEncoder.encode(Fixtures.subobjectThriftStruct.with(value: Fixtures.optionalThriftStruct.with(int16Value: nil)))
        XCTAssertEqual(dataWithNilInSubObject.base64EncodedString(), "HCEAFGQA")
    }

    func testCollections() throws {
        let data = try thriftEncoder.encode(Fixtures.collectionThriftStruct)
        XCTAssertEqual(data.base64EncodedString(), "GSeamZmZmZnxP5qZmZmZmQFAGwGIAWEEYXNkZhoVAgA=")

        let dataWithEmptyCollections = try thriftEncoder.encode(Fixtures.collectionThriftStruct.with(arrays: [], maps: [:], sets: []))
        XCTAssertEqual(dataWithEmptyCollections.base64EncodedString(), "GQcbABoFAA==")

        let dataWithArray = try thriftEncoder.encode(Fixtures.collectionThriftStruct.with(maps: nil, sets: nil))
        XCTAssertEqual(dataWithArray.base64EncodedString(), "GSeamZmZmZnxP5qZmZmZmQFAAA==")

        let dataWithMap = try thriftEncoder.encode(Fixtures.collectionThriftStruct.with(arrays: nil, sets: nil))
        XCTAssertEqual(dataWithMap.base64EncodedString(), "KwGIAWEEYXNkZgA=")

        let dataWithSet = try thriftEncoder.encode(Fixtures.collectionThriftStruct.with(arrays: nil, maps: nil))
        XCTAssertEqual(dataWithSet.base64EncodedString(), "OhUCAA==")
    }

    func testUnions() throws {
        let unionA = UnionStruct(someUnion: .unionClassA(UnionClassA(someString: "string")))
        let dataA = try thriftEncoder.encode(unionA)
        XCTAssertEqual(dataA.base64EncodedString(), "HBwYBnN0cmluZwAAAA==")

        let unionB = UnionStruct(someUnion: .unionClassB(UnionClassB(someInt: 123)))
        let dataB = try thriftEncoder.encode(unionB)
        XCTAssertEqual(dataB.base64EncodedString(), "HCwW9gEAAAA=")
    }

    func testEnums() throws {
        let enumA = EnumStruct(enumValue: .AAA)
        let dataA = try thriftEncoder.encode(enumA)
        XCTAssertEqual(dataA.base64EncodedString(), "FQIA")

        let enumB = EnumStruct(enumValue: .BBB)
        let dataB = try thriftEncoder.encode(enumB)
        XCTAssertEqual(dataB.base64EncodedString(), "FQQA")
    }

    func testEncodingUnencodableType() {
        var unencodableType: Any?
        do {
            _ = try thriftEncoder.encode(UncodableStruct(value: 1))
        } catch ThriftEncoderError.unencodableType(let type) {
            unencodableType = type
        } catch {}

        XCTAssertTrue(unencodableType is UInt64.Type)
    }

    func testDataEncoding() throws {
        let data = try thriftEncoder.encode(Fixtures.dataStruct)
        XCTAssertEqual(data.base64EncodedString(), "GAR0ZXN0EwUA")
    }
}
