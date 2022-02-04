// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftCompactDecoderTests.swift
//  TwitterApacheThriftTests
//
//  Created on 9/29/21.
//  Copyright © 2021 Twitter. All rights reserved.
//

import Foundation
import XCTest
@testable import TwitterApacheThrift

class ThriftCompactDecoderTests: XCTestCase {

    var thriftDecoder: ThriftDecoder!

    override func setUp() {
        self.thriftDecoder = ThriftDecoder()
        thriftDecoder.specification = .compact
        super.setUp()
    }

    func testEncodeFoundationTypes() throws {
        let value = Fixtures.foundationThriftStruct
        let data = try thriftDecoder.decode(FoundationThriftStruct.self, from: Data(base64Encoded: "EhdYObTIdr7zPxSAAhUuFoqfDBgLc29tZSBzdHJpbmcA")!)
        XCTAssertEqual(data, value)
    }

    func testOptionalTypes() throws {
        let data = try thriftDecoder.decode(OptionalThriftStruct.self, from: Data(base64Encoded: "FBgRAA==")!)
        XCTAssertEqual(data, Fixtures.optionalThriftStruct)

        let dataWithNil = try thriftDecoder.decode(OptionalThriftStruct.self, from: Data(base64Encoded: "IQA=")!)
        XCTAssertEqual(dataWithNil, Fixtures.optionalThriftStruct.with(int16Value: nil))
    }

    func testStructsTypes() throws {
        let data = try thriftDecoder.decode(SubobjectThriftStruct.self, from: Data(base64Encoded: "HBQYEQAUZAA=")!)
        XCTAssertEqual(data, Fixtures.subobjectThriftStruct)

        let dataWithNil = try thriftDecoder.decode(SubobjectThriftStruct.self, from: Data(base64Encoded: "JGQA")!)
        XCTAssertEqual(dataWithNil, Fixtures.subobjectThriftStruct.with(value: nil))

        let dataWithNilInSubObject = try thriftDecoder.decode(SubobjectThriftStruct.self, from: Data(base64Encoded: "HCEAFGQA")!)
        XCTAssertEqual(dataWithNilInSubObject, Fixtures.subobjectThriftStruct.with(value: Fixtures.optionalThriftStruct.with(int16Value: nil)))
    }

    func testCollections() throws {
        let data = try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "GSeamZmZmZnxP5qZmZmZmQFAGwGIAWEEYXNkZhoVAgA=")!)
        XCTAssertEqual(data, Fixtures.collectionThriftStruct)

        let dataWithEmptyCollections =  try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "GQcbABoFAA==")!)
        XCTAssertEqual(dataWithEmptyCollections, Fixtures.collectionThriftStruct.with(arrays: [], maps: [:], sets: []))

        let dataWithArray = try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "GSeamZmZmZnxP5qZmZmZmQFAAA==")!)
        XCTAssertEqual(dataWithArray, Fixtures.collectionThriftStruct.with(maps: nil, sets: nil))

        let dataWithMap = try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "KwGIAWEEYXNkZgA=")!)
        XCTAssertEqual(dataWithMap, Fixtures.collectionThriftStruct.with(arrays: nil, sets: nil))

        let dataWithSet = try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "OhUCAA==")!)
        XCTAssertEqual(dataWithSet, Fixtures.collectionThriftStruct.with(arrays: nil, maps: nil))
    }

    func testUnions() throws {
        let unionA = UnionStruct(someUnion: .unionClassA(UnionClassA(someString: "string")))
        let dataA = try thriftDecoder.decode(UnionStruct.self, from: Data(base64Encoded: "HBwYBnN0cmluZwAAAA==")!)
        XCTAssertEqual(dataA, unionA)

        let unionB = UnionStruct(someUnion: .unionClassB(UnionClassB(someInt: 123)))
        let dataB = try thriftDecoder.decode(UnionStruct.self, from: Data(base64Encoded: "HCwW9gEAAAA=")!)
        XCTAssertEqual(dataB, unionB)
    }

    func testEnums() throws {
        let enumA = EnumStruct(enumValue: .AAA)
        let dataA = try thriftDecoder.decode(EnumStruct.self, from: Data(base64Encoded: "FQIA")!)
        XCTAssertEqual(dataA, enumA)

        let enumB = EnumStruct(enumValue: .BBB)
        let dataB = try thriftDecoder.decode(EnumStruct.self, from: Data(base64Encoded: "FQQA")!)
        XCTAssertEqual(dataB, enumB)
    }

    func testDataDecoding() throws {
        let value = try thriftDecoder.decode(DataStruct.self, from: Data(base64Encoded: "GAR0ZXN0EwUA")!)
        XCTAssertEqual(value, Fixtures.dataStruct)
    }

    func testEmbeddedCollections() throws {
        struct ArrayStruct: ThriftCodable, Equatable {
            let array: [CollectiontThriftStruct]
            enum CodingKeys: Int, CodingKey {
                case array = 1
            }
        }

        let expectedValue = ArrayStruct(array: [CollectiontThriftStruct(arrays: [1,2,3], maps: nil, sets: nil)])
        let value = try thriftDecoder.decode(ArrayStruct.self, from: Data(base64Encoded: "GRwZNwAAAAAAAPA/AAAAAAAAAEAAAAAAAAAIQAAA")!)
        XCTAssertEqual(value, expectedValue)
    }
}
