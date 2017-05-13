enum Parsers {
   public static func item() -> Parser<Character> {
      return Parser { s in
         guard let (head, tail) = s.uncons() else {
            return []
         }   

         return [(result: head.characters.first!, remaining: tail)]
      }   
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
}
