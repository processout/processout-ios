//
//  NativeAlternativePaymentMethodViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

// swiftlint:disable type_body_length file_length

import UIKit

final class NativeAlternativePaymentMethodViewController<ViewModel: NativeAlternativePaymentMethodViewModel>:
    BaseViewController<ViewModel>,
    NativeAlternativePaymentMethodCollectionLayoutDelegate,
    NativeAlternativePaymentMethodCellDelegate {

    init(viewModel: ViewModel, style: PONativeAlternativePaymentMethodStyle?, logger: POLogger) {
        self.style = style
        self.logger = logger
        keyboardHeight = 0
        super.init(viewModel: viewModel, logger: logger)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        configureCollectionView()
        super.viewDidLoad()
        observeKeyboardChanges()
        observeScrollViewContentSizeChanges()
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = style?.backgroundColor ?? Constants.defaultBackgroundColor
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory,
              case .started(let startedState) = viewModel.state else {
            return
        }
        configure(with: startedState, reload: true, animated: false)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        configureCollectionViewBottomInset(state: viewModel.state)
        collectionViewLayout.invalidateLayout()
    }

    // MARK: - BaseViewController

    override func configure(with state: ViewModel.State) {
        super.configure(with: state)
        configureCollectionViewBottomInset(state: state)
        switch state {
        case .idle:
            configureWithIdleState()
        case .started(let startedState):
            configure(with: startedState)
        }
    }

    // MARK: - NativeAlternativePaymentMethodCollectionLayoutDelegate

    func centeredSection(layout: UICollectionViewLayout) -> Int? {
        let snapshot = collectionViewDataSource.snapshot()
        for (section, sectionId) in snapshot.sectionIdentifiers.enumerated() {
            for item in snapshot.itemIdentifiers(inSection: sectionId) {
                switch item {
                case .codeInput, .input, .picker, .loader:
                    return section
                default:
                    break
                }
            }
        }
        return nil
    }

    func collectionViewLayout(_ layout: UICollectionViewLayout, shouldDecorateSectionAt index: Int) -> Bool {
        collectionViewDataSource.sectionIdentifier(for: index)?.decoration != nil
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // todo(andrii-vysotskyo): consider migrating to self-sizing to evict boilerplate sizing code
        let adjustedBounds = collectionView.bounds.inset(by: collectionView.adjustedContentInset)
        let height: CGFloat
        switch collectionViewDataSource.itemIdentifier(for: indexPath) {
        case .loader:
            height = Constants.loaderHeight
        case .title(let item):
            height = collectionReusableViewSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodTitleCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(item: item, style: self.style?.title)
                }
            ).height
        case .error(let item):
            height = collectionReusableViewSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodErrorCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(item: item, style: self.style?.input?.error.description)
                }
            ).height
        case .submitted(let item):
            height = collectionReusableViewSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodSubmittedCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(
                        item: item,
                        style: .init(message: self.style?.message, successMessage: self.style?.successMessage)
                    )
                }
            ).height
        case .input, .codeInput, .picker:
            height = Constants.inputHeight
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
        return collectionReusableViewSizeProvider.systemLayoutSize(
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureButtonsContainerShadow()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateFirstResponder()
    }

    // MARK: - NativeAlternativePaymentMethodCellDelegate

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

    // MARK: - Private Nested Types

    private typealias SectionIdentifier = ViewModel.State.SectionIdentifier
    private typealias ItemIdentifier = ViewModel.State.Item

    // MARK: - Private Properties

    private let style: PONativeAlternativePaymentMethodStyle?
    private let logger: POLogger

    private lazy var collectionOverlayView: UIView = {
        let view = PassthroughView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = nil
        collectionView.contentInset = Constants.contentInset
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = NativeAlternativePaymentMethodCollectionLayout()
        layout.minimumLineSpacing = Constants.lineSpacing
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

    private var scrollViewContentSizeObservation: NSKeyValueObservation?
    private var keyboardChangesObserver: NSObjectProtocol?
    private var keyboardHeight: CGFloat

    // MARK: - State Management

    private func configureWithIdleState() {
        buttonsContainerView.alpha = 0
        let snapshot = DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        collectionViewDataSource.applySnapshotUsingReloadData(snapshot)
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
        collectionViewDataSource.apply(snapshot, animatingDifferences: animated) { [weak self] in
            self?.updateFirstResponder()
        }
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            if let actions = state.actions {
                buttonsContainerView.configure(actions: actions, animated: buttonsContainerView.alpha > 0 && animated)
                buttonsContainerView.alpha = 1
            } else {
                buttonsContainerView.alpha = 0
            }
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
        }
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }

    private func indexPathForFutureFirstResponderCell() -> IndexPath? {
        let snapshot = collectionViewDataSource.snapshot()
        var inputsIndexPaths: [IndexPath] = []
        for (section, sectionId) in snapshot.sectionIdentifiers.enumerated() {
            for (row, item) in snapshot.itemIdentifiers(inSection: sectionId).enumerated() {
                let isInvalid: Bool
                switch item {
                case .input(let inputItem):
                    isInvalid = inputItem.value.isInvalid
                case .codeInput(let inputItem):
                    isInvalid = inputItem.value.isInvalid
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
        collectionView.registerSupplementaryView(
            NativeAlternativePaymentMethodSectionDecorationView.self,
            kind: NativeAlternativePaymentMethodCollectionLayout.elementKindSectionBackground
        )
        collectionView.registerCell(NativeAlternativePaymentMethodTitleCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodLoaderCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodInputCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodCodeInputCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodErrorCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodSubmittedCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodPickerCell.self)
    }

    private func cell(for item: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell? {
        switch item {
        case .loader:
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodLoaderCell.self, for: indexPath)
            cell.initialize(style: style?.activityIndicator)
            return cell
        case .title(let item):
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodTitleCell.self, for: indexPath)
            cell.configure(item: item, style: style?.title)
            return cell
        case .input(let item):
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodInputCell.self, for: indexPath)
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
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodErrorCell.self, for: indexPath)
            cell.configure(item: item, style: style?.input?.error.description)
            return cell
        case .submitted(let item):
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodSubmittedCell.self, for: indexPath
            )
            cell.configure(item: item, style: .init(message: style?.message, successMessage: style?.successMessage))
            return cell
        case .picker(let item):
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodPickerCell.self, for: indexPath)
            cell.configure(item: item, style: style?.input)
            return cell
        }
    }

    private func supplementaryView(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        guard let sectionIdentifier = collectionViewDataSource.sectionIdentifier(for: indexPath.section) else {
            return nil
        }
        switch kind {
        case NativeAlternativePaymentMethodCollectionLayout.elementKindSectionBackground:
            guard let decoration = sectionIdentifier.decoration else {
                return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(
                NativeAlternativePaymentMethodSectionDecorationView.self, kind: kind, indexPath: indexPath
            )
            view.configure(item: decoration, style: style?.backgroundDecoration)
            return view
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(
                NativeAlternativePaymentMethodSectionHeaderView.self, kind: kind, indexPath: indexPath
            )
            view.configure(item: sectionIdentifier, style: style?.input?.normal.title)
            return view
        default:
            return nil
        }
    }

    // MARK: - Keyboard Handling

    private func observeKeyboardChanges() {
        keyboardChangesObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.keyboardWillChangeFrame(notification: notification)
            }
        )
    }

    private func keyboardWillChangeFrame(notification: Notification) {
        guard let notification = KeyboardNotification(notification: notification) else {
            return
        }
        // Keyboard updates are not always animated so defaults are provided for smoother UI.
        let animator = UIViewPropertyAnimator(
            duration: notification.animationDuration ?? Constants.animationDuration,
            curve: notification.animationCurve ?? .easeInOut,
            animations: { [self] in
                let coveredSafeAreaHeight = view.bounds.height
                    - view.convert(notification.frameEnd, from: nil).minY
                    - view.safeAreaInsets.bottom
                let keyboardHeight = max(coveredSafeAreaHeight, 0)
                guard self.keyboardHeight != keyboardHeight else {
                    return
                }
                collectionView.performBatchUpdates {
                    self.keyboardHeight = keyboardHeight
                    self.configureCollectionViewBottomInset(state: self.viewModel.state)
                }
                buttonsContainerView.additionalBottomSafeAreaInset = keyboardHeight
                collectionOverlayView.layoutIfNeeded()
            }
        )
        // An implementation of `UICollectionView.performBatchUpdates` resigns first responder if item associated
        // with a cell containing it is invalidated, for example moved, deleted or reloaded. And since keyboard
        // notification is sent as part of resign operation, we shouldn't call `performBatchUpdates` directly here
        // to avoid recursion which causes weird artifacts and inconsistency. To break it, keyboard animation info
        // is extracted from notification and update is scheduled for next run loop iteration. Collection layout
        // update is needed here in a first place because layout depends on inset, which transitively depends on
        // keyboard visibility.
        RunLoop.current.perform(animator.startAnimation)
    }

    /// Adjusts bottom inset based on current state actions and keyboard height.
    private func configureCollectionViewBottomInset(state: ViewModel.State) {
        // todo(andrii-vysotskyi): consider observing overlay content height instead for better flexibility in future
        var bottomInset = Constants.contentInset.bottom + keyboardHeight
        if case .started(let startedState) = state {
            if let actions = startedState.actions {
                if actions.primary != nil, actions.secondary != nil {
                    bottomInset += Constants.overlayLargeContentHeight
                } else if actions.primary != nil || actions.secondary != nil {
                    bottomInset += Constants.overlaySmallContentHeight
                }
            }
        }
        if bottomInset != collectionView.contentInset.bottom {
            collectionView.contentInset.bottom = bottomInset
        }
    }

    // MARK: - Action Buttons Shadow

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
        let threshold = Constants.contentInset.bottom
        let shadowOpacity = max(min(1, (minimumContentOffset - collectionView.contentOffset.y) / threshold), 0)
        buttonsContainerView.apply(style: style?.buttonsContainerShadow ?? .`default`, shadowOpacity: shadowOpacity)
    }
}

private enum Constants {
    static let defaultBackgroundColor = Asset.Colors.Background.primary.color
    static let animationDuration: TimeInterval = 0.25
    static let overlayLargeContentHeight: CGFloat = 160
    static let overlaySmallContentHeight: CGFloat = 96
    static let lineSpacing: CGFloat = 8
    static let sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
    static let contentInset = UIEdgeInsets(top: 4, left: 24, bottom: 16, right: 24)
    static let inputHeight: CGFloat = 48
    static let loaderHeight: CGFloat = 128
}

// swiftlint:enable type_body_length file_length
