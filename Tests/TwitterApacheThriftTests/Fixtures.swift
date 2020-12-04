// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  Fixtures.swift
//  TwitterApacheThriftTests
//
//  Created on 3/25/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation
import TwitterApacheThrift

extension OptionalThriftStruct {
    func with(int16Value: Int16?? = .some(nil)) -> OptionalThriftStruct {
        return OptionalThriftStruct(int16Value: int16Value.flatMap({ $0 ?? self.int16Value }))
    }
}

extension SubobjectThriftStruct {
    func with(value: OptionalThriftStruct?? = .some(nil), intValue: Int16? = nil) -> SubobjectThriftStruct {
        return SubobjectThriftStruct(value: value.flatMap({ $0 ?? self.value }),
                                     intValue: intValue ?? self.intValue)
    }
}

extension CollectiontThriftStruct {
    func with(arrays: [Double]?? = .some(nil), maps: [String: String]?? = .some(nil), sets: Set<Int32>?? = .some(nil)) -> CollectiontThriftStruct {
        return CollectiontThriftStruct(arrays: arrays.flatMap({ $0 ?? self.arrays }),
                                       maps: maps.flatMap({ $0 ?? self.maps }),
                                       sets: sets.flatMap({ $0 ?? self.sets }))
    }
}

enum Fixtures {
    static var foundationThriftStruct = FoundationThriftStruct(boolValue: false,
                                                               doubleValue: 1.234,
                                                               int16Value: 128,
                                                               int32Value: 23,
                                                               int64Value: 100293,
                                                               stringValue: "some string")

    static var optionalThriftStruct =  OptionalThriftStruct(int16Value: 12)

    static var subobjectThriftStruct = SubobjectThriftStruct(value: Fixtures.optionalThriftStruct, intValue: 50)

    static var collectionThriftStruct = CollectiontThriftStruct(arrays: [1.1, 2.2],
                                                                maps: ["a": "asdf"],
                                                                sets: [1])

    static var dataStruct = DataStruct(data: Data("test".utf8), byte: 5)
}

struct UncodableStruct: ThriftCodable {
    enum CodingKeys: Int, CodingKey {
        case value = 1
    }

    let value: UInt64
}

struct DataStruct: ThriftCodable, Equatable {

    enum CodingKeys: Int, CodingKey {
        case data = 1
        case byte = 2
    }

    let data: Data
    let byte: UInt8
}
