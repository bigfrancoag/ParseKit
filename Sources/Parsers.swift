public enum Parsers {
   public static let item: Parser<Character> = Parser { s in
      guard let (head, tail) = s.uncons() else {
         return []
      }   

      return [(result: head.characters.first!, remaining: tail)]
   }   

   public static func token(_ value: String) -> Parser<String> {
      return Parser { s in
         guard s.hasPrefix(value) else {
            return []
         }

         let tailIndex = s.index(s.startIndex, offsetBy: value.characters.count)
         let result = s.substring(to: tailIndex)
         let remaining = s.substring(from: tailIndex)

         return [(result: result, remaining: remaining)]
      }
   }

   public static func statisfy(_ predicate: @escaping (Character) -> Bool) -> Parser<Character> {
      return item.filter(predicate)
   }

   public static func regex(pattern: String) -> Parser<String> {
      return Parser { s in
         guard let range = s.range(of: pattern, options: [.regularExpression, .anchored], range: s.startIndex ..< s.endIndex) else {
            return []
         }
         let result = s.substring(with: range)
         let remaining = s.substring(from: range.upperBound)
         return [(result: result, remaining: remaining)]
      }
   }

   public static let whitespace: Parser<String> = regex(pattern: "\\s*")

   public static func symbolicToken(_ value: String) -> Parser<String> {
      return token(value).token()
   }
}
