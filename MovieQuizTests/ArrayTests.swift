import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    
    func testGetValueInRange() throws {
        let array = [1, 1, 2, 3, 5]
        let result = array[safe: 2]
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 2)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1, 1, 2, 3, 5]
        let result = array[safe: 20]
        XCTAssertNil(result)
    }
}
