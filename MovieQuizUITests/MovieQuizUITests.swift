import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testYesButton() {
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        let firstValue = indexLabel.label
        app.buttons["Yes"].tap()
        sleep(3)
        XCTAssertNotEqual(firstValue, indexLabel.label)
    }
    
    func testNoButton() {
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        let firstValue = indexLabel.label
        app.buttons["No"].tap()
        sleep(3)
        XCTAssertNotEqual(firstValue, indexLabel.label)
    }
    
    func testGameFinish() {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons["Сыграть ещё раз"].exists)
    }
    
    func testAlertDismiss() {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        app.alerts.firstMatch.buttons["Сыграть ещё раз"].tap()
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
