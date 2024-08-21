//
//  AlternativePaymentDataViewController.swift
//  Example
//
//  Created by Andrii Vysotskyi on 25.01.2023.
//

import UIKit

final class AlternativePaymentDataViewController<ViewModel: AlternativePaymentDataViewModelType>:
    ViewController<ViewModel> {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationItem()
    }

    override func loadView() {
        view = collectionView
    }

    override func configure(with state: ViewModel.State) {
        switch state {
        case .idle:
            configureWithIdleState()
        case .started(let startedState):
            configure(with: startedState)
        }
    }

    // MARK: - Private Nested Types

    private enum SectionIdentifier: Hashable {
        case `default`
    }

    private typealias ItemIdentifier = ViewModel.State.Item

    // MARK: - Private Properties

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.allowsSelection = false
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let item = self?.collectionViewDataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            if let remove = item.remove {
                let action = UIContextualAction(
                    style: .destructive,
                    title: String(localized: .AlternativePaymentData.remove),
                    handler: { _, _, completion in
                        remove()
                        completion(true)
                    }
                )
                return UISwipeActionsConfiguration(actions: [action])
            }
            return nil
        }
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }()

    private lazy var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> = {
        let dataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>(
            collectionView: collectionView,
            cellProvider: { [unowned self] _, indexPath, itemIdentifier in
                cell(for: itemIdentifier, at: indexPath)
            }
        )
        return dataSource
    }()

    // MARK: - Private Methods

    private func configureWithIdleState() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections([.default])
        collectionViewDataSource.apply(snapshot)
    }

    private func configure(with state: ViewModel.State.Started) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections([.default])
        snapshot.appendItems(state.items, toSection: .default)
        collectionViewDataSource.apply(snapshot)
    }

    private func cell(for item: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let registration = AlternativePaymentDataItemCell.registration
        return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
    }

    private func configureCollectionView() {
        _ = collectionViewDataSource
        _ = AlternativePaymentDataItemCell.registration
    }

    private func configureNavigationItem() {
        navigationItem.title = String(localized: .AlternativePaymentData.title)
        navigationItem.largeTitleDisplayMode = .never
        let submitButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: .init { [weak self] _ in
                self?.viewModel.submit()
            },
            menu: nil
        )
        let addButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: .init { [weak self] _ in
                self?.viewModel.add()
            },
            menu: nil
        )
        navigationItem.rightBarButtonItems = [submitButtonItem, addButtonItem]
    }
}
