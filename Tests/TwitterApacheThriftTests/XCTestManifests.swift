// Copyright 2020 Twitter, Inc.
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ThriftBinaryTests.allTests),
        testCase(MutableThriftBinaryTests.allTests),
        testCase(ThriftDecoderTests.allTests),
        testCase(ThriftEncoderTests.allTests),
        testCase(PreencodedContainerTests.allTests)
    ]
}
#endif
