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
    CollectionViewDelegateCenterLayout,
    NativeAlternativePaymentMethodCellDelegate {

    init(viewModel: ViewModel, style: PONativeAlternativePaymentMethodStyle, logger: POLogger) {
        self.style = style
        self.logger = logger
        keyboardHeight = 0
        super.init(viewModel: viewModel, logger: logger)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        configureCollectionView()
        super.viewDidLoad()
    }

    override func loadView() {
        view = UIView()
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

    override func configure(with state: ViewModel.State, animated: Bool) {
        super.configure(with: state, animated: animated)
        configureCollectionViewBottomInset(state: state)
        switch state {
        case .idle:
            configureWithIdleState()
        case .started(let startedState):
            configure(with: startedState, animated: animated)
        }
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
        let snapshot = collectionViewDataSource.snapshot()
        for (section, sectionId) in snapshot.sectionIdentifiers.enumerated() {
            for item in snapshot.itemIdentifiers(inSection: sectionId) {
                switch item {
                case .loader, .codeInput, .input, .picker, .radio:
                    return section
                default:
                    break
                }
            }
        }
        return nil
    }

    func collectionViewLayout(_ layout: UICollectionViewLayout, shouldSeparateCellAt indexPath: IndexPath) -> Bool {
        switch collectionViewDataSource.itemIdentifier(for: indexPath) {
        case .title:
            return true
        default:
            return false
        }
    }

    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? NativeAlternativePaymentMethodCell
        cell?.willDisplay()
    }

    func collectionView(
        _: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath
    ) {
        let cell = cell as? NativeAlternativePaymentMethodCell
        cell?.didEndDisplaying()
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
                    cell.configure(item: item, style: self.style.title)
                }
            ).height
        case .error(let item):
            height = collectionReusableViewSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodErrorCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(item: item, style: self.style.errorDescription)
                }
            ).height
        case .submitted(let item):
            height = collectionReusableViewSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodSubmittedCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    let style = NativeAlternativePaymentMethodSubmittedCellStyle(
                        title: self.style.title, message: self.style.message, successMessage: self.style.successMessage
                    )
                    cell.configure(item: item, style: style)
                }
            ).height
        case .input, .codeInput, .picker:
            height = Constants.inputHeight
        case .radio(let item):
            height = collectionReusableViewSizeProvider.systemLayoutSize(
                viewType: NativeAlternativePaymentMethodRadioCell.self,
                preferredWidth: adjustedBounds.width,
                configure: { cell in
                    cell.configure(item: item, style: self.style.radioButton)
                }
            ).height
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
        guard let sectionHeader = sectionIdentifier.header else {
            return .zero
        }
        let width = collectionView.bounds.inset(by: collectionView.adjustedContentInset).width
        return collectionReusableViewSizeProvider.systemLayoutSize(
            viewType: NativeAlternativePaymentMethodSectionHeaderView.self,
            preferredWidth: width,
            configure: { [self] view in
                view.configure(item: sectionHeader, style: style.sectionTitle)
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
        if snapshot.sectionIdentifiers[section].header == nil {
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

    func collectionView(
        _ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        if let identifier = collectionViewDataSource.sectionIdentifier(for: section), identifier.isTight {
            return Constants.tightLineSpacing
        }
        return Constants.lineSpacing
    }

    // MARK: - Scroll View Delegate

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

    private let style: PONativeAlternativePaymentMethodStyle
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

    private lazy var collectionViewLayout = CollectionViewCenterLayout()
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

    // MARK: - State Management

    private func configureWithIdleState() {
        buttonsContainerView.configure(viewModel: .init(primary: nil, secondary: nil), animated: false)
        let snapshot = DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        collectionViewDataSource.applySnapshotUsingReloadData(snapshot)
        view.backgroundColor = style.background.regular
    }

    /// - Parameters:
    ///   - reload: Allows to force reload even if new data source is not different from current. This is useful if data
    ///    didn't change but its known that content should change due to external conditions e.g. updated
    ///    traitCollection.
    private func configure(with state: ViewModel.State.Started, reload: Bool = false, animated: Bool) {
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
            view.backgroundColor = state.isCaptured ? style.background.success : style.background.regular
            buttonsContainerView.configure(viewModel: state.actions, animated: animated)
            collectionOverlayView.layoutIfNeeded()
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
            NativeAlternativePaymentMethodSeparatorView.self,
            kind: CollectionViewCenterLayout.elementKindSeparator
        )
        collectionView.registerCell(NativeAlternativePaymentMethodTitleCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodLoaderCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodInputCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodCodeInputCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodErrorCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodSubmittedCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodPickerCell.self)
        collectionView.registerCell(NativeAlternativePaymentMethodRadioCell.self)
    }

    private func cell(for item: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell? {
        switch item {
        case .loader:
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodLoaderCell.self, for: indexPath)
            cell.initialize(style: style.activityIndicator)
            return cell
        case .title(let item):
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodTitleCell.self, for: indexPath)
            cell.configure(item: item, style: style.title)
            return cell
        case .input(let item):
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodInputCell.self, for: indexPath)
            cell.configure(item: item, style: style.input)
            cell.delegate = self
            return cell
        case .codeInput(let item):
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodCodeInputCell.self, for: indexPath
            )
            cell.configure(item: item, style: style.codeInput)
            cell.delegate = self
            return cell
        case .error(let item):
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodErrorCell.self, for: indexPath)
            cell.configure(item: item, style: style.errorDescription)
            return cell
        case .submitted(let item):
            let cell = collectionView.dequeueReusableCell(
                NativeAlternativePaymentMethodSubmittedCell.self, for: indexPath
            )
            let style = NativeAlternativePaymentMethodSubmittedCellStyle(
                title: style.title, message: style.message, successMessage: style.successMessage
            )
            cell.configure(item: item, style: style)
            return cell
        case .picker(let item):
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodPickerCell.self, for: indexPath)
            cell.configure(item: item, style: style.input)
            return cell
        case .radio(let item):
            let cell = collectionView.dequeueReusableCell(NativeAlternativePaymentMethodRadioCell.self, for: indexPath)
            cell.configure(item: item, style: style.radioButton)
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
                NativeAlternativePaymentMethodSeparatorView.self, kind: kind, indexPath: indexPath
            )
            view.configure(color: style.separatorColor)
            return view
        case UICollectionView.elementKindSectionHeader:
            guard let sectionHeader = sectionIdentifier.header else {
                return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(
                NativeAlternativePaymentMethodSectionHeaderView.self, kind: kind, indexPath: indexPath
            )
            view.configure(item: sectionHeader, style: style.sectionTitle)
            return view
        default:
            return nil
        }
    }

    /// Adjusts bottom inset based on current state actions and keyboard height.
    private func configureCollectionViewBottomInset(state: ViewModel.State) {
        // todo(andrii-vysotskyi): consider observing overlay content height instead for better flexibility in future
        var bottomInset = Constants.contentInset.bottom + keyboardHeight
        if case .started(let startedState) = state {
            bottomInset += buttonsContainerView.contentHeight(viewModel: startedState.actions)
        }
        if bottomInset != collectionView.contentInset.bottom {
            collectionView.contentInset.bottom = bottomInset
        }
    }
}

private enum Constants {
    static let animationDuration: TimeInterval = 0.25
    static let lineSpacing: CGFloat = 8
    static let tightLineSpacing: CGFloat = 4
    static let sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
    static let contentInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
    static let inputHeight: CGFloat = 44
    static let loaderHeight: CGFloat = 256
}

// swiftlint:enable type_body_length file_length
