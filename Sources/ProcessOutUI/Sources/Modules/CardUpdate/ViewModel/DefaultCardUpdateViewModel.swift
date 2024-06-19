//
//  DefaultCardUpdateViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

final class DefaultCardUpdateViewModel: CardUpdateViewModel {

    init(interactor: some CardUpdateInteractor, configuration: POCardUpdateConfiguration) {
        self.configuration = configuration
        self.interactor = interactor
        sections = []
        actions = []
        observeChanges(interactor: interactor)
    }

    // MARK: - CardUpdateViewModel

    private(set) lazy var title: String? = {
        let title = configuration.title ?? String(resource: .CardUpdate.title)
        return title.isEmpty ? nil : title
    }()

    @Published
    private(set) var sections: [CardUpdateViewModelSection]

    @Published
    private(set) var actions: [POActionsContainerActionViewModel]

    @Published
    var focusedItemId: AnyHashable?

    func start() {
        interactor.start()
    }

    // MARK: - Private Nested Types

    private typealias InteractorState = CardUpdateInteractorState

    private enum SectionId {
        static let cardInformation = "card-info"
        static let preferredScheme = "preferred-scheme"
    }

    private enum ItemId {
        static let number = "card-number"
        static let cvc = "card-cvc"
        static let error = "error"
        static let scheme = "scheme"
    }

    private enum ActionId {
        static let submit = "submit"
        static let cancel = "cancel"
    }

    // MARK: - Private Properties

    private let configuration: POCardUpdateConfiguration
    private let interactor: any CardUpdateInteractor

    // MARK: - Private Methods

    private func observeChanges(interactor: some Interactor) {
        interactor.didChange = { [weak self] in
            self?.configureWithInteractorState()
        }
        configureWithInteractorState()
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle, .completed:
            break // Ignored
        case .starting:
            sections = [
                .init(id: SectionId.cardInformation, title: nil, items: [.progress])
            ]
            updateActionsWithStartingState()
            focusedItemId = nil
        case .started(let state):
            updateSections(with: state)
            updateActions(with: state)
            focusedItemId = ItemId.cvc
        case .updating(let state):
            updateSections(with: state)
            updateActions(with: state, isSubmitting: true)
            focusedItemId = nil
        }
    }

    // MARK: - Inputs

    private func updateSections(with state: InteractorState.Started) {
        var cardItems = [
            createCardNumberItem(state: state), createCvcItem(state: state)
        ]
        if let error = state.recentErrorMessage {
            let errorItem = CardUpdateViewModelItem.Error(id: ItemId.error, description: error)
            cardItems.append(.error(errorItem))
        }
        let cardSection = CardUpdateViewModelSection(
            id: SectionId.cardInformation, title: nil, items: cardItems.compactMap { $0 }
        )
        let preferredSchemeSection = createPreferredSchemeSection(startedState: state)
        self.sections = [cardSection, preferredSchemeSection].compactMap { $0 }
    }

    private func createCardNumberItem(state: InteractorState.Started) -> CardUpdateViewModelItem? {
        guard let cardNumber = state.cardNumber else {
            return nil
        }
        let scheme = state.preferredScheme ?? state.scheme
        let item = CardUpdateViewModelItem.Input(
            id: ItemId.number,
            value: .constant(cardNumber),
            placeholder: "",
            isInvalid: false,
            isEnabled: false,
            icon: scheme.flatMap(CardSchemeImageProvider.shared.image),
            formatter: nil,
            keyboard: .asciiCapableNumberPad,
            contentType: nil,
            onSubmit: { }
        )
        return .input(item)
    }

    private func createCvcItem(state: InteractorState.Started) -> CardUpdateViewModelItem {
        let item = CardUpdateViewModelItem.Input(
            id: ItemId.cvc,
            value: .init(
                get: { state.cvc },
                set: { [weak self] newValue in
                    self?.interactor.update(cvc: newValue)
                }
            ),
            placeholder: String(resource: .CardUpdate.CardDetails.cvc),
            isInvalid: !state.areParametersValid,
            isEnabled: true,
            icon: Image(.Card.back),
            formatter: state.formatter,
            keyboard: .asciiCapableNumberPad,
            contentType: nil,
            onSubmit: { [weak self] in
                self?.interactor.submit()
            }
        )
        return .input(item)
    }

    // MARK: - Preferred Scheme

    private func createPreferredSchemeSection(
        startedState: InteractorState.Started
    ) -> CardUpdateViewModelSection? {
        guard configuration.isSchemeSelectionAllowed,
              let scheme = startedState.scheme,
              let coScheme = startedState.coScheme else {
            return nil
        }
        let pickerItem = CardUpdateViewModelItem.Picker(
            id: ItemId.scheme,
            options: [
                .init(id: scheme, title: scheme.capitalized),
                .init(id: coScheme, title: coScheme.capitalized)
            ],
            selectedOptionId: .init(
                get: { startedState.preferredScheme },
                set: { [weak self] newValue in
                    self?.interactor.setPreferredScheme(newValue ?? scheme)
                }
            ),
            preferrsInline: true
        )
        let section = CardUpdateViewModelSection(
            id: SectionId.preferredScheme,
            title: String(resource: .CardUpdate.PreferredScheme.title),
            items: [.picker(pickerItem)]
        )
        return section
    }

    // MARK: - Actions

    private func updateActionsWithStartingState() {
        let actions = [
            submitAction(isEnabled: false, isLoading: false),
            cancelAction(isEnabled: false)
        ]
        self.actions = actions.compactMap { $0 }
    }

    private func updateActions(with state: InteractorState.Started, isSubmitting: Bool = false) {
        let actions = [
            submitAction(isEnabled: state.areParametersValid, isLoading: isSubmitting),
            cancelAction(isEnabled: !isSubmitting)
        ]
        self.actions = actions.compactMap { $0 }
    }

    private func submitAction(isEnabled: Bool, isLoading: Bool) -> POActionsContainerActionViewModel {
        let action = POActionsContainerActionViewModel(
            id: ActionId.submit,
            title: configuration.primaryActionTitle ?? String(resource: .CardUpdate.Button.submit),
            isEnabled: isEnabled,
            isLoading: isLoading,
            isPrimary: true,
            action: { [weak self] in
                self?.interactor.submit()
            }
        )
        return action
    }

    private func cancelAction(isEnabled: Bool) -> POActionsContainerActionViewModel? {
        let title = configuration.cancelActionTitle ?? String(resource: .CardUpdate.Button.cancel)
        guard !title.isEmpty else {
            return nil
        }
        let action = POActionsContainerActionViewModel(
            id: ActionId.cancel,
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
}
