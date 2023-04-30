//
//  BetaNativeAlternativePaymentMethodViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

// swiftlint:disable type_body_length file_length

import UIKit

final class BetaNativeAlternativePaymentMethodViewController<ViewModel: BetaNativeAlternativePaymentMethodViewModel>:
    BaseViewController<ViewModel>,
    BetaNativeAlternativePaymentMethodCollectionLayoutDelegate,
    BetaNativeAlternativePaymentMethodCellDelegate {

    init(viewModel: ViewModel, style: PONativeAlternativePaymentMethodStyle?, logger: POLogger) {
        self.style = style
        self.logger = logger
        notificationObservers = []
        super.init(viewModel: viewModel)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        configureCollectionView()
        super.viewDidLoad()
        observeNotifications()
        observeScrollViewContentSizeChanges()
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = style?.backgroundColor ?? Constants.defaultBackgroundColor
        view.addSubview(collectionView)
        view.addSubview(buttonsContainerView)
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory,
              case .started(let startedState) = viewModel.state else {
            return
        }
        configure(with: startedState, reload: true, animated: false)
    }

    // MARK: - CollectionViewDelegateBetaNativeAlternativePaymentMethodLayout

    func centeredSection(
        in collectionView: UICollectionView, layout: BetaNativeAlternativePaymentMethodCollectionLayout
    ) -> Int? {
        let snapshot = collectionViewDataSource.snapshot()
        for (section, sectionId) in snapshot.sectionIdentifiers.enumerated() {
            for item in snapshot.itemIdentifiers(inSection: sectionId) {
                switch item {
                case .codeInput, .input:
                    return section
                default:
                    break
                }
            }
        }
        return nil
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let adjustedBounds = collectionView.bounds.inset(by: collectionView.adjustedContentInset)
        let height: CGFloat
        switch collectionViewDataSource.itemIdentifier(for: indexPath) {
        case .loader:
            height = adjustedBounds.height
        case .title(let item):
            height = collectionCellSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodTitleCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(item: item, style: self.style?.title)
                }
            ).height
        case .error(let item):
            height = collectionCellSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodErrorCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(item: item, style: self.style?.input?.error.description)
                }
            ).height
        case .submitted(let item):
            height = collectionCellSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodSubmittedCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(
                        item: item,
                        style: .init(message: self.style?.message, successMessage: self.style?.successMessage)
                    )
                }
            ).height
        case .input, .codeInput:
            height = 48
        case nil:
            height = .zero
        }
        return CGSize(width: adjustedBounds.width, height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sectionIdentifier = collectionViewDataSource.snapshot().sectionIdentifiers[section]
        guard sectionIdentifier.title != nil else {
            return .zero
        }
        let width = collectionView.bounds.inset(by: collectionView.adjustedContentInset).width
        return collectionCellSizeProvider.systemLayoutSize(
            viewType: NativeAlternativePaymentMethodSectionHeaderView.self,
            preferredWidth: width,
            configure: { [self] view in
                view.configure(item: sectionIdentifier, style: style?.input?.normal.title)
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
            sectionInset.top = 0
        }
        if section + 1 == snapshot.numberOfSections {
            sectionInset.bottom = 0
        }
        return sectionInset
    }

    // MARK: - Scroll View Delegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureButtonsContainerShadow()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateFirstResponder()
    }

    // MARK: - BetaNativeAlternativePaymentMethodInputCellDelegate

    func nativeAlternativePaymentMethodCellShouldReturn(_ cell: NativeAlternativePaymentMethodCell) -> Bool {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        guard let indexPath = collectionView.indexPath(for: cell),
              let nextIndex = visibleIndexPaths.firstIndex(of: indexPath)?.advanced(by: 1),
              visibleIndexPaths.indices.contains(nextIndex) else {
            viewModel.submit()
            return true
        }
        for indexPath in visibleIndexPaths.suffix(from: nextIndex) {
            guard let cell = collectionView.cellForItem(at: indexPath) as? NativeAlternativePaymentMethodCell,
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

    // MARK: - BaseViewController

    override func configure(with state: ViewModel.State) {
        logger.debug("Will update with new state: \(String(describing: state))")
        switch state {
        case .idle:
            configureWithIdleState()
        case .started(let startedState):
            configure(with: startedState)
        }
    }

    // MARK: - Private Nested Types

    private typealias SectionIdentifier = ViewModel.State.SectionIdentifier
    private typealias ItemIdentifier = ViewModel.State.Item

    // MARK: - Private Properties

    private let style: PONativeAlternativePaymentMethodStyle?
    private let logger: POLogger

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = style?.backgroundColor ?? Constants.defaultBackgroundColor
        return collectionView
    }()

    private lazy var collectionViewLayout = BetaNativeAlternativePaymentMethodCollectionLayout()
    private lazy var collectionCellSizeProvider = CollectionReusableViewSizeProvider()

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

    private lazy var buttonsContainerView: NativeAlternativePaymentMethodButtonsView = {
        let style = NativeAlternativePaymentMethodButtonsViewStyle(
            primaryButton: style?.primaryButton ?? .primary,
            secondaryButton: style?.secondaryButton ?? .secondary
        )
        let view = NativeAlternativePaymentMethodButtonsView(
            style: style, horizontalInset: Constants.contentInset.left
        )
        view.backgroundColor = self.style?.backgroundColor ?? Constants.defaultBackgroundColor
        return view
    }()

    private var scrollViewContentSizeObservation: NSKeyValueObservation?
    private var notificationObservers: [NSObjectProtocol]

    // MARK: - State Management

    private func configureWithIdleState() {
        let snapshot = DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        collectionViewDataSource.apply(snapshot, animatingDifferences: false)
        buttonsContainerView.alpha = 0
    }

    /// - Parameters:
    ///   - reload: Allows to force reload even if new data source is not different from current. This is useful if data
    ///    didn't change but its known that content should change due to external conditions e.g. updated
    ///    traitCollection.
    private func configure(with state: ViewModel.State.Started, reload: Bool = false, animated: Bool = true) {
        var snapshot = DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections(state.sections.map(\.id))
        for section in state.sections {
            snapshot.appendItems(section.items, toSection: section.id)
        }
        if reload {
            snapshot.reloadSections(collectionViewDataSource.snapshot().sectionIdentifiers)
        }

        updateCollectionInset(state: state) // apply bellow will trigger what we want

        collectionViewDataSource.apply(snapshot, animatingDifferences: animated) { [weak self] in
            if !reload {
                self?.updateFirstResponder()
            }
        }
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            if let actions = state.actions {
                buttonsContainerView.configure(
                    primaryAction: actions.primary, secondaryAction: actions.secondary, animated: animated
                )
                buttonsContainerView.alpha = 1
            } else {
                buttonsContainerView.alpha = 0
            }
        }
    }

    private func updateCollectionInset(state: ViewModel.State.Started) {
        let bottomInset: CGFloat
        if let actions = state.actions {
            if actions.secondary != nil {
                bottomInset = 160 + 16
            } else {
                bottomInset = 96 + 16
            }
        } else {
            bottomInset = 16
        }
        if bottomInset != collectionView.contentInset.bottom {
            collectionView.contentInset.bottom = bottomInset
        }
    }

    // MARK: - Current Responder Handling

    private func updateFirstResponder() {
        if case .started(let startedState) = viewModel.state, !startedState.isEditingAllowed {
            logger.debug("Editing is not allowed in current state, will resign first responder")
            view.endEditing(true)
            return
        }
        let isEditing = collectionView.indexPathsForVisibleItems.contains { indexPath in
            let cell = collectionView.cellForItem(at: indexPath) as? NativeAlternativePaymentMethodCell
            return cell?.inputResponder?.isFirstResponder == true
        }
        guard !isEditing, let indexPath = indexPathForFutureFirstResponderCell() else {
            return
        }
        if collectionView.indexPathsForVisibleItems.contains(indexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as? NativeAlternativePaymentMethodCell
            cell?.inputResponder?.becomeFirstResponder()
        } else {
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    private func indexPathForFutureFirstResponderCell() -> IndexPath? {
        let snapshot = collectionViewDataSource.snapshot()
        var inputsIndexPaths: [IndexPath] = []
        for (section, sectionId) in snapshot.sectionIdentifiers.enumerated() {
            for (row, item) in snapshot.itemIdentifiers(inSection: sectionId).enumerated() {
                let isInvalid: Bool
                switch item {
                case .input(let inputItem):
                    isInvalid = inputItem.isInvalid
                case .codeInput(let inputItem):
                    isInvalid = inputItem.isInvalid
                default:
                    continue
                }
                let indexPath = IndexPath(row: row, section: section)
                if isInvalid {
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
            NativeAlternativePaymentMethodSectionHeaderView.self, kind: UICollectionView.elementKindSectionHeader
        )
        collectionView.registerCell(NativeAlternativePaymentMethodTitleCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodLoaderCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodInputCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodCodeInputCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodErrorCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodSubmittedCell.self)
        collectionView.contentInset = Constants.contentInset
        collectionView.showsVerticalScrollIndicator = false
        collectionViewLayout.minimumLineSpacing = Constants.lineSpacing
    }

    private func cell(for item: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell? {
        switch item {
        case .loader:
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodLoaderCell.self, for: indexPath
            )
            cell.initialize(style: style?.activityIndicator)
            return cell
        case .title(let item):
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodTitleCell.self, for: indexPath
            )
            cell.configure(item: item, style: style?.title)
            return cell
        case .input(let item):
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodInputCell.self, for: indexPath
            )
            cell.configure(item: item, style: style?.input)
            cell.delegate = self
            return cell
        case .codeInput(let item):
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodCodeInputCell.self, for: indexPath
            )
            cell.configure(item: item, style: style?.codeInput)
            cell.delegate = self
            return cell
        case .error(let item):
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodErrorCell.self, for: indexPath
            )
            cell.configure(item: item, style: style?.input?.error.description)
            return cell
        case .submitted(let item):
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodSubmittedCell.self, for: indexPath
            )
            cell.configure(
                item: item, style: .init(message: style?.message, successMessage: style?.successMessage)
            )
            return cell
        }
    }

    private func supplementaryView(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        let sectionIdentifier = collectionViewDataSource.snapshot().sectionIdentifiers[indexPath.section]
        let view = collectionView.dequeueReusableSupplementaryView(
            NativeAlternativePaymentMethodSectionHeaderView.self, kind: kind, indexPath: indexPath
        )
        view.configure(item: sectionIdentifier, style: style?.input?.normal.title)
        return view
    }

    // MARK: - Notifications

    private func observeNotifications() {
        let willChangeFrameObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                // Keyboard updates are not always animated so changes are wrapped
                // in default animation block for smoother UI.
                self?.keyboardWillChangeFrame(notification: notification)
            }
        )
        notificationObservers = [willChangeFrameObserver]
    }

    // MARK: - Keyboard Handling

    private func keyboardWillChangeFrame(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let coveredSafeAreaHeight = view.bounds.height
            - view.convert(keyboardFrame, from: nil).minY
            - view.safeAreaInsets.bottom
            + additionalSafeAreaInsets.bottom
        additionalSafeAreaInsets.bottom = max(coveredSafeAreaHeight, 0)
        view.layoutIfNeeded()
        collectionView.performBatchUpdates { } // Allows to update collection view with animation
    }

    // MARK: - Action Buttons

    private func observeScrollViewContentSizeChanges() {
        let observation = collectionView.observe(\.contentSize, options: [.old]) { [weak self] scrollView, value in
            guard scrollView.contentSize.height != value.oldValue?.height else {
                return
            }
            self?.configureButtonsContainerShadow()
        }
        scrollViewContentSizeObservation = observation
    }

    private func configureButtonsContainerShadow() {
        let minimumContentOffset = collectionView.contentSize.height
            - collectionView.bounds.height
            + collectionView.adjustedContentInset.bottom
        let threshold = Constants.buttonsContainerShadowVisibilityThreshold
        let shadowOpacity = max(min(1, (minimumContentOffset - collectionView.contentOffset.y) / threshold), 0)
        buttonsContainerView.apply(style: style?.buttonsContainerShadow ?? .`default`, shadowOpacity: shadowOpacity)
    }
}

private enum Constants {
    static let defaultBackgroundColor = Asset.Colors.Background.primary.color
    static let animationDuration: TimeInterval = 0.25
    static let buttonsContainerShadowVisibilityThreshold: CGFloat = 32 // swiftlint:disable:this identifier_name
    static let lineSpacing: CGFloat = 8
    static let sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
    static let contentInset = UIEdgeInsets(top: 4, left: 24, bottom: 0, right: 24)
}

// todo: add background decoration to loader and submitted cells
// todo: move needed classes from legacy to new view

// swiftlint:enable type_body_length file_length
