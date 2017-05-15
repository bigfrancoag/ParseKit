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

   public func run(on input: String) -> [ParseResult] {
      return self.parse(input)
   }

   public func map<B>(_ transform: @escaping (A) -> B) -> Parser<B> {
      return self.flatMap { Parser<B>(pure: transform($0)) }
   }

   public func flatMap<B>(_ transform: @escaping (A) -> Parser<B>) -> Parser<B> {
      return Parser<B> { s in
         let a = self.parse(s)
         return a.flatMap { return transform($0.result).parse($0.remaining) }
      }
   }

   public static func apply<B>(_ pf: Parser<(A) -> B>, _ pa: Parser<A>) -> Parser<B> {
      return Parser<B> { s in
         return pf.parse(s).flatMap { (f, s1) in pa.parse(s1).map { (a, s2) in (f(a), s2) } }
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
      return self.flatMap { a in self.many().flatMap { xs in Parser<[A]>(pure: [a] + xs) } }
   }

   public func separatedBy<B>(_ separator: Parser<B>) -> Parser<[A]> {
      return self.separatedBy(some: separator).combine(deterministic: Parser<[A]>(pure: []))
   }

   public func separatedBy<B>(some separator: Parser<B>) -> Parser<[A]> {
      return self.flatMap { a in self.separatedBy(separator).flatMap({ _ in self }).many().flatMap { xs in Parser<[A]>(pure: [a] + xs) } }
   }

   public func token() -> Parser<A> {
      return self.flatMap { a in Parsers.whitespace.flatMap { _ in Parser<A>(pure: a) } }
   }

   public func apply(to value: String) -> [ParseResult] {
      return Parsers.whitespace.flatMap { _ in self }.parse(value)
   }

   public func chain(_ combiner: Parser<(A, A) -> A>, seed: A) -> Parser<A> {
      return chain(combiner).combine(deterministic: Parser(pure: seed))
   }

   public func chain(_ combiner: Parser<(A, A) -> A>) -> Parser<A> {
      func rest(_ a: A) -> Parser<A> {
         return combiner.flatMap { f in self.flatMap { b in rest(f(a, b)) } }
            .combine(deterministic: Parser(pure: a))
      }

      return self.flatMap { rest($0) }
   }

   public func filter(_ predicate: @escaping (A) -> Bool) -> Parser<A> {
      return self.flatMap { a in
         if predicate(a) {
            return self
         }
         return Parser<A>()
      }
   }
}
