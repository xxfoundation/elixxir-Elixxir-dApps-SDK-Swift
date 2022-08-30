import Foundation

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
