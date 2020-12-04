// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftType.swift
//  TwitterApacheThrift
//
//  Created on 3/25/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation

/// A mapping between Swift types and thrift type
///
/// - Note: Any type not listed is not supported
public enum ThriftType: UInt8 {
    /// Thrift control type not mapped to swift type
    case stop = 0
    /// Thrift control type not mapped to swift type
    case void = 1
    case bool = 2
    /// Represented as a UInt8
    case byte = 3
    case double = 4
    case int16 = 6
    case int32 = 8
    case int64 = 10
    /// This type can be either a String or Data
    /// it is determined based on the type in the model
    case string = 11
    case structure = 12
    /// Represented as a dictionary
    case map = 13
    case set = 14
    /// Represented as an array
    case list = 15
}

extension ThriftType {
    init(coreValue: UInt8) throws {
        guard let value = ThriftType(rawValue: coreValue) else {
            throw ThriftDecoderError.unsupportedThriftType
        }
        self = value
    }
}

extension ThriftType {
    static func type<T>(from value: T) throws -> ThriftType where T : Encodable {
        return try type(from: T.self)
    }

    static func type<T>(from value: T.Type) throws -> ThriftType where T : Encodable {
        switch value {
        case is Bool.Type:
            return .bool
        case is Data.Type:
            return .string //String because the format is the same
        case is Double.Type:
            return .double
        case is UInt8.Type:
            return .byte
        case is Int16.Type:
            return .int16
        case is Int32.Type:
            return .int32
        case is Int64.Type:
            return .int64
        case is String.Type:
            return .string
        case let v as ThriftEncodable.Type:
            return try v.thriftType()
        default:
            throw ThriftEncoderError.unencodableType(type: value.self)
        }
    }
}
