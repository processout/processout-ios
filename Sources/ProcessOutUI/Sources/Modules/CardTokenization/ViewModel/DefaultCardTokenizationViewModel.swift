//
//  DefaultCardTokenizationViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import Foundation
import Combine
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

final class DefaultCardTokenizationViewModel: CardTokenizationViewModel {

    init(interactor: some CardTokenizationInteractor, configuration: POCardTokenizationConfiguration) {
        self.interactor = interactor
        self.configuration = configuration
        state = .idle
        observeChanges(interactor: interactor)
    }

    // MARK: - CardTokenizationViewModel

    @Published
    var state: CardTokenizationViewModelState

    func didAppear() {
        interactor.start()
    }

    // MARK: - Private Nested Types

    private typealias InteractorState = CardTokenizationInteractorState

    private enum SectionId {
        static let title = "title"
        static let cardInformation = "card-info"
        static let preferredScheme = "preferred-scheme"
    }

    private enum ItemId {
        static let error = "error"
        static let trackData = "track-data"
    }

    // MARK: - Private Properties

    private let interactor: any CardTokenizationInteractor
    private let configuration: POCardTokenizationConfiguration

    private var interactorChangesCancellable: AnyCancellable?

    // MARK: - Private Methods

    private func observeChanges(interactor: some CardTokenizationInteractor) {
        interactor.didChange = { [weak self] in
            self?.configureWithInteractorState()
        }
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .started(let startedState):
            state = convertToState(startedState: startedState, isSubmitting: false)
        case .tokenizing(let startedState):
            state = convertToState(startedState: startedState, isSubmitting: true)
        default:
            break
        }
    }

    // MARK: - Started State

    private func convertToState(
        startedState: InteractorState.Started, isSubmitting: Bool
    ) -> CardTokenizationViewModelState {
        var cardInformationItems = cardInformationInputItems(startedState: startedState)
        if let error = startedState.recentErrorMessage {
            let errorItem = State.ErrorItem(id: ItemId.error, description: error)
            cardInformationItems.append(.error(errorItem))
        }
        let cardInformationSection = State.Section(
            id: SectionId.cardInformation,
            title: String(resource: .CardTokenization.CardDetails.title),
            items: cardInformationItems
        )
        let sections = [
            cardInformationSection
        ]
        let startedState = State(
            title: title(),
            sections: sections.compactMap { $0 },
            isEditingAllowed: !isSubmitting,
            actions: createActions(startedState: startedState, isSubmitting: isSubmitting),
            focusedInputId: focusedInputId(startedState: startedState, isSubmitting: isSubmitting)
        )
        return startedState
    }

    // MARK: - Title

    private func title() -> String? {
        let title = configuration.title ?? String(resource: .CardTokenization.title)
        return title.isEmpty ? nil : title
    }

    // MARK: - Input Items

    private func cardInformationInputItems(
        startedState: InteractorState.Started
    ) -> [CardTokenizationViewModelState.Item] {
        let numberItem = createItem(
            parameter: startedState.number,
            placeholder: String(resource: .CardTokenization.CardDetails.Placeholder.number),
            icon: cardNumberIcon(startedState: startedState),
            keyboard: .asciiCapableNumberPad,
            contentType: .creditCardNumber
        )
        let expirationItem = createItem(
            parameter: startedState.expiration,
            placeholder: String(resource: .CardTokenization.CardDetails.Placeholder.expiration),
            keyboard: .asciiCapableNumberPad
        )
        let cvcItem = createItem(
            parameter: startedState.cvc,
            placeholder: String(resource: .CardTokenization.CardDetails.Placeholder.cvc),
            icon: Image(.Card.back),
            keyboard: .asciiCapableNumberPad
        )
        var items = [
            numberItem,
            .group(
                State.GroupItem(id: ItemId.trackData, items: [expirationItem, cvcItem])
            )
        ]
        if configuration.isCardholderNameInputVisible {
            let cardholderItem = createItem(
                parameter: startedState.cardholderName,
                placeholder: String(resource: .CardTokenization.CardDetails.Placeholder.cardholder),
                keyboard: .asciiCapable,
                contentType: .name
            )
            items.append(cardholderItem)
        }
        return items
    }

    private func createItem(
        parameter: InteractorState.Parameter,
        placeholder: String,
        icon: Image? = nil,
        keyboard: UIKeyboardType,
        contentType: UITextContentType? = nil
    ) -> CardTokenizationViewModelState.Item {
        let value = Binding<String>(
            get: { parameter.value },
            set: { [weak self] in self?.interactor.update(parameterId: parameter.id, value: $0) }
        )
        let inputItem = State.InputItem(
            id: parameter.id,
            value: value,
            placeholder: placeholder,
            isInvalid: !parameter.isValid,
            icon: icon,
            formatter: parameter.formatter,
            keyboard: keyboard,
            contentType: contentType,
            onSubmit: { [weak self] in
                self?.submitFocusedInput()
            }
        )
        return .input(inputItem)
    }

    private func cardNumberIcon(startedState: InteractorState.Started) -> Image? {
        let scheme = startedState.issuerInformation?.coScheme != nil
            ? startedState.preferredScheme
            : startedState.issuerInformation?.scheme
        guard let scheme else {
            return nil
        }
        let resources: [String: ImageResource] = [
            "american express": .Schemes.amex,
            "carte bancaire": .Schemes.carteBancaire,
            "dinacard": .Schemes.dinacard,
            "diners club": .Schemes.diners,
            "diners club carte blanche": .Schemes.diners,
            "diners club international": .Schemes.diners,
            "diners club united states & canada": .Schemes.diners,
            "discover": .Schemes.discover,
            "elo": .Schemes.elo,
            "jcb": .Schemes.JCB,
            "mada": .Schemes.mada,
            "maestro": .Schemes.maestro,
            "mastercard": .Schemes.mastercard,
            "rupay": .Schemes.rupay,
            "sodexo": .Schemes.sodexo,
            "china union pay": .Schemes.unionPay,
            "verve": .Schemes.verve,
            "visa": .Schemes.visa,
            "vpay": .Schemes.vpay
        ]
        let normalizedScheme = scheme.lowercased()
        guard let resource = resources[normalizedScheme] else {
            return nil
        }
        return Image(resource)
    }

    // MARK: - Preferred Scheme

