// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0

//
// Autogenerated by Scrooge
//
// DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
//

import Foundation
import TwitterApacheThrift

public enum SomeEnum: Int32, ThriftCodable, Equatable {
  case AAA = 1
  case BBB = 2

  public func thriftEncode(to encoder: ThriftEncoder) throws {
     var container = encoder.unkeyedContainer()
     try container.encode(self.rawValue)
  }

  public init(fromThrift decoder: ThriftDecoder) throws {
    var container = try decoder.unkeyedContainer()
    let value = try container.decode(Int32.self)
    guard let enumValue = SomeEnum(rawValue: value) else {
      throw ThriftDecoderError.undecodableType(type: value.self)
    }
    self = enumValue
  }

  public static func thriftType() -> ThriftType {
    return .int32
  }
}
