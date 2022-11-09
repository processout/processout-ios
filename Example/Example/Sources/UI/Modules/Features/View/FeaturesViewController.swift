//
//  FeaturesViewController.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import UIKit

final class FeaturesViewController<ViewModel: FeaturesViewModelType>:
    ViewController<ViewModel>, UICollectionViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        navigationItem.title = Strings.Features.title
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

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = collectionViewDataSource.itemIdentifier(for: indexPath)
        item?.select()
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    // MARK: - Private Nested Types

    private enum SectionIdentifier: Hashable {
        case `default`
    }

    private typealias ItemIdentifier = ViewModel.State.Feature

    // MARK: - Private Properties

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
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
        snapshot.appendItems(state.features, toSection: .default)
        collectionViewDataSource.apply(snapshot)
    }

    private func cell(for item: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let registration = FeaturesFeatureCell.registration
        return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
    }

    private func configureCollectionView() {
        _ = collectionViewDataSource
        _ = FeaturesFeatureCell.registration
    }
}
