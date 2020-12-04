//
//  BinaryProtocol.swift
//  TwitterApacheThrift
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation

class MutableBinaryProtocol: BinaryProtocol {

    private let writingBuffer = MutableMemoryBuffer()

    convenience init() {
        self.init(data: Data())
    }

    func getBuffer() -> Data {
        return writingBuffer.getBuffer()
    }

    func insert(data: Data) {
        writingBuffer.write(data: data)
    }

    func insert(bytes: [UInt8]) {
        writingBuffer.write(bytes: bytes)
    }
}

extension MutableBinaryProtocol {
    func write(_ value: Bool) {
        write(UInt8(value ? 1 : 0))
    }

    func write(_ data: Data) {
        write(Int32(data.count))
        insert(data: data)
    }

    func write(_ value: Int16) {
        var buffer = [UInt8](repeating: 0, count: 2)
        buffer[0] = UInt8(0xFF & (value >> 8))
        buffer[1] = UInt8(0xFF & value)
        insert(bytes: buffer)
    }

    func write(_ value: Int32) {
        var buffer = [UInt8](repeating: 0, count: 4)
        buffer[0] = UInt8(0xFF & (value >> 24))
        buffer[1] = UInt8(0xFF & (value >> 16))
        buffer[2] = UInt8(0xFF & (value >> 8))
        buffer[3] = UInt8(0xFF & value)
        insert(bytes: buffer)
    }

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

    func write(_ value: String) {
        write(Data(value.utf8))
    }

    func write(_ byte: UInt8) {
        insert(bytes: [byte])
    }

    func writeMapMetadata(keyType: ThriftType, valueType: ThriftType, count: Int) {
        self.write(keyType.rawValue)
        self.write(valueType.rawValue)
        self.write(Int32(count))
    }

    func writeSetMetadata(elementType: ThriftType, count: Int) {
      self.write(elementType.rawValue)
      self.write(Int32(count))
    }

    func writeListMetadata(elementType: ThriftType, count: Int) {
      self.write(elementType.rawValue)
      self.write(Int32(count))
    }

    func writeFieldBegin(fieldType: ThriftType, fieldID: Int) {
      self.write(fieldType.rawValue)
      self.write(Int16(fieldID))
    }

    func writeFieldStop() {
        self.write(ThriftType.stop.rawValue)
    }
}
