//
//  AlternativePaymentMethodsViewController.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import UIKit

final class AlternativePaymentMethodsViewController<ViewModel: AlternativePaymentMethodsViewModelType>:
    ViewController<ViewModel>, UICollectionViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        navigationItem.title = String(localized: .AlternativePayments.title)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
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
        if case .configuration(let item) = item {
            item.select()
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let item = collectionViewDataSource.itemIdentifier(for: indexPath)
        if case .configuration = item {
            return true
        }
        return false
    }

    func collectionView(
        _ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath
    ) {
        assert(indexPath.section == 0, "Items are expected to be in one section.")
        guard indexPath.row + 10 >= collectionViewDataSource.snapshot().numberOfItems else {
            return
        }
        viewModel.loadMore()
    }

    // MARK: - Private Nested Types

    private enum SectionIdentifier: Hashable {
        case `default`
    }

    private typealias ItemIdentifier = ViewModel.State.Item

    // MARK: - Private Properties

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
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

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshControlValueDidChange), for: .valueChanged)
        return control
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Private Methods

    private func configureWithIdleState() {
        refreshControl.endRefreshing()
        activityIndicatorView.stopAnimating()
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections([.default])
        collectionViewDataSource.apply(snapshot)
    }

    private func configure(with state: ViewModel.State.Started) {
        if state.areOperationsExecuting {
            activityIndicatorView.startAnimating()
        } else {
            refreshControl.endRefreshing()
            activityIndicatorView.stopAnimating()
        }
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections([.default])
        snapshot.appendItems(state.items, toSection: .default)
        collectionViewDataSource.apply(snapshot)
    }

    private func cell(for item: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case .configuration(let item):
            let registration = AlternativePaymentMethodsConfigurationCell.registration
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        case .failure(let item):
            let registration = AlternativePaymentMethodsFailureCell.registration
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func configureCollectionView() {
        _ = collectionViewDataSource
        _ = AlternativePaymentMethodsConfigurationCell.registration
        _ = AlternativePaymentMethodsFailureCell.registration
    }

    // MARK: -

    @objc
    private func refreshControlValueDidChange() {
        viewModel.restart()
    }
}
