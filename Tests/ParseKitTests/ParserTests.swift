import XCTest

@testable import ParseKit

class ParserTests: XCTestCase {
   
   func test_GIVEN_Item_WHEN_call_run_empty_string_THEN_returns_empty_array() {
      let sut = Parser<Any>.item()
      let input = ""

      let result: [(result: String, remaining: String)] = sut.runParser(on: input)

      XCTAssertTrue(result.isEmpty)
   }
   
   func test_GIVEN_Item_WHEN_call_run_on_test_THEN_returns_single_element_t_est() {
      let sut = Parser<Any>.item()
      let input = "test"

      let result: [(result: String, remaining: String)] = sut.runParser(on: input)

      XCTAssertFalse(result.isEmpty)
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0].result, "t")
      XCTAssertEqual(result[0].remaining, "est")
   }
   
   func test_GIVEN_10_WHEN_init_pure_AND_call_run_on_test_THEN_returns_single_element_10_test() {
      let input = "test"
      let value = 10
      let sut = Parser(pure: value)

      let result: [(result: Int, remaining: String)] = sut.runParser(on: input)

      XCTAssertFalse(result.isEmpty)
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result[0].result, 10)
      XCTAssertEqual(result[0].remaining, "test")
   }
}
