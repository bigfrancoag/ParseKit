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

   public init() {
      self = Parser { _ in [] }
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

   public func flatMap<B>(_ transform: @escaping (A) -> Parser<B>) -> Parser<B> {
      return Parser<B> { s in
         let a = self.parse(s)
         return a.flatMap { return transform($0.result).parse($0.remaining) }
      }
   }

   public func combine(_ parser: Parser<A>) -> Parser<A> {
      return Parser { s in
         var a = self.parse(s)
         let b = parser.parse(s)
         a.append(contentsOf: b)
         return a
      }
   }

   public func combine(deterministic parser: Parser<A>) -> Parser<A> {
      return Parser { s in
         let combined = self.combine(parser)
         let temp = combined.parse(s)
         if temp.isEmpty {
            return []
         }

         return Array(temp.prefix(1))
      }
   }

   public func option(_ other: Parser<A>) -> Parser<A> {
      return Parser { s in
         let a = self.parse(s)
         if a.isEmpty {
            return other.parse(s)
         }
         return a
      }
   }

   public func many() -> Parser<[A]> {
      return self.some().combine(deterministic: Parser<[A]>(pure: []))
   }

   public func some() -> Parser<[A]> {
      return self.flatMap { a in
         self.many().flatMap { xs in
            return Parser<[A]>(pure: [a] + xs)
         }
      }
   }

   public func separatedBy<B>(_ separator: Parser<B>) -> Parser<[A]> {
      return self.separatedBy(some: separator).combine(deterministic: Parser<[A]>(pure: []))
   }

   public func separatedBy<B>(some separator: Parser<B>) -> Parser<[A]> {
      return self.flatMap { a in
         self.separatedBy(separator).flatMap({ _ in return self }).many().flatMap { xs in
            return Parser<[A]>(pure: [a] + xs)
         }
      }
   }

   public func token() -> Parser<A> {
      return self.flatMap { a in
         return Parsers.whitespace.flatMap { _ in
            return Parser<A>(pure: a)
         }
      }
   }

   public func apply(to value: String) -> [ParseResult] {
      return Parsers.whitespace.flatMap { _ in self }.parse(value)
   }
}
