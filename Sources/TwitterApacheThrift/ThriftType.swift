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
    /// A `bool` type
    case bool = 2
    /// Represented as a `UInt8`
    case byte = 3
    /// A `Double` type
    case double = 4
    /// A `Int16` type
    case int16 = 6
    /// A `Int32` type
    case int32 = 8
    /// A `Int64`
    case int64 = 10
    /// This type can be either a String or Data
    /// it is determined based on the type in the model
    case string = 11
    /// A struct or a class depending on the model
    case structure = 12
    /// Represented as a dictionary
    case map = 13
    /// A `Set` type
    case set = 14
    /// Represented as an array
    case list = 15
}

extension ThriftType {

    /// Creates a ThriftType from the a thrift value
    /// - Parameter coreValue: The value from the thrift
    /// - Throws: `ThriftDecoderError.unsupportedThriftType` if the type is not supported
    init(coreValue: UInt8) throws {
        guard let value = ThriftType(rawValue: coreValue) else {
            throw ThriftDecoderError.unsupportedThriftType
        }
        self = value
    }
}

extension ThriftType {

    /// Maps a value to a thrift type
    /// - Parameter value: The value to convert
    /// - Throws: `ThriftEncoderError.unencodableType` when the type is not supported
    /// - Returns: The thrift type of the value
    static func type<T>(from value: T) throws -> ThriftType where T : Encodable {
        return try type(from: T.self)
    }

    /// Maps a type to a thrift type
    /// - Parameter value: The value to convert
    /// - Throws: `ThriftEncoderError.unencodableType` when the type is not supported
    /// - Returns: The thrift type of the value
    static func type<T>(from value: T.Type) throws -> ThriftType where T : Encodable {
        switch value {
        case is Bool.Type:
            return .bool
        case is Data.Type:
            return .string //Data is not an offical thrift type but is the same format as string
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
