# Thrift overview

Thrift is typed binary. It allows data to be sent over a network with the smallest amount of formatting possible. Please note class and struct are going to be used interchangeably. The underlying type is dependent on the language and not thrift.

Thrift models support Boolean, Byte, Double, Int16, Int32, Int64, String, Structures, Map, Set, and List. They also support optional values. They are defined this format.

```thrift
struct Tweet {
  1: string user_handle
  2: string tweet_text
  3: optional int64 like_count
}
```

This defines a struct named Tweet with three properties, `user_handle`, `tweet_text`, and `like_count`. `user_handle` and `tweet_text` are both strings and `like_count` is an optional Int64. Below is the swift equivalent.  The numeric prefix on each line is use to identify the field when decoding and encoding.

```swift
struct Tweet {
  let userHandle: String
  let tweetText: String
  let likeCount: Int64?
}
```

This thrift struct has this format when encoded as data. Note: There is not any extra padding after each value. Spacing is used here for illustrative purposes.  

```
|--------------------------------------------------|
|Struct type                                       |
|Field Type|Field Id|String data length|String data|
|Field Type|Field Id|String data length|String data|
|Field Type|Field Id|Int64                         |
|Struct Stop                                       |
|--------------------------------------------------|
```

#### Example

Say we have this tweet
```javascript
{
  "user_handle" : "jack",
  "tweet_text" : "just setting up my twttr",
  "like_count" : 167454
}
```
The thrift equivalent would the following data.

Note: the strings are displayed here for convenience. They would be encoded as UTF8 data.
```
|-----------------------------------------------------------------|
|12|11|1|4|"jack"|11|2|24|"just setting up my twttr"|10|3|167454|0|
|-----------------------------------------------------------------|
```

## Thrift Types

All thrift types map to a single byte mapping.

Type | Thrift type | Size (bytes) | Description
---- | ---------- | ------------ | -----------
Bool | 2 | 1 | A boolean
Byte | 3 | 1 | A single byte
Double | 4 | 8 | A double
Int16 | 6 | 2 | A Int16
Int32 | 8 | 4 | A Int32
Int64 | 10 | 8 | A Int64
String | 11 | 4 + string length | The length of a string and utf8 data
Struct | 12 | varies | A structure of fields
Map | 13 | 6 + keys + values | The type of the key and value. The amount of elements.
Set | 14 | 5 + values | The type of the value. The amount of elements.
List | 15 | 5 + values | The type of the value. the amount of elements.

A Data type is also possible using the string thrift type and relying on encoding/decoding library.

## Code generation
The thrift model classes can be generated automatically using [scrooge](https://github.com/twitter/scrooge). Follow this [page](https://twitter.github.io/scrooge/CommandLine.html#scrooge-generator) to get scrooge working.

The following assumes you are generating Swift classes. Other languages please refer to the scrooge docs.

Say we have this file thrift file called `tweet.thrift`

```thrift
namespace java com.twitter.tweetservice.thriftjava

struct Tweet {
  1: string user_handle
  2: string tweet_text
  3: optional int64 like_count
}
```

We will need to first add a namespace for swift by adding the following line below the java namespace. The namespace decides what the swift package will be called. Note: Swift does not support java style name spacing.

```
#@namespace swift Tweets
```

We will then run the following command to actually generate the swift package in the current directory.

```bash
$ ./sbt 'scrooge-generator/runMain com.twitter.scrooge.Main -l swift tweet.thift'
```

The generator can also generate classes instead of structs by passing the `--language-flag swift-classes` argument.

The generator can also generate Objective-C compatible classes by passing the `--language-flag 'swift-objc prefix'` argument. Prefix will be the Objective-C class prefix. Note the quotes are required when using this argument.
