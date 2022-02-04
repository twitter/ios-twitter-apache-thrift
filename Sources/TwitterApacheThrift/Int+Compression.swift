// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  Int+Compression.swift
//  TwitterApacheThrift
//
//  Created on 9/24/21.
//  Copyright © 2021 Twitter, Inc. All rights reserved.
//

import Foundation

extension Int16 {
    init(zigZag value: Int16) {
        self = Int16((value >> 1) ^ -(value & 1))
    }
}
extension Int {
    var zigZag: Int {
        if self.bitWidth > 32 {
            return Int((Int64(self) << 1) ^ (Int64(self) >> 63))
        }
        return (self << 1) ^ (self >> 31)
    }
    init(zigZag value: Int64) {
        self = Int((value >> 1) ^ -(value & 1))
    }
    init(zigZag value: Int32) {
        self = Int((value >> 1) ^ -(value & 1))
    }
}

extension Int32 {
    var zigZag: Int32 {
        return (self << 1) ^ (self >> 31)
    }
    init(zigZag value: Int32) {
        self = (value >> 1) ^ -(value & 1)
    }
}

extension Int64 {
    var zigZag: Int64 {
        return (self << 1) ^ (self >> 63)
    }
    init(zigZag value: UInt64) {
        self = Int64(value >> 1) ^ (-Int64(value & 1))
    }
}

extension UInt64 {
    var zigZag: Int64 {
        return (Int64(self) << 1) ^ (Int64(self) >> 63)
    }
    init(zigZag value: Int64) {
        self = UInt64((value >> 1) ^ -(value & 1))
    }
}
