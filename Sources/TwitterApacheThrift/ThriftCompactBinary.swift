// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftBinary.swift
//  TwitterApacheThrift
//
//  Created on 9/23/21.
//  Copyright © 2021 Twitter. All rights reserved.
//

import CoreFoundation
import Foundation

/// A class for reading values from thrift data
class ThriftCompactBinary: ThriftBinary {

    override func readStruct(index: Int?) throws -> ThriftStruct {
        var fields: [Int: ThriftValue] = [:]
        var nextField = try readFieldMetadata(previousId: 0)
        while nextField.type != .stop, let id = nextField.id {
            let value = try readValue(index: id, type: nextField.type, isCollection: false)
            fields[id] = ThriftValue(index: id, type: nextField.type, data: value)
            nextField = try readFieldMetadata(previousId: id)
        }
        return ThriftStruct(index: index, fields: fields)
    }

    override func readValue(index: Int?, type: ThriftType, isCollection: Bool = false) throws -> ThriftObject {
        switch type {
        case .void: //Void is boolean true in compact thrift when used as a field.
            return isCollection ? .stop : .data(Data([1]))
        case .bool: //bool is boolean false in compact thrift when used as a field but is one byte when used in a collection
            return isCollection ? .data(try Data([readByte()])) : .data(Data([0]))
        case .byte:
            return .data(try Data([readByte()]))
        case .double:
            return .data(try readingBuffer.read(size: 8))
        case .int64, .int16, .int32:
            return .data(try Data(unsignedLEBBytes()))
        case .string:
            return .data(try readBinary())
        case .structure:
            return .struct(try readStruct(index: index))
        case .map:
            var values: [ThriftKeyedCollection.Value] = []
            let metadata = try readMapMetadata()
            for _ in 0..<metadata.size {
                let key = try readValue(index: nil, type: metadata.keyType, isCollection: true)
                let value = try readValue(index: nil, type: metadata.valueType, isCollection: true)
                values.append(.init(key: key, value: value))
            }
            return .keyedCollection(ThriftKeyedCollection(index: index,
                                                          count: metadata.size,
                                                          keyType:metadata.keyType,
                                                          elementType: metadata.valueType,
                                                          value: values))
        case .list, .set:
            var values: [ThriftObject] = []
            let metadata = try readListMetadata()
            for _ in 0..<metadata.size {
                let value = try readValue(index: nil, type: metadata.elementType, isCollection: true)
                values.append(value)
            }
            return .unkeyedCollection(ThriftUnkeyedCollection(index: index, count: metadata.size, elementType: type, value: values))
        default:
            return .stop
        }

    }

    /// Reads a the field metadata from the thrift. This type is equivalent to a Dictionary
    /// - Throws: ThriftDecoderError.readBufferOverflow when trying to read outside the range of data
    /// - Returns: The field thrift type. The thrift id if it is not a ThriftType.stop.
    func readFieldMetadata(previousId: Int) throws -> (type: ThriftType, id: Int?) {
        let binary = try readByte()
        if binary == 0 {
            return (.stop, nil)
        }
        let fieldIdDelta = UInt8((binary & 0xF0) >> 4)
        let fieldType = UInt8(binary & 0x0F)
        let type = try ThriftType(compactValue: fieldType)

        if fieldIdDelta == 0 {
            let fieldId = try Int16(zigZag: super.readInt16())
            return (type, Int(fieldId))
        }

        return (type, Int(fieldIdDelta) + previousId)
    }

    override func readDouble() throws -> Double {
        let buffer = try readingBuffer.read(size: 8)
        let i64: UInt64 = buffer.withUnsafeBytes { $0.load(as: UInt64.self) }
        let value = CFSwapInt64LittleToHost(i64)
        return Double(bitPattern: value)
    }

    /// Reads the next UInt64 from the thrift
    /// - Throws: ThriftDecoderError.readBufferOverflow when trying to read outside the range of data
    /// - Returns: The value decoded from the thrift
    override func readUInt64() throws -> UInt64 {
        let value: Int64 = decodeUnsignedLEB(from: readingBuffer.buffer)
        return CFSwapInt64LittleToHost(UInt64(zigZag: value))
    }

