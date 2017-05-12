import XCTest

@testable import ParseKit

class ParserTests: XCTestCase {
   func testInitPure() {
      let input = "test"
      let value = 10
      let sut = Parser(pure: value)

      let result = sut.runParser(on: input)

      XCTAssertFalse(result.isEmpty)
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0].result, 10)
      XCTAssertEqual(result[0].remaining, "test")
   }

   //TODO: make it monadic with map/flatMap/ap

   func testMap() {
      let input = "test"
      let value = 10
      let f: (Int) -> Double = { Double($0 + 5) }
      let sut = Parser(pure: value).map(f)

      let result = sut.runParser(on: input)

      XCTAssertFalse(result.isEmpty)
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0].result, 15.0)
      XCTAssertEqual(result[0].remaining, "test")
   }

   func testInit() {
      let input = "test"
      let sut = Parser<Int>()

      let result = sut.runParser(on: input)

      XCTAssertTrue(result.isEmpty)
   }
}
