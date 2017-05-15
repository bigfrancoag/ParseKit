import Foundation

public struct Parser<A> {
   public typealias ParseResult = (result: A, remaining: String)
   fileprivate let parse: (String) -> [ParseResult]

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
      return self >>- { Parser<B>(pure: transform($0)) }
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

   public func orElse(_ other: Parser<A>) -> Parser<A> {
      return Parser { s in
         let a = self.parse(s)
         if a.isEmpty {
            return other.parse(s)
         }
         return a
      }
   }

   public func optional() -> Parser<A?> {
      return self.map({ (a: A) -> A? in return a }) <|> Parser<A?>(pure: nil)
   }

   public func many() -> Parser<[A]> {
      return self.some().combine(deterministic: Parser<[A]>(pure: []))
   }

   public func some() -> Parser<[A]> {
      return self >>- { a in self.many() >>- { xs in Parser<[A]>(pure: [a] + xs) } }
   }

   public func separatedBy<B>(_ separator: Parser<B>) -> Parser<[A]> {
      return self.separatedBy(some: separator).combine(deterministic: Parser<[A]>(pure: []))
   }

   public func separatedBy<B>(some separator: Parser<B>) -> Parser<[A]> {
      return self >>- { a in self.separatedBy(separator).flatMap({ _ in self }).many() >>- { xs in Parser<[A]>(pure: [a] + xs) } }
   }

   public func token() -> Parser<A> {
      return self >>- { a in Parsers.whitespace >>- { _ in Parser<A>(pure: a) } }
   }

   public func apply(to value: String) -> [ParseResult] {
      return (Parsers.whitespace >>- { _ in self }).parse(value)
   }

   public func chain(_ combiner: Parser<(A, A) -> A>, seed: A) -> Parser<A> {
      return chain(combiner).combine(deterministic: Parser(pure: seed))
   }

   public func chain(_ combiner: Parser<(A, A) -> A>) -> Parser<A> {
      func rest(_ a: A) -> Parser<A> {
         return (combiner >>- { f in self >>- { b in rest(f(a, b)) } })
            .combine(deterministic: Parser(pure: a))
      }

      return self >>- { rest($0) }
   }

   public func filter(_ predicate: @escaping (A) -> Bool) -> Parser<A> {
      return self >>- { a in
         if predicate(a) {
            return self
         }
         return Parser<A>()
      }
   }

   public static func >>- <B>(lhs: Parser<A>, rhs: @escaping (A) -> Parser<B>) -> Parser<B> {
      return lhs.flatMap(rhs)
   }

   public static func >> <B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<B> {
      return lhs >>- { _ in rhs }
   }

   public static func <^> <B>(lhs: @escaping (A) -> B, rhs: Parser<A>) -> Parser<B> {
      return fmap(lhs)(rhs)
   }

   public static func <*> <B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {
      return ap(lhs, rhs)
   }

   public static func <^ <B>(lhs: A, rhs: Parser<B>) -> Parser<A> {
      return fmap(const(lhs))(rhs)
   }

   public static func *> <B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<B> {
      return (id <^ lhs) <*> rhs 
   }

   public static func <* <B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<A> {
      return fmap(const)(lhs) <*> rhs
   }

   public static func <|> (lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
      return lhs.orElse(rhs)
   }

   public static postfix func .? (val: Parser<A>) -> Parser<A?> {
      return val.optional()
   }

   public static postfix func .* (val: Parser<A>) -> Parser<[A]> {
      return val.many()
   }

   public static postfix func .+ (val: Parser<A>) -> Parser<[A]> {
      return val.some()
   }
}

public func fmap<T, U>(_ f: @escaping (T) -> U) -> (Parser<T>) -> Parser<U> {
   return { $0.map(f) }
}

public func ap<T, U>(_ pf: Parser<(T) -> U>, _ pt: Parser<T>) -> Parser<U> {
   return Parser<U> { s in
      return pf.parse(s).flatMap { (f, s1) in pt.parse(s1).map { (t, s2) in (f(t), s2) } }
   }
}

postfix operator .?
postfix operator .*
postfix operator .+

infix operator •: FunctorPrecedence

infix operator <*>: FunctorPrecedence
infix operator <^>: FunctorPrecedence
infix operator <^: FunctorPrecedence
infix operator *>: FunctorSequencePrecedence
infix operator <*: FunctorSequencePrecedence
infix operator >>-: MonadPrecedence
infix operator >>: MonadPrecedence

infix operator <|>: ParserPrecedence

precedencegroup FunctorPrecedence {
   associativity: left
   higherThan: ParserPrecedence
}

precedencegroup FunctorSequencePrecedence {
   associativity: left
   higherThan: FunctorPrecedence
}

precedencegroup MonadPrecedence {
   associativity: left
   higherThan: FunctorSequencePrecedence
}

precedencegroup ParserPrecedence {
   associativity: left
   higherThan: DefaultPrecedence
}