    /// Reads the next Int64 from the thrift
    /// - Throws: ThriftDecoderError.readBufferOverflow when trying to read outside the range of data
    /// - Returns: The value decoded from the thrift
    override func readInt64() throws -> Int64 {
        let value: UInt64 = decodeUnsignedLEB(from: readingBuffer.buffer)
        return (Int64(zigZag: value))
    }

    /// Reads the next Int32 from the thrift
    /// - Throws: ThriftDecoderError.readBufferOverflow when trying to read outside the range of data
    /// - Returns: The value decoded from the thrift
    override func readInt32() throws -> Int32 {
        let value: Int32 = decodeUnsignedLEB(from: readingBuffer.buffer)
        return (Int32(zigZag: value))
    }

    /// Reads the next Int16 from the thrift
    /// - Throws: ThriftDecoderError.readBufferOverflow when trying to read outside the range of data
    /// - Returns: The value decoded from the thrift
    override func readInt16() throws -> Int16 {
        let value = try readInt32()
        return Int16(value)
    }

    /// Reads the next data from the thrift. The length of data is based on the next 4 bytes.
    /// - Throws: ThriftDecoderError.readBufferOverflow when trying to read outside the range of data
    /// - Returns: The value decoded from the thrift
    override func readBinary() throws -> Data {
        let bytes = try unsignedLEBBytes()
        let size: Int32 = decodeUnsignedLEB(from: bytes)
        return try readingBuffer.read(size: Int(size))
    }

    /// Reads a map object metadata from the thrift. This type is equivalent to a Dictionary
    /// - Throws: ThriftDecoderError.readBufferOverflow when trying to read outside the range of data
    /// - Returns: The type of key as a thrift type. The type of values as a thrift type. The amount of elements.
    override func readMapMetadata() throws -> (keyType: ThriftType, valueType: ThriftType, size: Int) {
        let binary = try readByte()
        if binary == 0 {
            //Empty map
            return (.stop, .stop, 0)
        }

        let sizeBytes = try unsignedLEBBytes(startingByte: binary)
        let size: Int32 = decodeUnsignedLEB(from: sizeBytes)

        let types = try readByte()
        let keyType = UInt8(types >> 4) & 0x0F
        let elementType = UInt8(types & 0x0F)

        return (try ThriftType(compactValue: keyType), try ThriftType(compactValue: elementType), Int(size))
    }

    /// Reads a list object metadata from the thrift. This type is equivalent to a Array
    /// - Throws: ThriftDecoderError.readBufferOverflow when trying to read outside the range of data
    /// - Returns: The type of values as a thrift type. The amount of elements.
    override func readListMetadata() throws -> (elementType: ThriftType, size: Int) {
        let binary = try readByte()
        let compactSize = UInt8(binary >> 4) & 0x0F
        let elementType = UInt8(binary & 0x0F)
        let type = try ThriftType(compactValue: elementType)

        //If size is 15 (1111) then it uses a different format
        if compactSize == 0b1111 {
            let sizeBytes = try unsignedLEBBytes()
            let size: Int32 = decodeUnsignedLEB(from: sizeBytes)
            return (type, Int(size))
        }

        return (type, Int(compactSize))
    }

    func unsignedLEBBytes(startingByte: UInt8? = nil) throws -> Data {
        var bytes: [UInt8] = []
        while true {
            let byte: UInt8
            if let firstByte = startingByte, bytes.isEmpty {
                byte = firstByte
            } else {
                byte = try readByte()
            }

            bytes.append(byte)
            if (byte & 0x80) == 0 {
                break
            }
        }
        return Data(bytes)
    }

    func decodeUnsignedLEB<T: BinaryInteger>(from bytes: Data) -> T {
        var result: T = 0
        var shift: T = 0

        for byte in bytes {
            result |= ((T(byte) & 0x7F) << shift)
            shift += 7
        }
        return result
    }
}
