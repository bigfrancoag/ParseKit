import XCTest

@testable import ParseKit

class ParsersTests: XCTestCase {
   
   func testItem_empty() {
      let sut = Parsers.item
      let input = ""

      let result = sut.runParser(on: input)

      XCTAssertTrue(result.isEmpty)
   }
   
   func testItem_nonempty() {
      let sut = Parsers.item
      let input = "test"

      let result = sut.runParser(on: input)

      XCTAssertFalse(result.isEmpty)
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0].result, "t")
      XCTAssertEqual(result[0].remaining, "est")
   }

   func testToken_empty() {
      let sut = Parsers.token("token")
      let input = ""

      let result = sut.runParser(on: input)

      XCTAssertTrue(result.isEmpty)
   }
   
   func testToken_nonmatching() {
      let sut = Parsers.token("token")
      let input = "test"

      let result = sut.runParser(on: input)

      XCTAssertTrue(result.isEmpty)
   }
   
   func testToken_matchingExactly() {
      let sut = Parsers.token("token")
      let input = "token"

      let result = sut.runParser(on: input)

      XCTAssertFalse(result.isEmpty)
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0].result, "token")
      XCTAssertEqual(result[0].remaining, "")
   }
   
   func testToken_matching() {
      let sut = Parsers.token("token")
      let input = "tokenstr"

      let result = sut.runParser(on: input)

      XCTAssertFalse(result.isEmpty)
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0].result, "token")
      XCTAssertEqual(result[0].remaining, "str")
   }
}
