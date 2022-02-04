// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0//
//
//  MutableThriftCompactBinary.swift
//  TwitterApacheThrift
//
//  Created on 9/24/21.
//  Copyright © 2021 Twitter. All rights reserved.

import CoreFoundation
import Foundation

class MutableThriftCompactBinary: MutableThriftBinary {
    override func write(_ value: Int16) {
        write(Int32(value))
    }

    override func write(_ value: Int32) {
        let bytes = encodedUnsignedLEB(value: value.zigZag)
        insert(data: bytes)
    }

    override func write(_ value: Int64) {
        let bytes = encodedUnsignedLEB(value: value.zigZag)
        insert(data: bytes)
    }

    override func write(_ value: Double) {
        var bits = CFSwapInt64HostToLittle(value.bitPattern)
        let buffer = withUnsafePointer(to: &bits) {
            return Data(bytes: UnsafePointer<UInt8>(OpaquePointer($0)), count: MemoryLayout<UInt64>.size)
        }
        insert(data: buffer)
    }

    override func write(_ data: Data) {
        let lengthBytes = encodedUnsignedLEB(value: Int32(data.count))
        insert(data: lengthBytes)
        insert(data: data)
    }

    override func writeFieldBegin(fieldType: ThriftType, fieldID: Int, previousId: Int) {
        // check if we can use delta encoding for the field id
        let diff = fieldID - previousId
        if (fieldID > previousId) && (diff <= 15) {
            // Write them together
            write((UInt8(fieldID - previousId) << 4) | fieldType.compactValue)

        } else {
            // Write them separate
            write(fieldType.compactValue)
            super.write(Int16(fieldID.zigZag))
        }
    }

    override func writeListMetadata(elementType: ThriftType, count: Int) {
        if count < 15 {
            write((UInt8(count) << 4) | elementType.compactValue)
        } else {
            write(0xF0 | elementType.compactValue)
            insert(data: encodedUnsignedLEB(value: count))
        }
    }

    override func writeMapMetadata(keyType: ThriftType, valueType: ThriftType, count: Int) {
        if count == 0 {
            write(UInt8(0))
            return
        }
        insert(data: encodedUnsignedLEB(value: count))
        write((keyType.compactValue << 4) | valueType.compactValue)
    }

    func encodedUnsignedLEB<T: BinaryInteger>(value: T) -> Data {
        var value = value
        var count = 0
        var data = Data()
        data.reserveCapacity(10)
        repeat {
            var byte = UInt8(value & 0x7F)
            value = value >> 7
            if value != 0 {
                byte |= 0x80
            }
            data.append(byte)
            count += 1
        } while value != 0

        return data
    }
}
