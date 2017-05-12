import XCTest

@testable import ParseKit

class StringExtensionsTests: XCTestCase {
   
   func test_GIVEN_Empty_String_WHEN_uncons_THEN_returns_nil() {
      let sut = ""

      let result = sut.uncons()

      XCTAssertNil(result)
   }
   
   func test_GIVEN_s_WHEN_uncons_THEN_returns_s_empty() {
      let sut = "s"

      let result = sut.uncons()

      XCTAssertNotNil(result)
      XCTAssertEqual(result!.head, "s")
      XCTAssertEqual(result!.tail, "")
   }
}
