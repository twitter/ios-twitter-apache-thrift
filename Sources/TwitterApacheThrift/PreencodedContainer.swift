// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  PreencodedContainer.swift
//  TwitterApacheThrift
//
//  Created on 7/1/20.
//  Copyright © 2020 Twitter. All rights reserved.
//

import Foundation

/// A container allowing pre-encoded data to be placed in the encoding
/// buffer instead of a value
///
/// For example the first struct would take .encodedData([0, 57]) and
/// this would allow the second struct to be decoded with a value of 57
///
///     struct SomeStruct: ThriftCodable {
///         let value: PreencodedContainer<Int16>
///     }
///
///     struct AnotherStruct: ThriftCodable {
///         let value: Int16
///     }
///
public enum PreencodedContainer<T: Codable> {
    /// Preencoded data
    case encodedData(Data)
    /// A value that needs to be encoded/decoded
    case value(T)
}

extension PreencodedContainer: Equatable where T: Equatable {}
extension PreencodedContainer: Hashable where T: Hashable {}
