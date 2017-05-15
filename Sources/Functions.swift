func const<A, B>(_ a: A) -> (B) -> A {
   return { _ in a }
}

func id<A>(_ a: A) -> A {
   return a
}

func • <A, B, C>(_ f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
   return { a in f(g(a)) }
}
