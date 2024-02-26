//
//  CardRecognitionCoordinatorDelegate.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 26.01.2024.
//

protocol CardRecognitionCoordinatorDelegate: AnyObject {

    /// Called when coordinator recognizes card details.
    func cardRecognitionCoordinator(_ coordinator: CardRecognitionCoordinator, didRecognizeCard: POScannedCard)
}
