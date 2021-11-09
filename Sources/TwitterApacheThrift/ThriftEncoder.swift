// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftEncoder.swift
//  TwitterApacheThrift
//
//  Created on 3/23/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation

public extension ThriftEncodable {
    func thriftEncode(to encoder: ThriftEncoder) throws {
        try self.encode(to: encoder)
        encoder.binary?.writeFieldStop()
    }

    static func thriftType() throws -> ThriftType {
        return .structure
    }

    func validate() throws {}
}

/// Errors thrown when the thrift is encoded.
public enum ThriftEncoderError: Error {
    /// Internal buffer is uninitialized
    case uninitializedEncodingData
    /// CodingKey is missing the value
    case codingKeyMissingIntValue(key: CodingKey)
    /// The type is not encodable, example not conforming to ThriftEncodable
    case unencodableType(type: Any)
    /// The validate method returned an error
    case validationFailure(type: Any)
}

///An object that encodes instances of a data type to Thrift objects.
public class ThriftEncoder: Encoder {

    fileprivate var binary: MutableThriftBinary?

    public var codingPath: [CodingKey] = []

    public var userInfo: [CodingUserInfoKey : Any] = [:]

    fileprivate var previousId: Int = 0

    /// The specification to be used for encoding
    public var specification: ThriftSpecification = .standard

    /// Initializes `self` with defaults.
    public init() {}

    fileprivate init(binary: MutableThriftBinary?, specification: ThriftSpecification) {
        self.binary = binary
        self.specification = specification
    }

    /// Encodes the given top-level value and returns its Thrift representation.
    ///
    /// - parameter value: The value to encode.
    /// - returns: A new `Data` value containing the encoded Thrift data.
    /// - throws: `ThriftEncoderError` An error if any value throws an error during encoding.
    public func encode<T>(_ value: T) throws -> Data where T: ThriftEncodable {
        let binary = specification == .compact ? MutableThriftCompactBinary() : MutableThriftBinary()
        self.binary = binary
        try value.thriftEncode(to: self)
        self.previousId = 0
        return binary.getBuffer()
    }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self))
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return UnkeyedContainer(encoder: self)
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        return UnkeyedContainer(encoder: self)
    }

    private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var encoder: ThriftEncoder

        var codingPath: [CodingKey] { return [] }

        func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            try encoder.encode(value, forKey: key)
        }

        func encodeNil(forKey key: Key) throws {}

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return encoder.container(keyedBy: keyType)
        }

        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            return encoder.unkeyedContainer()
        }

        func superEncoder() -> Encoder {
            return encoder
        }

        func superEncoder(forKey key: Key) -> Encoder {
            return encoder
        }
    }

    fileprivate struct UnkeyedContainer: UnkeyedEncodingContainer, SingleValueEncodingContainer {
        var encoder: ThriftEncoder

        var codingPath: [CodingKey] { return [] }

        var count: Int { return 0 }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return encoder.container(keyedBy: keyType)
        }

        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            return self
        }

        func superEncoder() -> Encoder {
            return encoder
        }

        func encodeNil() throws {}

        func encode<T>(_ value: T) throws where T : Encodable {
            try encoder.encodeValue(value)
        }
    }
}

extension ThriftEncoder {
    private func encode<T, Key>(_ value: T, forKey key: Key) throws where T : Encodable, Key: CodingKey {
        self.codingPath.append(key)

        defer {
            self.codingPath.removeLast()
        }

        guard let binary = self.binary else {
            throw ThriftEncoderError.uninitializedEncodingData
        }
        guard let keyId = key.intValue else {
            throw ThriftEncoderError.codingKeyMissingIntValue(key: key)
        }

        let thriftType: ThriftType
        //Bools are encoded as part of the type
        if let boolValue = value as? Bool, specification == .compact {
            thriftType = boolValue ? .void : .bool
        } else {
            thriftType = try ThriftType.type(from: value)
        }

        binary.writeFieldBegin(fieldType: thriftType, fieldID: keyId, previousId: self.previousId)

        if (specification == .compact && thriftType != .bool && thriftType != .void) || specification != .compact {
            try encodeValue(value)
        }

        previousId = keyId
    }

    private func encodeValue<T>(_ value: T) throws where T : Encodable {
        guard let binary = self.binary else {
            throw ThriftEncoderError.uninitializedEncodingData
        }

        switch value {
        case let v as Bool:
            binary.write(v)
        case let v as Data:
            binary.write(v)
        case let v as Double:
            binary.write(v)
        case let v as UInt8:
            binary.write(v)
        case let v as Int16:
            binary.write(v)
        case let v as Int32:
            binary.write(v)
        case let v as Int64:
            binary.write(v)
        case let v as String:
            binary.write(v)
        case let v as ThriftEncodable:
            try v.thriftEncode(to: ThriftEncoder(binary: self.binary, specification: self.specification))
        default:
            throw ThriftEncoderError.unencodableType(type: value.self)
        }
    }
}

extension Dictionary : ThriftEncodable where Key : Encodable, Value : Encodable {
    public static func thriftType() -> ThriftType {
        return .map
    }

    public func thriftEncode(to encoder: ThriftEncoder) throws {
        var container = encoder.unkeyedContainer()

        let keyType = try ThriftType.type(from: Key.self)
        let valueType = try ThriftType.type(from: Value.self)

        encoder.binary?.writeMapMetadata(keyType: keyType, valueType: valueType, count: self.count)

        for item in self {
            try container.encode(item.key)
            try container.encode(item.value)
        }
    }
}

extension Set: ThriftEncodable where Element: Encodable {
    public static func thriftType() -> ThriftType {
        return .set
    }

    public func thriftEncode(to encoder: ThriftEncoder) throws {
        var container = encoder.unkeyedContainer()

        let keyType = try ThriftType.type(from: Element.self)
        encoder.binary?.writeSetMetadata(elementType: keyType, count: self.count)

        for item in self {
            try container.encode(item)
        }
    }
}

extension Array: ThriftEncodable where Element: Encodable {

    public static func thriftType() -> ThriftType {
        return .list
    }

    public func thriftEncode(to encoder: ThriftEncoder) throws {
        var container = encoder.unkeyedContainer()

        let arrayType = try ThriftType.type(from: Element.self)
        encoder.binary?.writeListMetadata(elementType: arrayType, count: self.count)
        for item in self {
            try container.encode(item)
        }
    }
}

extension PreencodedContainer: ThriftEncodable {

    public static func thriftType() throws -> ThriftType {
        return try ThriftType.type(from: T.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .encodedData(let encodedData):
            if let thriftContainer = container as? ThriftEncoder.UnkeyedContainer {
                thriftContainer.encoder.binary?.insert(data: encodedData)
            } else {
                try container.encode(encodedData)
            }
        case .value(let value):
            try container.encode(value)
        }
    }

    public func thriftEncode(to encoder: ThriftEncoder) throws {
        try self.encode(to: encoder)
    }
}
