# Twitter Apache Thrift

Swift’s modern model constructs allow a 1:1 mapping to Thrift. Swift with Thrift 
allows the client and backend to use a common model for representing data.

## Getting Started

### Installing

#### Swift Package Manager
Add the following to your Package.swift file

```
.package(name: "TwitterApacheThrift", url: "https://github.com/twitter/ios-twitter-apache-thrift", .upToNextMajor(from: "1.0.0"))
```

#### Carthage
Add the following to your Cartfile

```
github "twitter/ios-twitter-apache-thrift"
```

### Usage

#### Encoding and Decoding
The thrift encoder and decoder use the Encoder and Decoder protocols. Conforming
to these protocols allows the compiler to autogenerate the codable methods. This 
reduces the potential for errors; they also receive JSON support for free. The 
implementation of these models deviate from the official thrift specification. The 
official specification was designed for languages without automatic encoding and 
decoding. Output and input binary will be up to the official thrift specification. There 
is ThriftEncodable and ThriftDecodable protocols that confirm the respective swift 
protocols. There is also a typealias combining them for convenience.
 ```
public typealias ThriftCodable = ThriftDecodable & ThriftEncodable

/// A protocol for types which can be encoded from thrift.
public protocol ThriftEncodable: Encodable {
    /// Encodes this value into the given thrift encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// This function is not required to be implemented,
    /// however `func encode(to encoder: Encoder) throws` is required
    ///
    /// - Parameter encoder: The encoder to write data to.
    func thriftEncode(to encoder: ThriftEncoder) throws

    /// Provides an override point to all the protocol implementer to provide
    /// a different ThriftType such as for wrapping
    ///
    /// This function is not required to be implemented, defaults to struct
    ///
    /// - returns: The thrift type of the implementer
    static func thriftType() -> ThriftType

    /// Provides a validation step before encoding to insure fields are set
    /// to appropriate values provided by the implementer.
    ///
    /// This function is not required to be implemented, default is no validation
    ///
    /// - throws: `ThriftEncoderError.validationFailure()` if field validation fails
    func validate() throws
}

/// A protocol for types which can be decoded from thrift.
public protocol ThriftDecodable: Decodable {

    /// Creates a new instance by decoding from the given thrift decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// This function is not required to be implemented,
    /// however `init(from decoder: Decoder)` is required
    ///
    /// - Parameter decoder: The decoder to read data from.
    init(fromThrift decoder: ThriftDecoder) throws
}
```
Encoding and decoding use the ThriftEncoder and ThriftDecoder. The usage 
will be like the following.
```
//Encoder
let thrift = SomeThriftEncodable()
let encoder = ThriftEncoder()
let data = try thriftEncoder.encode(thrift)

//Decoder
let decoder = ThriftDecoder()
let thriftObject = try decoder.decode(SomeThriftEncodable.self, from: thriftData)
```
#### Type Mapping
Mappings between foundation Swift types to thrift types handled by the library. 
The following table outlines how the swift types map the thrift type.

Note: 
    Data is a special case. The format for data is the same as string so they unified 
    and rely on the swift type for encoding and decoding.

| Swift type | Thrift Type (UInt8 Value) |
| ----------- | -------------------------- |
| Bool | Bool (2) |
| UInt8 | Byte (3) |
| Double | Double (4) |
| Int16 | Int16 (6) |
| Int32 | Int32 (8) |
| Int64 | Int64 (10) |
| Data | String (11) |
| String | String (11) | (UTF8 data) |
| SomeStruct: ThriftCodable | Struct
| Dictionary<ThriftCodable, ThriftCodable> | Map<ThriftCodable, ThriftCodable> (13) |
| Set<ThriftCodable> | Set<ThriftCodable> (14) |
| Array<ThriftCodable> | List<ThriftCodable> (15) |


For supported collection types, we have extensions to support the ThriftCodable 
protocol. Thrift structs map to Swift structs. Swift structs are value types. These
prevent misuse of the models and unexpected behavior. Structs add field ids as 
coding keys on the structs, shown here:
```
/// ClassA.thrift
struct ClassA {
  1: required string someString
}

/// ClassA.swift
public struct ClassA: ThriftCodable {
  let someString: String
  enum CodingKeys: Int, CodingKey {
    case someString = 1
  }
}
```

Thrift enums will be a Swift Enum with a Int32 raw value per the thrift specification. 
Unions will also be created as enums and will also contain coding keys for the field
ids. Unions are mutually exclusive types, making them as enums is ideal to prevent 
misuse of the model. Here is an example:
```
/// MyUnion.thrift
union MyUnion {
  1: UnionClassA unionCase1
  2: UnionClassB unionCase2
}

/// MyUnion.swift
public enum MyUnion: ThriftCodable {
  case unionCase1(UnionClassA)
  case unionCase2(UnionClassB)

  enum CodingKeys: Int, CodingKey {
    case unionClassA = 1
    case unionClassB = 2
  }
}
```

## Support

Create a [new issue](https://github.com/twitter/ios-twitter-apache-thrift/issues/new) on GitHub.

## License

Copyright 2020 Twitter, Inc.

Licensed under the Apache License, Version 2.0: https://www.apache.org/licenses/LICENSE-2.0

## Resources

[Thrift Specification](https://thrift.apache.org/static/files/thrift-20070401.pdf)
