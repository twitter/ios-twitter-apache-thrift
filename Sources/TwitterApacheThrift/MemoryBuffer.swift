// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  MemoryBuffer.swift
//  TwitterApacheThrift
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation

/// A class for reading a thrift data buffer.
class MemoryBuffer {

    /// The thrift data buffer
    var buffer: Data

    /// The offset of read cursor
    private var offset: Int = 0

    /// Initializes the class with a thrift buffer
    /// - Parameter buffer: The thrift buffer
    init(buffer: Data) {
        self.buffer = buffer
    }

    /// Reads data from the buffer with the given length
    /// - Parameter size: The amount of data to read in bytes
    /// - Throws: Throws `ThriftDecoderError.readBufferOverflow` if the size is greater then the amount of data remaining
    /// - Returns: The data from the buffer
    /// - Note: Calling this method will return new data from the buffer each call
    func read(size: Int) throws -> Data {
        if buffer.count - offset < size || offset < 0 {
            throw ThriftDecoderError.readBufferOverflow
        }
        let data = buffer.subdata(in: offset..<offset+size)
        offset += size
        return data
    }

    /// Moves the read cursor
    /// - Parameter offset: The amount of bytes to move the cursor. Positive for forward. Negative for backwards.
    func moveOffset(by offset: Int) {
        self.offset += offset
    }
}

/// A class for writing to a thrift data buffer.
class MutableMemoryBuffer: MemoryBuffer {

    /// Initializes the class with a empty buffer
    init() {
        super.init(buffer: Data())
    }

    /// Gets the entire buffer
    /// - Returns: Returns the current buffer
    func getBuffer() -> Data {
        return buffer
    }

    /// Appends bytes to the end of the buffer
    /// - Parameter bytes: The bytes to append
    func write(bytes: [UInt8]) {
        buffer.append(contentsOf: bytes)
    }

    /// Appends data to the end of the buffer
    /// - Parameter data: The data to append
    func write(data: Data) {
        buffer.append(data)
    }
}