//    private func preferredSchemeSection(startedState: InteractorState.Started) -> State.Section? {
//        guard configuration.isSchemeSelectionAllowed,
//              let issuerInformation = startedState.issuerInformation,
//              let coScheme = issuerInformation.coScheme else {
//            return nil
//        }
//        let sectionId = State.SectionIdentifier(
//            id: SectionId.preferredScheme,
//            header: .init(title: Text.PreferredScheme.title, isCentered: false),
//            isTight: true
//        )
//        let schemeItem = State.RadioButtonItem(
//            value: Text.PreferredScheme.description(issuerInformation.scheme.capitalized),
//            isSelected: startedState.preferredScheme == issuerInformation.scheme,
//            isInvalid: false,
//            accessibilityIdentifier: "card-tokenization.scheme-button",
//            select: { [weak self] in
//                self?.interactor.setPreferredScheme(issuerInformation.scheme)
//            }
//        )
//        let coSchemeItem = State.RadioButtonItem(
//            value: Text.PreferredScheme.description(coScheme.capitalized),
//            isSelected: startedState.preferredScheme == coScheme,
//            isInvalid: false,
//            accessibilityIdentifier: "card-tokenization.co-scheme-button",
//            select: { [weak self] in
//                self?.interactor.setPreferredScheme(coScheme)
//            }
//        )
//        let items = [schemeItem, coSchemeItem].map(State.Item.radio)
//        return State.Section(id: sectionId, items: items)
//    }

    // MARK: - Actions

    private func createActions(
        startedState: InteractorState.Started, isSubmitting: Bool
    ) -> [POActionsContainerActionViewModel] {
        let actions = [
            submitAction(startedState: startedState, isSubmitting: isSubmitting),
            cancelAction(isEnabled: !isSubmitting)
        ]
        return actions.compactMap { $0 }
    }

    private func submitAction(
        startedState: InteractorState.Started, isSubmitting: Bool
    ) -> POActionsContainerActionViewModel {
        let action = POActionsContainerActionViewModel(
            id: "card-tokenization.primary-button",
            title: configuration.primaryActionTitle ?? String(resource: .CardTokenization.Button.submit),
            isEnabled: startedState.recentErrorMessage == nil,
            isLoading: isSubmitting,
            isPrimary: true,
            action: { [weak self] in
                self?.interactor.tokenize()
            }
        )
        return action
    }

    private func cancelAction(isEnabled: Bool) -> POActionsContainerActionViewModel? {
        let title = configuration.cancelActionTitle ?? String(resource: .CardTokenization.Button.cancel)
        guard !title.isEmpty else {
            return nil
        }
        let action = POActionsContainerActionViewModel(
            id: "card-tokenization.cancel-button",
            title: title,
            isEnabled: isEnabled,
            isLoading: false,
            isPrimary: false,
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }

    // MARK: - Parameters Submission

    private func submitFocusedInput() {
        guard let focusedInputId = state.focusedInputId else {
            assertionFailure("Unable to identify focused input.")
            return
        }
        guard case .started(let startedState) = interactor.state else {
            return
        }
        let parameterIds = parameters(startedState: startedState).map(\.id)
        guard let focusedInputIndex = parameterIds.map(AnyHashable.init).firstIndex(of: focusedInputId) else {
            return
        }
        if parameterIds.indices.contains(focusedInputIndex + 1) {
            state.focusedInputId = parameterIds[focusedInputIndex + 1]
        } else {
            interactor.tokenize()
        }
    }

    // MARK: - Focus

    /// Returns input identifier that should be focused.
    private func focusedInputId(startedState: InteractorState.Started, isSubmitting: Bool) -> AnyHashable? {
        if isSubmitting {
            return nil
        }
        if let id = state.focusedInputId {
            return id
        }
        let paramters = parameters(startedState: startedState)
        if let index = paramters.map(\.isValid).firstIndex(of: false) {
            // Attempt to focus first invalid parameter if available.
            return paramters[index].id
        }
        return paramters.first?.id
    }

    // MARK: - Utils

    private func parameters(startedState: InteractorState.Started) -> [InteractorState.Parameter] {
        var parameters = [startedState.number, startedState.expiration, startedState.cvc]
        if configuration.isCardholderNameInputVisible {
            parameters.append(startedState.cardholderName)
        }
        return parameters
    }
}
