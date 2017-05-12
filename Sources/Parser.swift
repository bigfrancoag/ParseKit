import Foundation

public struct Parser<A> {
   public typealias ParseResult = (result: A, remaining: String)
   private let parse: (String) -> [(result: A, remaining: String)]

   public init(_ parse: @escaping (String) -> [(result: A, remaining: String)]) {
      self.parse = parse
   }

   public init(pure value: A) {
      self = Parser { [(result: value, remaining: $0)] }
   }

   public func runParser(on input: String) -> [(result: A, remaining: String)] {
      return self.parse(input)
   }

   public static func item() -> Parser<String> {
      return Parser<String> { s in
         if s.isEmpty {
            return []
         }

         let tailIndex = s.index(after: s.startIndex)

         let start = s.substring(to: tailIndex)
         let end = s.substring(from: tailIndex)
         return [(result: start, remaining: end)]
      }
   }
}
