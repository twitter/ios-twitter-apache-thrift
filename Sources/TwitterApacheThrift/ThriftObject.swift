// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftObject.swift
//  TwitterApacheThrift
//
//  Created on 9/24/21.
//  Copyright © 2021 Twitter, Inc. All rights reserved.
//

import Foundation

indirect enum ThriftObject: Hashable {
    case data(Data)
    case unkeyedCollection(ThriftUnkeyedCollection)
    case keyedCollection(ThriftKeyedCollection)
    case `struct`(ThriftStruct)
    case stop
}

struct ThriftValue: Hashable {
    var index: Int?
    var type: ThriftType
    var data: ThriftObject
}

struct ThriftStruct: Hashable {
    var index: Int?
    var fields: [Int: ThriftValue]
}

struct ThriftUnkeyedCollection: Hashable {
    var index: Int?
    var count: Int
    var elementType: ThriftType
    var value: [ThriftObject]
}

struct ThriftKeyedCollection: Hashable {
    var index: Int?
    var count: Int
    var keyType: ThriftType
    var elementType: ThriftType
    var value: [Value]

    struct Value: Hashable {
        let key: ThriftObject
        let value: ThriftObject
    }
}
