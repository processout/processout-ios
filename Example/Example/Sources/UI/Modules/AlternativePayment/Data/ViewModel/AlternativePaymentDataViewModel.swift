//
//  AlternativePaymentDataViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 25.01.2023.
//

import Foundation

final class AlternativePaymentDataViewModel:
    BaseViewModel<AlternativePaymentDataViewModelState>, AlternativePaymentDataViewModelType {

    init(
        router: any RouterType<AlternativePaymentDataRoute>,
        completion: @escaping (_ additionalData: [String: String]) -> Void
    ) {
        self.router = router
        self.completion = completion
        additionalData = [:]
        super.init(state: .idle)
    }

    // MARK: - AlternativePaymentDataViewModelType

    override func start() {
        guard case .idle = state else {
            return
        }
        let startedState = State.Started(items: [emptyItem])
        state = .started(startedState)
    }

    func submit() {
        router.trigger(route: .close)
        completion(additionalData)
    }

    func add() {
        let route = AlternativePaymentDataRoute.additionalData { [weak self] key, value in
            guard !key.isEmpty else {
                return
            }
            self?.additionalData[key] = value.isEmpty ? nil : value
        }
        router.trigger(route: route)
    }

    // MARK: - Private Properties

    private let router: any RouterType<AlternativePaymentDataRoute>
    private let completion: ([String: String]) -> Void

    private lazy var emptyItem: State.Item = {
        State.Item(title: Strings.AlternativePaymentData.emptyMessage, subtitle: nil, remove: nil)
    }()

    private var additionalData: [String: String] {
        didSet { additionalDataDidChange() }
    }

    // MARK: - Private Methods

    private func additionalDataDidChange() {
        guard case .started = state else {
            return
        }
        let items: [State.Item]
        if additionalData.isEmpty {
            items = [emptyItem]
        } else {
            items = additionalData.sorted { $0.key > $1.key } .map { key, value in
                State.Item(title: key, subtitle: value) { [weak self] in
                    self?.additionalData[key] = nil
                }
            }
        }
        let startedState = State.Started(items: items)
        state = .started(startedState)
    }
}
