//
//  CardPaymentViewController.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit
import SnapKit

final class CardPaymentViewController<ViewModel: CardPaymentViewModelType>: ViewController<ViewModel> {

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

    private typealias SectionIdentifier = ViewModel.State.SectionIdentifier
    private typealias ItemIdentifier = ViewModel.State.Parameter

    // MARK: - Private Properties

    private lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }()

    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }()

    private lazy var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> = {
        let dataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>(
            collectionView: collectionView,
            cellProvider: { [unowned self] _, indexPath, itemIdentifier in
                cell(for: itemIdentifier, at: indexPath)
            }
        )
        dataSource.supplementaryViewProvider = { [unowned self] _, kind, indexPath in
            self.supplementaryView(ofKind: kind, at: indexPath)
        }
        return dataSource
    }()

    // MARK: - Private Methods

    private func configureWithIdleState() {
        let snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        collectionViewDataSource.apply(snapshot)
    }

    private func configure(with state: ViewModel.State.Started) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections(state.sections.map(\.identifier))
        state.sections.forEach { section in
            snapshot.appendItems(section.parameters, toSection: section.identifier)
        }
        collectionViewDataSource.apply(snapshot)
    }

    private func cell(for item: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let registration = CardPaymentParameterCell.registration
        return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
    }

    private func supplementaryView(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        let sectionIdentifier: SectionIdentifier?
        if #available(iOS 15, *) {
            sectionIdentifier = collectionViewDataSource.sectionIdentifier(for: indexPath.section)
        } else {
            sectionIdentifier = collectionViewDataSource.snapshot().sectionIdentifiers[indexPath.section]
        }
        guard let sectionIdentifier else {
            return nil
        }
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueConfiguredReusableSupplementary(
                using: CardPaymentSectionHeaderView.registration, for: indexPath
            )
            view.configure(item: sectionIdentifier)
            return view
        default:
            return nil
        }
    }

    private func configureCollectionView() {
        _ = collectionViewDataSource
        _ = CardPaymentParameterCell.registration
        _ = CardPaymentSectionHeaderView.registration
    }

    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = .init(
            title: Strings.CardPayment.PayButton.title, style: .done, target: self, action: #selector(didTouchPayButton)
        )
        navigationItem.title = Strings.CardPayment.title
        navigationItem.largeTitleDisplayMode = .never
    }

    @objc
    private func didTouchPayButton() {
        viewModel.pay()
    }
}
