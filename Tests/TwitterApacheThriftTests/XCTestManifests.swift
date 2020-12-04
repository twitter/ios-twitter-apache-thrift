import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BinaryProtocolTests.allTests),
        testCase(MutableBinaryProtocolTests.allTests),
        testCase(ThriftDecoderTests.allTests),
        testCase(ThriftEncoderTests.allTests)
    ]
}
#endif
