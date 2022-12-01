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
        router: any RouterType<NativeAlternativePaymentMethodRoute>,
        completion: ((Result<Void, POFailure>) -> Void)?
    ) {
        self.interactor = interactor
        self.router = router
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

    // MARK: - NativeAlternativePaymentMethodInteractorType

    private let interactor: any NativeAlternativePaymentMethodInteractorType
    private let router: any RouterType<NativeAlternativePaymentMethodRoute>
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
            state = .starting
        case .started(let startedState):
            state = convertToState(startedState: startedState)
        case let .submitting(stateSnapshot):
            state = convertToState(startedState: stateSnapshot, isSubmitting: true)
        case let .submissionFailure(stateSnapshot, failure):
            state = convertToState(startedState: stateSnapshot, failureMessage: failure.message)
        case let .submitted(stateSnapshot):
            state = convertToState(startedState: stateSnapshot)
        case .failure:
            state = .failure
        }
    }

    private func convertToState(
        startedState: InteractorState.Started, failureMessage: String? = nil, isSubmitting: Bool = false
    ) -> State {
        let parameters = startedState.parameters.map { parameter -> State.Parameter in
            let value = startedState.values[parameter.key]?.value ?? ""
            let parameterViewModel = State.Parameter(
                id: parameter.key + parameter.type.rawValue,
                placeholder: placeholder(for: parameter),
                value: value,
                isRequired: parameter.required,
                type: parameter.type,
                update: { [weak self] newValue in
                    self?.interactor.updateValue(newValue, for: parameter.key) ?? false
                }
            )
            return parameterViewModel
        }
        let state = State.Started(
            message: startedState.message,
            parameters: parameters,
            failureMessage: failureMessage,
            isSubmitAllowed: startedState.isSubmitAllowed,
            isSubmitting: isSubmitting
        )
        return .started(state)
    }

    // MARK: - Utils

    private func placeholder(for parameter: PONativeAlternativePaymentMethodParameter) -> String {
        switch parameter.type {
        case .numeric:
            return "123456"
        case .text:
            return "Text goes here..."
        case .email:
            return "example@domain.com"
        case .phone:
            return "Phone number goes here..."
        }
    }
}
