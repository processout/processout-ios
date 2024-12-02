//
//  CardScannerInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2024.
//

protocol CardScannerInteractor: BaseInteractor<CardScannerInteractorState> {

    /// Card scanner configuration.
    var configuration: POCardScannerConfiguration { get }
}
