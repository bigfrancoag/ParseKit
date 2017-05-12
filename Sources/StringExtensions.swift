extension String {
   func uncons() -> (head: String, tail: String)? {
      guard !self.isEmpty else {
         return nil
      }

      let tailIndex = self.index(after: self.startIndex)
      let head = self.substring(to: tailIndex)
      let tail = self.substring(from: tailIndex)
      return (head: head, tail: tail)
   }
}
