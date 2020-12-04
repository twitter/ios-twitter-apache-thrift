//
//  BinaryProtocol.swift
//  TwitterApacheThrift
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation

class BinaryProtocol {

    private let readingBuffer: MemoryBuffer

    init(data: Data) {
        readingBuffer = MemoryBuffer(buffer: data)
    }

    func moveReadCursorBackAfterType() {
        readingBuffer.moveOffset(by: -(UInt8.bitWidth / 8))
    }

    func moveReadCursorBackAfterTypeAndFieldID() {
        moveReadCursorBackAfterType()
        readingBuffer.moveOffset(by: -(Int16.bitWidth / 8))
    }
}

extension BinaryProtocol {

    func readUInt64() throws -> UInt64 {
        let i64rd = try readingBuffer.read(size: 8)

        let byte56 = UInt64(i64rd[0]) << 56
        let byte48 = UInt64(i64rd[1]) << 48
        let byte40 = UInt64(i64rd[2]) << 40
        let byte32 = UInt64(i64rd[3]) << 32
        let byte24 = UInt64(i64rd[4]) << 24
        let byte16 = UInt64(i64rd[5]) << 16
        let byte8 = UInt64(i64rd[6]) << 8
        let byte0 = UInt64(i64rd[7]) << 0

        return (byte56 | byte48 | byte40 | byte32 | byte24 | byte16 | byte8 | byte0)
    }

    func readInt64() throws -> Int64 {
        let u64 = try readUInt64()
        return Int64(bitPattern: u64)
    }

    func readInt32() throws -> Int32 {
        let i32rd = try readingBuffer.read(size: 4)

        let byte24 = Int32(i32rd[0]) << 24
        let byte16 = Int32(i32rd[1]) << 16
        let byte8 = Int32(i32rd[2]) << 8
        let byte0 = Int32(i32rd[3]) << 0

        return (byte24 | byte16 | byte8 | byte0)
    }

    func readInt16() throws -> Int16 {
        let i16rd = try readingBuffer.read(size: 2)

        let byte8 = Int16(i16rd[0]) << 8
        let byte0 = Int16(i16rd[1]) << 0

        return byte8 | byte0
    }

    func readDouble() throws -> Double {
        let ui64 = try readUInt64()
        return Double(bitPattern: ui64)
    }

    func readBinary() throws -> Data {
        let size = try readInt32()
        return try readingBuffer.read(size: Int(size))
    }

    func readString() throws -> String {
        let size = try readInt32()
        let stringData = try readingBuffer.read(size: Int(size))

        guard let string = String(bytes: stringData, encoding: .utf8) else {
            throw ThriftDecoderError.nonUTF8StringData(stringData)
        }

        return string
    }

    func readBool() throws -> Bool {
        return try readByte() == 1
    }

    func readByte() throws -> UInt8 {
        return try readingBuffer.read(size: 1)[0]
    }

    func readMapMetadata() throws -> (keyType: ThriftType, valueType: ThriftType, size: Int) {
        let keyType = try readByte()
        let valueType = try readByte()
        let size = try readInt32()
        return (try ThriftType(coreValue: keyType), try ThriftType(coreValue: valueType), Int(size))
    }

    func readSetMetadata() throws -> (elementType: ThriftType, size: Int) {
        let type = try readByte()
        let size = try readInt32()
        return (try ThriftType(coreValue: type), Int(size))
    }

    func readListMetadata() throws -> (elementType: ThriftType, size: Int) {
        let type = try readByte()
        let size = try readInt32()
        return (try ThriftType(coreValue: type), Int(size))
    }

    func readFieldMetadata() throws -> (type: ThriftType, id: Int?) {
        let type = try ThriftType(coreValue: try readByte())
        if (type != .stop) {
            let id = try self.readInt16()
            return (type, Int(id))
        }
        return (type, nil)
    }
}
