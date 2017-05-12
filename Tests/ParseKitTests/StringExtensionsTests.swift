import XCTest

@testable import ParseKit

class StringExtensionsTests: XCTestCase {
   
   func testUncons_empty() {
      let sut = ""

      let result = sut.uncons()

      XCTAssertNil(result)
   }
   
   func testUncons_nonempty() {
      let sut = "s"

      let result = sut.uncons()

      XCTAssertNotNil(result)
      XCTAssertEqual(result!.head, "s")
      XCTAssertEqual(result!.tail, "")
   }
}
