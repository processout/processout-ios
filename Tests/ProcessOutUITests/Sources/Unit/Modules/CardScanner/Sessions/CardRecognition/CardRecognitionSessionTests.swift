//
//  CardRecognitionSessionTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2024.
//

import XCTest
import SwiftUI
import UIKit
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

final class CardRecognitionSessionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sut = CardRecognitionSession(
            numberDetector: CardNumberDetector(
                regexProvider: .shared, formatter: .init()
            ),
            expirationDetector: CardExpirationDetector(
                regexProvider: .shared, formatter: .init()
            ),
            cardholderNameDetector: CardholderNameDetector(),
            errorCorrection: .init(errorCorrectionDuration: 0), // Disables error correction
            logger: .stub
        )
    }

    // MARK: - Tests

    func test_setCameraSession_setsCameraSessionDelegate() async {
        // Given
        let cameraSession = MockCameraSession()

        // When
        await sut.setCameraSession(cameraSession)

        // Then
        let isDelegateSet = await cameraSession.delegate != nil
        XCTAssertTrue(isDelegateSet)
    }

    func test_cameraSessionDidOutput_whenCardImageIsValid_updatesDelegateUpdatedImage() async {
        // Given
        let cameraSession = MockCameraSession(), recognitionSessionDelegate = MockCardRecognitionSessionDelegate()
        await sut.setDelegate(recognitionSessionDelegate)
        await sut.setCameraSession(cameraSession)

        // When
        let testCardImage = UIImage(named: "ValidCard", in: Bundle(for: CardRecognitionSessionTests.self), with: nil)!
        await cameraSession.delegate?.cameraSession(
            cameraSession, didOutput: CIImage(cgImage: testCardImage.cgImage!)
        )

        // Then
        let expectedCard = POScannedCard(
            number: "5454 5454 5454 5454",
            expiration: .init(month: 4, year: 2040, description: "04 / 40"),
            cardholderName: "JOHN DOE"
        )
        let lastUpdatedCard = await recognitionSessionDelegate.lastUpdatedCard
        XCTAssertTrue(lastUpdatedCard == expectedCard)
    }

    // MARK: - Private Properties

    private var sut: CardRecognitionSession!
}
