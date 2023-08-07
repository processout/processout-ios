//
//  CardTokenizationViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

// swiftlint:disable type_body_length file_length

import UIKit

final class CardTokenizationViewController<ViewModel: CardTokenizationViewModel>:
    BaseViewController<ViewModel>,
    CollectionViewDelegateCenterLayout,
    CardTokenizationCellDelegate {

    init(viewModel: ViewModel, style: POCardTokenizationStyle, logger: POLogger) {
        self.style = style
        self.logger = logger
        keyboardHeight = 0
        didAppear = false
        super.init(viewModel: viewModel, logger: logger)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        configureCollectionView()
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        updateFirstResponder()
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = style.backgroundColor
        view.addSubview(collectionView)
        view.addSubview(collectionOverlayView)
        collectionOverlayView.addSubview(buttonsContainerView)
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionOverlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonsContainerView.leadingAnchor.constraint(equalTo: collectionOverlayView.leadingAnchor),
            buttonsContainerView.centerXAnchor.constraint(equalTo: collectionOverlayView.centerXAnchor),
            buttonsContainerView.bottomAnchor.constraint(equalTo: collectionOverlayView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func traitCollectionDidChange(_ previousTrait: UITraitCollection?) {
        super.traitCollectionDidChange(previousTrait)
        guard traitCollection.preferredContentSizeCategory != previousTrait?.preferredContentSizeCategory else {
            return
        }
        configure(with: viewModel.state, reload: true, animated: false)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        configureCollectionViewBottomInset(state: viewModel.state)
        collectionViewLayout.invalidateLayout()
    }

    // MARK: - BaseViewController

    override func configure(with state: ViewModel.State, animated: Bool) {
        super.configure(with: state, animated: animated)
        configureCollectionViewBottomInset(state: state)
        configure(with: state, reload: false, animated: animated)
    }

    override func keyboardWillChange(newHeight: CGFloat) {
        super.keyboardWillChange(newHeight: newHeight)
        collectionView.performBatchUpdates {
            self.keyboardHeight = newHeight
            self.configureCollectionViewBottomInset(state: self.viewModel.state)
        }
        buttonsContainerView.additionalBottomSafeAreaInset = newHeight
        collectionOverlayView.layoutIfNeeded()
    }

    // MARK: - CollectionViewDelegateCenterLayout

    func centeredSection(layout: UICollectionViewLayout) -> Int? {
        nil
    }

    func collectionViewLayout(_ layout: UICollectionViewLayout, shouldSeparateCellAt indexPath: IndexPath) -> Bool {
        if case .title = collectionViewDataSource.itemIdentifier(for: indexPath) {
            return true
        }
        return false
    }

    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? CardTokenizationCell
        cell?.willDisplay()
    }

    func collectionView(
        _: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath
    ) {
        let cell = cell as? CardTokenizationCell
        cell?.didEndDisplaying()
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let adjustedBounds = collectionView.bounds.inset(by: collectionView.adjustedContentInset)
        let height: CGFloat
        var width = adjustedBounds.width
        switch collectionViewDataSource.itemIdentifier(for: indexPath) {
        case .title(let item):
            height = collectionReusableViewSizeProvider.systemLayoutSize(
                viewType: CardTokenizationTitleCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(item: item, style: self.style.title)
                }
            ).height
        case .error(let item):
            height = collectionReusableViewSizeProvider.systemLayoutSize(
                viewType: CardTokenizationErrorCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(item: item, style: self.style.errorDescription)
                }
            ).height
        case .input(let item):
            if item.isCompact {
                width = (width - Constants.itemsSpacing) / 2
            }
            height = Constants.inputHeight
        case nil:
            height = .zero
        }
        return CGSize(width: width, height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sectionIdentifier = collectionViewDataSource.snapshot().sectionIdentifiers[section]
        guard let sectionTitle = sectionIdentifier.title else {
            return .zero
        }
        let width = collectionView.bounds.inset(by: collectionView.adjustedContentInset).width
        return collectionReusableViewSizeProvider.systemLayoutSize(
            viewType: CardTokenizationSectionHeaderView.self,
            preferredWidth: width,
            configure: { [self] view in
                view.configure(item: sectionTitle, style: style.sectionTitle)
            }
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let snapshot = collectionViewDataSource.snapshot()
        var sectionInset = Constants.sectionInset
        if snapshot.sectionIdentifiers[section].title == nil {
            // Top inset purpose is to add spacing between header and items,
            // for sections without header instead is 0
            sectionInset.top = 0
        }
        if section + 1 == snapshot.numberOfSections {
            // Bottom inset purpose is to add spacing between sections, it's
            // not needed in last section.
            sectionInset.bottom = 0
        }
        return sectionInset
    }

    // MARK: - Scroll View Delegate

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateFirstResponder()
    }

    // MARK: - CardTokenizationCellDelegate

    func cardTokenizationCellShouldReturn(_ cell: CardTokenizationCell) -> Bool {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        guard let indexPath = collectionView.indexPath(for: cell),
              let nextIndex = visibleIndexPaths.firstIndex(of: indexPath)?.advanced(by: 1),
              visibleIndexPaths.indices.contains(nextIndex) else {
            viewModel.submit()
            return true
        }
        for indexPath in visibleIndexPaths.suffix(from: nextIndex) {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CardTokenizationCell,
                  let responder = cell.inputResponder else {
                continue
            }
            if responder.becomeFirstResponder() {
                collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
            return true
        }
        viewModel.submit()
        return true
    }

    // MARK: - Private Nested Types

    private typealias SectionIdentifier = ViewModel.State.SectionIdentifier
    private typealias ItemIdentifier = ViewModel.State.Item

    // MARK: - Private Properties

    private let style: POCardTokenizationStyle
    private let logger: POLogger

    private lazy var collectionOverlayView: UIView = {
        let view = PassthroughView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var buttonsContainerView = ActionsContainerView(
        style: style.actions, horizontalInset: Constants.contentInset.left
    )

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = nil
        collectionView.contentInset = Constants.contentInset
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private lazy var collectionViewLayout: CollectionViewCenterLayout = {
        let layout = CollectionViewCenterLayout()
        layout.minimumLineSpacing = Constants.itemsSpacing
        layout.minimumInteritemSpacing = Constants.itemsSpacing
        return layout
    }()

    private lazy var collectionReusableViewSizeProvider = CollectionReusableViewSizeProvider()

    private lazy var collectionViewDataSource: CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> = {
        let dataSource = CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>(
            collectionView: collectionView,
            cellProvider: { [unowned self] _, indexPath, itemIdentifier in
                cell(for: itemIdentifier, at: indexPath)
            }
        )
        dataSource.supplementaryViewProvider = { [unowned self] _, kind, indexPath in
            supplementaryView(ofKind: kind, at: indexPath)
        }
        return dataSource
    }()

    private var keyboardHeight: CGFloat
    private var didAppear: Bool

    // MARK: - State Management

    /// - Parameters:
    ///   - reload: Allows to force reload even if new data source is not different from current. This is useful if data
    ///    didn't change but its known that content should change due to external conditions e.g. updated
    ///    traitCollection.
    private func configure(with state: ViewModel.State, reload: Bool, animated: Bool) {
        var snapshot = DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections(state.sections.map(\.id))
        for section in state.sections {
            snapshot.appendItems(section.items, toSection: section.id)
        }
        if reload {
            snapshot.reloadSections(collectionViewDataSource.snapshot().sectionIdentifiers)
        }
        collectionViewDataSource.apply(snapshot, animatingDifferences: animated) { [weak self] in
            self?.updateFirstResponder()
        }
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            buttonsContainerView.configure(viewModel: state.actions, animated: animated)
            collectionOverlayView.layoutIfNeeded()
        }
    }

    // MARK: - Current Responder Handling

    private func updateFirstResponder() {
        // Becoming first responder may cause UI issues related to keyboard presentation if attempted
        // before view appears on screen. For example, during a push to UINavigationController. So
        // the operation is delayed until then.
        guard didAppear else {
            return
        }
        if !viewModel.state.isEditingAllowed {
            logger.debug("Editing is not allowed in current state, will resign first responder")
            view.endEditing(true)
            return
        }
        let isEditing = collectionView.indexPathsForVisibleItems.contains { indexPath in
            let cell = collectionView.cellForItem(at: indexPath) as? CardTokenizationCell
            return cell?.inputResponder?.isFirstResponder == true
        }
        guard !isEditing, let indexPath = indexPathForFutureFirstResponderCell() else {
            return
        }
        if collectionView.indexPathsForVisibleItems.contains(indexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as? CardTokenizationCell
            cell?.inputResponder?.becomeFirstResponder()
        }
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }

    private func indexPathForFutureFirstResponderCell() -> IndexPath? {
        let snapshot = collectionViewDataSource.snapshot()
        var inputsIndexPaths: [IndexPath] = []
        for (section, sectionId) in snapshot.sectionIdentifiers.enumerated() {
            for (row, item) in snapshot.itemIdentifiers(inSection: sectionId).enumerated() {
                guard case .input(let inputItem) = item else {
                    continue
                }
                let indexPath = IndexPath(row: row, section: section)
                if inputItem.value.isInvalid {
                    return indexPath
                }
                inputsIndexPaths.append(indexPath)
            }
        }
        return inputsIndexPaths.first
    }

    // MARK: -

    private func configureCollectionView() {
        _ = collectionViewDataSource
        collectionView.registerSupplementaryView(
            CardTokenizationSectionHeaderView.self, kind: UICollectionView.elementKindSectionHeader
        )
        collectionView.registerSupplementaryView(
            CardTokenizationSeparatorView.self,
            kind: CollectionViewCenterLayout.elementKindSeparator
        )
        collectionView.registerCell(CardTokenizationTitleCell.self)
        collectionView.registerCell(CardTokenizationInputCell.self)
        collectionView.registerCell(CardTokenizationErrorCell.self)
    }

    private func cell(for item: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell? {
        switch item {
        case .title(let item):
            let cell = collectionView.dequeueReusableCell(CardTokenizationTitleCell.self, for: indexPath)
            cell.configure(item: item, style: style.title)
            return cell
        case .input(let item):
            let cell = collectionView.dequeueReusableCell(CardTokenizationInputCell.self, for: indexPath)
            cell.configure(item: item, style: style.input)
            cell.delegate = self
            return cell
        case .error(let item):
            let cell = collectionView.dequeueReusableCell(CardTokenizationErrorCell.self, for: indexPath)
            cell.configure(item: item, style: style.errorDescription)
            return cell
        }
    }

    private func supplementaryView(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        guard let sectionIdentifier = collectionViewDataSource.sectionIdentifier(for: indexPath.section) else {
            return nil
        }
        switch kind {
        case CollectionViewCenterLayout.elementKindSeparator:
            let view = collectionView.dequeueReusableSupplementaryView(
                CardTokenizationSeparatorView.self, kind: kind, indexPath: indexPath
            )
            view.configure(color: style.separatorColor)
            return view
        case UICollectionView.elementKindSectionHeader:
            guard let sectionTitle = sectionIdentifier.title else {
                return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(
                CardTokenizationSectionHeaderView.self, kind: kind, indexPath: indexPath
            )
            view.configure(item: sectionTitle, style: style.sectionTitle)
            return view
        default:
            return nil
        }
    }

    private func configureCollectionViewBottomInset(state: ViewModel.State) {
        let bottomInset = Constants.contentInset.bottom
            + keyboardHeight
            + buttonsContainerView.contentHeight(viewModel: state.actions)
        if bottomInset != collectionView.contentInset.bottom {
            collectionView.contentInset.bottom = bottomInset
        }
    }
}

private enum Constants {
    static let animationDuration: TimeInterval = 0.25
    static let itemsSpacing: CGFloat = 8
    static let sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
    static let contentInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
    static let inputHeight: CGFloat = 44
}

// swiftlint:enable type_body_length file_length
