import Foundation

public struct Parser<A> {
   public typealias ParseResult = (result: A, remaining: String)
   private let parse: (String) -> [ParseResult]

   public init(_ parse: @escaping (String) -> [ParseResult]) {
      self.parse = parse
   }

   public init(pure value: A) {
      self = Parser { [(result: value, remaining: $0)] }
   }

   public func runParser(on input: String) -> [ParseResult] {
      return self.parse(input)
   }

   public func map<B>(_ transform: @escaping (A) -> B) -> Parser<B> {
      return Parser<B> { s in
         let a = self.parse(s)
         return a.map { (result: transform($0.result), remaining: $0.remaining) }
      }
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
