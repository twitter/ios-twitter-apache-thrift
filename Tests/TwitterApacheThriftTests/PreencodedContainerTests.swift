//
//  ThriftDecodingTests.swift
//  TwitterApacheThriftTests
//
//  Created on 7/1/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation
import XCTest
@testable import TwitterApacheThrift

class PreencodedContainerTests: XCTestCase {

    struct TestStruct: ThriftCodable {
        let value: PreencodedContainer<Int16>
        enum CodingKeys: Int, CodingKey {
            case value = 1
        }
    }

    func testEncodingData() throws {
        let testValue = TestStruct(value: .encodedData(Data([0, 57])))
        let encoder = ThriftEncoder()
        let data = try encoder.encode(testValue)

        XCTAssertEqual(data, Data([6, 0, 1, 0, 57, 0]))
    }

    func testEncodingValue() throws {
        let testValue = TestStruct(value: .value(57))
        let encoder = ThriftEncoder()
        let data = try encoder.encode(testValue)

        XCTAssertEqual(data, Data([6, 0, 1, 0, 57, 0]))
    }

    func testDecoding() throws {
        struct ValueStruct: ThriftCodable {
            let value: Int16
            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }

        let decoder = ThriftDecoder()
        let testStructValue = try decoder.decode(TestStruct.self, from: Data([6, 0, 1, 0, 57, 0]))
        let valueStructValue = try decoder.decode(ValueStruct.self, from: Data([6, 0, 1, 0, 57, 0]))

        XCTAssertEqual(testStructValue.value, .value(57))
        XCTAssertEqual(valueStructValue.value, 57)
    }
}
