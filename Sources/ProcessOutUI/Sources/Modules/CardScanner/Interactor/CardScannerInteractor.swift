//
//  CardScannerInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2024.
//

protocol CardScannerInteractor: BaseInteractor<CardScannerInteractorState> {

    /// Card scanner configuration.
    var configuration: POCardScannerConfiguration { get }

    /// Enables or disables torch based on given value.
    func setTorchEnabled(_ isEnabled: Bool)

    /// Opens system application settings.
    func openApplicationSetting()
}
