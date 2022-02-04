// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftDecodingTests.swift
//  TwitterApacheThriftTests
//
//  Created on 3/25/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation
import XCTest
@testable import TwitterApacheThrift

class ThriftDecoderTests: XCTestCase {

    var thriftDecoder: ThriftDecoder!

    override func setUp() {
        self.thriftDecoder = ThriftDecoder()
        super.setUp()
    }

    func testEncodeFoundationTypes() throws {
        let value = Fixtures.foundationThriftStruct
        let data = try thriftDecoder.decode(FoundationThriftStruct.self, from: Data(base64Encoded: "AgABAAQAAj/zvnbItDlYBgADAIAIAAQAAAAXCgAFAAAAAAABh8ULAAYAAAALc29tZSBzdHJpbmcA")!)
        XCTAssertEqual(data, value)
    }

    func testOptionalTypes() throws {
        let data = try thriftDecoder.decode(OptionalThriftStruct.self, from: Data(base64Encoded: "BgABAAwCAAIBAA==")!)
        XCTAssertEqual(data, Fixtures.optionalThriftStruct)

        let dataWithNil = try thriftDecoder.decode(OptionalThriftStruct.self, from: Data(base64Encoded: "AgACAQA=")!)
        XCTAssertEqual(dataWithNil, Fixtures.optionalThriftStruct.with(int16Value: nil))
    }

    func testStructsTypes() throws {
        let data = try thriftDecoder.decode(SubobjectThriftStruct.self, from: Data(base64Encoded: "DAABBgABAAwCAAIBAAYAAgAyAA==")!)
        XCTAssertEqual(data, Fixtures.subobjectThriftStruct)

        let dataWithNil = try thriftDecoder.decode(SubobjectThriftStruct.self, from: Data(base64Encoded: "BgACADIA")!)
        XCTAssertEqual(dataWithNil, Fixtures.subobjectThriftStruct.with(value: nil))

        let dataWithNilInSubObject = try thriftDecoder.decode(SubobjectThriftStruct.self, from: Data(base64Encoded: "DAABAgACAQAGAAIAMgA=")!)
        XCTAssertEqual(dataWithNilInSubObject, Fixtures.subobjectThriftStruct.with(value: Fixtures.optionalThriftStruct.with(int16Value: nil)))
    }

    func testCollections() throws {
        let data = try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "DwABBAAAAAI/8ZmZmZmZmkABmZmZmZmaDQACCwsAAAABAAAAAWEAAAAEYXNkZg4AAwgAAAABAAAAAQA=")!)
        XCTAssertEqual(data, Fixtures.collectionThriftStruct)

        let dataWithEmptyCollections =  try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "DwABBAAAAAANAAILCwAAAAAOAAMIAAAAAAA=")!)
        XCTAssertEqual(dataWithEmptyCollections, Fixtures.collectionThriftStruct.with(arrays: [], maps: [:], sets: []))

        let dataWithArray = try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "DwABBAAAAAI/8ZmZmZmZmkABmZmZmZmaAA==")!)
        XCTAssertEqual(dataWithArray, Fixtures.collectionThriftStruct.with(maps: nil, sets: nil))

        let dataWithMap = try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "DQACCwsAAAABAAAAAWEAAAAEYXNkZgA=")!)
        XCTAssertEqual(dataWithMap, Fixtures.collectionThriftStruct.with(arrays: nil, sets: nil))

        let dataWithSet = try thriftDecoder.decode(CollectiontThriftStruct.self, from: Data(base64Encoded: "DgADCAAAAAEAAAABAA==")!)
        XCTAssertEqual(dataWithSet, Fixtures.collectionThriftStruct.with(arrays: nil, maps: nil))
    }

    func testUnions() throws {
        let unionA = UnionStruct(someUnion: .unionClassA(UnionClassA(someString: "string")))
        let dataA = try thriftDecoder.decode(UnionStruct.self, from: Data(base64Encoded: "DAABDAABCwABAAAABnN0cmluZwAAAA==")!)
        XCTAssertEqual(dataA, unionA)

        let unionB = UnionStruct(someUnion: .unionClassB(UnionClassB(someInt: 123)))
        let dataB = try thriftDecoder.decode(UnionStruct.self, from: Data(base64Encoded: "DAABDAACCgABAAAAAAAAAHsAAAA=")!)
        XCTAssertEqual(dataB, unionB)
    }

    func testEnums() throws {
        let enumA = EnumStruct(enumValue: .AAA)
        let dataA = try thriftDecoder.decode(EnumStruct.self, from: Data(base64Encoded: "CAABAAAAAQA=")!)
        XCTAssertEqual(dataA, enumA)

        let enumB = EnumStruct(enumValue: .BBB)
        let dataB = try thriftDecoder.decode(EnumStruct.self, from: Data(base64Encoded: "CAABAAAAAgA=")!)
        XCTAssertEqual(dataB, enumB)
    }

    func testDictionariesWithStructs() throws {
        let dict = ["a": UnionClassA(someString: "a"), "b": UnionClassA(someString: "b")]
        let data = try thriftDecoder.decode([String: UnionClassA].self, from: Data(base64Encoded: "CwwAAAACAAAAAWELAAEAAAABYQAAAAABYgsAAQAAAAFiAA==")!)
        XCTAssertEqual(dict, data)
    }

    func testDecodingUndecodableType() {
        var undecoableType: Any?
        do {
            _ = try thriftDecoder.decode(UncodableStruct.self, from: Data(base64Encoded: "CAABAAAAAgA=")!)
        } catch ThriftDecoderError.undecodableType(let type) {
            undecoableType = type
        } catch {}

        XCTAssertTrue(undecoableType is UInt64.Type)
    }

    func testDataDecoding() throws {
        let value = try thriftDecoder.decode(DataStruct.self, from: Data(base64Encoded: "CwABAAAABHRlc3QDAAIFAA==")!)
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
        let value = try thriftDecoder.decode(ArrayStruct.self, from: Data(base64Encoded: "DwABDAAAAAEPAAEEAAAAAz/wAAAAAAAAQAAAAAAAAABACAAAAAAAAAAA")!)
        XCTAssertEqual(value, expectedValue)
    }
}
