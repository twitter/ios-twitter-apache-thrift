// Copyright 2021 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0
//
//  ThriftSpecification.swift
//  TwitterApacheThrift
//
//  Created on 9/30/21.
//  Copyright © 2021 Twitter, Inc. All rights reserved.
//

import Foundation

/// The specification to be used for encoding and decoding
public enum ThriftSpecification {
    /// The standard specification
    /// https://thrift.apache.org/static/files/thrift-20070401.pdf
    case standard
    /// The compact specification
    /// https://github.com/apache/thrift/blob/master/doc/specs/thrift-compact-protocol.md
    case compact
}
