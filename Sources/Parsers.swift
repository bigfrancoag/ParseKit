enum Parsers {
   public static func item() -> Parser<String> {
      return Parser<String> { s in
         guard let (head, tail) = s.uncons() else {
            return []
         }   

         return [(result: head, remaining: tail)]
      }   
   }
}
