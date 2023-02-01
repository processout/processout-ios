//
//  NativeAlternativePaymentMethodViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation

final class NativeAlternativePaymentMethodViewModel:
    BaseViewModel<NativeAlternativePaymentMethodViewModelState>, NativeAlternativePaymentMethodViewModelType {

    init(
        interactor: any NativeAlternativePaymentMethodInteractorType,
        configuration: PONativeAlternativePaymentMethodConfiguration,
        completion: ((Result<Void, POFailure>) -> Void)?
    ) {
        self.interactor = interactor
        self.configuration = configuration
        self.completion = completion
        super.init(state: .idle)
        observeInteractorStateChanges()
    }

    override func start() {
        interactor.start()
    }

    func submit() {
        interactor.submit()
    }

    // MARK: - Private Nested Types

    private typealias InteractorState = NativeAlternativePaymentMethodInteractorState
    private typealias Strings = ProcessOut.Strings.NativeAlternativePayment

    private enum Constants {
        static let captureSuccessCompletionDelay: TimeInterval = 3
    }

    // MARK: - NativeAlternativePaymentMethodInteractorType

    private let interactor: any NativeAlternativePaymentMethodInteractorType
    private let configuration: PONativeAlternativePaymentMethodConfiguration
    private let completion: ((Result<Void, POFailure>) -> Void)?

    // MARK: - Private Methods

    private func observeInteractorStateChanges() {
        interactor.didChange = { [weak self] in self?.configureWithInteractorState() }
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .starting:
            state = .loading
        case .started(let startedState):
            state = convertToState(startedState: startedState)
        case .failure(let failure):
            completion?(.failure(failure))
        case .submitting(let startedStateSnapshot):
            state = convertToState(startedState: startedStateSnapshot, isSubmitting: true)
        case .submitted:
            completion?(.success(()))
        case .awaitingCapture(let awaitingCaptureState):
            state = convertToState(awaitingCaptureState: awaitingCaptureState)
        case .captured(let capturedState):
            configure(with: capturedState)
        }
    }

    private func convertToState(
        startedState: InteractorState.Started, isSubmitting: Bool = false
    ) -> State {
        let parameters = startedState.parameters.map { parameter -> State.Parameter in
            let value = startedState.values[parameter.key]
            let viewModel = State.Parameter(
                name: parameter.displayName,
                placeholder: placeholder(for: parameter),
                value: value?.value ?? "",
                type: parameter.type,
                length: parameter.length,
                errorMessage: value?.recentErrorMessage,
                update: { [weak self] newValue in
                    _ = self?.interactor.updateValue(newValue, for: parameter.key)
                }
            )
            return viewModel
        }
        let actionTitle = submitActionTitle(amount: startedState.amount, currencyCode: startedState.currencyCode)
        let state = State.Started(
            title: configuration.title ?? Strings.title(startedState.gatewayDisplayName),
            parameters: parameters,
            isSubmitting: isSubmitting,
            action: .init(title: actionTitle, isEnabled: startedState.isSubmitAllowed) { [weak self] in
                self?.interactor.submit()
            }
        )
        return .started(state)
    }

    private func convertToState(awaitingCaptureState: InteractorState.AwaitingCapture) -> State {
        guard let expectedActionMessage = awaitingCaptureState.expectedActionMessage else {
            return .loading
        }
        let submittedState = State.Submitted(
            message: expectedActionMessage,
            logoImage: awaitingCaptureState.gatewayLogoImage,
            image: awaitingCaptureState.actionImage,
            isCaptured: false
        )
        return .submitted(submittedState)
    }

    private func configure(with capturedState: InteractorState.Captured) {
        if configuration.skipSuccessScreen {
            completion?(.success(()))
        } else {
            Timer.scheduledTimer(
                withTimeInterval: Constants.captureSuccessCompletionDelay,
                repeats: false,
                block: { [weak self] _ in
                    self?.completion?(.success(()))
                }
            )
            let submittedState = State.Submitted(
                message: Strings.Success.message,
                logoImage: capturedState.gatewayLogo,
                image: Asset.Images.success.image,
                isCaptured: true
            )
            state = .submitted(submittedState)
        }
    }

    // MARK: - Utils

    private func placeholder(for parameter: PONativeAlternativePaymentMethodParameter) -> String? {
        switch parameter.type {
        case .numeric:
            return nil
        case .text:
            return Strings.Text.placeholder
        case .email:
            return Strings.Email.placeholder
        case .phone:
            return Strings.Phone.placeholder
        }
    }

    private func submitActionTitle(amount: Decimal, currencyCode: String) -> String {
        if let title = configuration.primaryActionTitle {
            return title
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 0
        // swiftlint:disable:next legacy_objc_type
        if let formattedAmount = formatter.string(from: amount as NSDecimalNumber) {
            return Strings.SubmitButton.title(formattedAmount)
        }
        return Strings.SubmitButton.defaultTitle
    }
}
