// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  MutableThriftBinary.swift
//  TwitterApacheThrift
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation

/// A class for writing values to thift data
class MutableThriftBinary: ThriftBinary {

    /// The buffer for writing
    private let writingBuffer = MutableMemoryBuffer()

    /// Creates a new instance with a empty buffer
    convenience init() {
        self.init(data: Data())
    }

    /// Gets the buffer as data
    /// - Returns: The data of the buffer
    func getBuffer() -> Data {
        return writingBuffer.getBuffer()
    }

    /// Inserts data into the buffer
    /// - Parameter data: The data to insert
    func insert(data: Data) {
        writingBuffer.write(data: data)
    }

    fileprivate func insert(bytes: [UInt8]) {
        writingBuffer.write(bytes: bytes)
    }
}

extension MutableThriftBinary {

    /// Writes a bool to the buffer
    /// - Parameter value: The value to write
    func write(_ value: Bool) {
        write(UInt8(value ? 1 : 0))
    }

    /// Writes a data to the buffer
    /// - Parameter value: The value to write
    func write(_ data: Data) {
        write(Int32(data.count))
        insert(data: data)
    }

    /// Writes a Int16 to the buffer
    /// - Parameter value: The value to write
    func write(_ value: Int16) {
        var buffer = [UInt8](repeating: 0, count: 2)
        buffer[0] = UInt8(0xFF & (value >> 8))
        buffer[1] = UInt8(0xFF & value)
        insert(bytes: buffer)
    }

    /// Writes a Int32 to the buffer
    /// - Parameter value: The value to write
    func write(_ value: Int32) {
        var buffer = [UInt8](repeating: 0, count: 4)
        buffer[0] = UInt8(0xFF & (value >> 24))
        buffer[1] = UInt8(0xFF & (value >> 16))
        buffer[2] = UInt8(0xFF & (value >> 8))
        buffer[3] = UInt8(0xFF & value)
        insert(bytes: buffer)
    }

    /// Writes a Int64 to the buffer
    /// - Parameter value: The value to write
    func write(_ value: Int64) {
        var buffer = [UInt8](repeating: 0, count: 8)
        buffer[0] = UInt8(0xFF & (value >> 56))
        buffer[1] = UInt8(0xFF & (value >> 48))
        buffer[2] = UInt8(0xFF & (value >> 40))
        buffer[3] = UInt8(0xFF & (value >> 32))
        buffer[4] = UInt8(0xFF & (value >> 24))
        buffer[5] = UInt8(0xFF & (value >> 16))
        buffer[6] = UInt8(0xFF & (value >> 8))
        buffer[7] = UInt8(0xFF & value)
        insert(bytes: buffer)
    }

    /// Writes a Double to the buffer
    /// - Parameter value: The value to write
    func write(_ value: Double) {
        let bitValue = value.bitPattern
        var buffer = [UInt8](repeating: 0, count: 8)
        buffer[0] = UInt8(0xFF & (bitValue >> 56))
        buffer[1] = UInt8(0xFF & (bitValue >> 48))
        buffer[2] = UInt8(0xFF & (bitValue >> 40))
        buffer[3] = UInt8(0xFF & (bitValue >> 32))
        buffer[4] = UInt8(0xFF & (bitValue >> 24))
        buffer[5] = UInt8(0xFF & (bitValue >> 16))
        buffer[6] = UInt8(0xFF & (bitValue >> 8))
        buffer[7] = UInt8(0xFF & bitValue)
        insert(bytes: buffer)
    }

    /// Writes a string as UTF8 data to the buffer
    /// - Parameter value: The value to write
    func write(_ value: String) {
        write(Data(value.utf8))
    }

    /// Writes a byte (UInt8) to the buffer
    /// - Parameter value: The value to write
    func write(_ byte: UInt8) {
        insert(bytes: [byte])
    }


    /// Writes the a map (aka Dictionary) metadata to the buffer
    /// - Parameters:
    ///   - keyType: The thrift type of the key
    ///   - valueType: The thrift type of the value
    ///   - count: The amount of values
    func writeMapMetadata(keyType: ThriftType, valueType: ThriftType, count: Int) {
        self.write(keyType.rawValue)
        self.write(valueType.rawValue)
        self.write(Int32(count))
    }

    /// Writes the a set metadata to the buffer
    /// - Parameters:
    ///   - elementType: The thrift type of values
    ///   - count: The amount of values
    func writeSetMetadata(elementType: ThriftType, count: Int) {
      self.write(elementType.rawValue)
      self.write(Int32(count))
    }

    /// Writes the a list (aka Array) metadata to the buffer
    /// - Parameters:
    ///   - elementType: The thrift type of values
    ///   - count: The amount of values
    func writeListMetadata(elementType: ThriftType, count: Int) {
      self.write(elementType.rawValue)
      self.write(Int32(count))
    }

    /// Writes field information.
    /// - Parameters:
    ///   - fieldType: The field type
    ///   - fieldID: The identifier of the field
    func writeFieldBegin(fieldType: ThriftType, fieldID: Int) {
      self.write(fieldType.rawValue)
      self.write(Int16(fieldID))
    }

    /// Writes the a stop type to the buffer. Used at the end of structures.
    func writeFieldStop() {
        self.write(ThriftType.stop.rawValue)
    }
}
