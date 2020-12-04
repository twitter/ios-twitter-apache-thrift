/// A convenient shortcut for indicating something is both encodable and decodable.
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
    /// - Note: This function is not required to be implemented,
    /// however `func encode(to encoder: Encoder) throws` is required. It
    /// should be automatically created by the compiler.
    ///
    /// - Parameter encoder: The encoder to write data to.
    func thriftEncode(to encoder: ThriftEncoder) throws

    /// Provides an override point to all the protocol implementer to provide
    /// a different ThriftType such as for wrapping
    ///
    /// - Note: This function is not required to be implemented, defaults to struct
    ///
    /// - returns: The thrift type of the implementer
    static func thriftType() throws -> ThriftType

    /// Provides a validation step before encoding to insure fields are set
    /// to appropriate values provided by the implementer.
    ///
    /// - Note: This function is not required to be implemented, default is no validation
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
    /// - Note: This function is not required to be implemented,
    /// however `init(from decoder: Decoder)` is required. It should be automatically
    /// created by the compiler.
    ///
    /// - Parameter decoder: The decoder to read data from.
    init(fromThrift decoder: ThriftDecoder) throws
}
