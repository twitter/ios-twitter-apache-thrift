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

class MemoryBuffer {
    fileprivate var buffer: Data
    private var offset: Int = 0

    init(buffer: Data) {
        self.buffer = buffer
    }

    func read(size: Int) throws -> Data {
        if buffer.count - offset < size || offset < 0 {
            throw ThriftDecoderError.readBufferOverflow
        }
        let data = buffer.subdata(in: offset..<offset+size)
        offset += size
        return data
    }

    func moveOffset(by offset: Int) {
        self.offset += offset
    }
}

class MutableMemoryBuffer: MemoryBuffer {

    init() {
        super.init(buffer: Data())
    }

    func getBuffer() -> Data {
        return buffer
    }

    func write(bytes: [UInt8]) {
        buffer.append(contentsOf: bytes)
    }

    func write(data: Data) {
        buffer.append(data)
    }
}
