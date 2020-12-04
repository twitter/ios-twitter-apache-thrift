namespace java com.twitter.thrift.encoding
#@namespace scala com.twitter.thrift.encoding.thriftscala
namespace swift ThriftEncoding

struct FoundationThriftStruct {
  1: required bool boolValue
  2: required double doubleValue
  3: required i16 int16Value
  4: required i32 int32Value
  5: required i64 int64Value
  6: required string stringValue
}

struct OptionalThriftStruct {
  1: optional i16 int16Value
}

struct SubobjectThriftStruct {
  1: optional OptionalThriftStruct value
  2: required i16 intValue
}

struct CollectiontThriftStruct {
  1: optional list<double> arrays
  2: optional map<string, string> maps
  3: optional set<i32> sets
}

struct UnionClassA {
  1: required string someString
}
struct UnionClassB {
  1: required i64 someInt
}
union MyUnion {
  1: UnionClassA unionClassA
  2: UnionClassB unionClassB
}
struct UnionStruct {
  1: required MyUnion someUnion
}

enum SomeEnum {
  AAA = 1,
  BBB = 2
}

struct EnumStruct {
  1: required SomeEnum enumValue
}
