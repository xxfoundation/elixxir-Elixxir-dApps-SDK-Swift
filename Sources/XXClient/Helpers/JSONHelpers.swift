import Foundation

/// Replaces all numbers at provided key with string equivalents
///
/// Example input:
/// {
///   "key": 123,
///   "object": {
///     "hello": "world",
///     "key": 321
///   }
/// }
///
/// Example output:
/// {
///   "key": "123",
///   "object": {
///     "hello": "world",
///     "key": "321"
///   }
/// }
///
/// - Parameters:
///   - input: JSON data
///   - key: the key which values should be converted
/// - Returns: JSON data
func convertJsonNumberToString(
  in input: Data,
  at key: String
) -> Data {
  guard var string = String(data: input, encoding: .utf8) else {
    return input
  }
  string = string.replacingOccurrences(
    of: #""\#(key)"( *):( *)([0-9]+)( *)(,*)"#,
    with: #""\#(key)"$1:$2"$3"$4$5"#,
    options: [.regularExpression]
  )
  guard let output = string.data(using: .utf8) else {
    return input
  }
  return output
}

/// Replaces all strings at provided key with number equivalents
///
/// Example input:
/// {
///   "key": "123",
///   "object": {
///     "hello": "world",
///     "key": "321"
///   }
/// }
///
/// Example output:
/// {
///   "key": 123,
///   "object": {
///     "hello": "world",
///     "key": 321
///   }
/// }
///
/// - Parameters:
///   - input: JSON data
///   - key: the key which values should be converted
/// - Returns: JSON data
func convertJsonStringToNumber(
  in input: Data,
  at key: String
) -> Data {
  guard var string = String(data: input, encoding: .utf8) else {
    return input
  }
  string = string.replacingOccurrences(
    of: #""\#(key)"( *):( *)"([0-9]+)"( *)(,*)"#,
    with: #""\#(key)"$1:$2$3$4$5"#,
    options: [.regularExpression]
  )
  guard let output = string.data(using: .utf8) else {
    return input
  }
  return output
}
