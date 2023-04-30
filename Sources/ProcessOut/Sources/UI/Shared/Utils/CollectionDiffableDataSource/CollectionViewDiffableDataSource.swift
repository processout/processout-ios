//
//  CollectionViewDiffableDataSource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.04.2023.
//

import UIKit

/// Simplified backport of UICollectionViewDiffableDataSource that is available for older iOS versions.
final class CollectionViewDiffableDataSource<SectionIdentifier: Hashable, ItemIdentifier: Hashable>:
    NSObject, UICollectionViewDataSource {

    /// A closure that configures and returns a cell for a collection view from its diffable data source.
    typealias CellProvider = (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?

    /// A closure that configures and returns a collection view’s supplementary view, such as a header or footer,
    /// from a data source.
    typealias SupplementaryViewProvider =
        (UICollectionView, _ elementKind: String, IndexPath) -> UICollectionReusableView?

    /// The closure that configures and returns the collection view’s supplementary views, such as headers and
    /// footers, from the data source.
    var supplementaryViewProvider: SupplementaryViewProvider?

    init(collectionView: UICollectionView, cellProvider: @escaping CellProvider) {
        self.collectionView = collectionView
        self.cellProvider = cellProvider
        currentSnapshot = .init()
        super.init()
        collectionView.dataSource = self
    }

    /// Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes.
    func apply(
        _ snapshot: DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let performUpdates = {
            self.collectionView.performBatchUpdates {
                self.update(with: snapshot)
            } completion: { _ in
                completion?()
            }
        }
        if animatingDifferences {
            performUpdates()
        } else {
            UIView.performWithoutAnimation(performUpdates)
        }
    }

    func applySnapshotUsingReloadData(_ snapshot: DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>) {
        currentSnapshot = snapshot
        collectionView.reloadData()
    }

    /// Returns an identifier for the section at the index you specify in the collection view.
    func sectionIdentifier(for index: Int) -> SectionIdentifier? {
        currentSnapshot.sectionIdentifier(for: index)
    }

    /// Returns an identifier for the item at the specified index path in the collection view.
    ///
    /// This method is a constant time operation, O(1), which means you can look up an item identifier from its
    /// corresponding index path with no significant overhead.
    func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifier? {
        guard let identifier = currentSnapshot.sectionIdentifier(for: indexPath.section) else {
            return nil
        }
        let itemIdentifiers = currentSnapshot.itemIdentifiers(inSection: identifier)
        guard itemIdentifiers.indices.contains(indexPath.row) else {
            return nil
        }
        return itemIdentifiers[indexPath.row]
    }

    func snapshot() -> DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier> {
        currentSnapshot
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        currentSnapshot.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let identifier = currentSnapshot.sectionIdentifier(for: section) {
            return currentSnapshot.numberOfItems(inSection: identifier)
        }
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let itemIdentifier = itemIdentifier(for: indexPath),
              let cell = cellProvider(collectionView, indexPath, itemIdentifier) else {
            assertionFailure("Either index path is invalid or there is not cell to return.")
            return UICollectionViewCell()
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let view = supplementaryViewProvider?(collectionView, kind, indexPath) else {
            assertionFailure("No supplementary view to return.")
            return UICollectionReusableView()
        }
        return view
    }

    // MARK: - Private Nested Types

    /// Alias to DataSourceSnapshot.
    private typealias Snapshot = DiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>

    private struct Updates<Index> {

        // swiftlint:disable:next nesting
        struct Move {
            let from, to: Index // swiftlint:disable:this identifier_name
        }

        /// Removals in descending order.
        let removals: [Index]

        /// Reload operations.
        let reloads: [Index]

        /// Insertions in ascending order.
        let insertions: [Index]

        /// Moves.
        let moves: [Move]
    }

    private struct Element<Identifier: Hashable, Index: Equatable> {

        /// Item identifier.
        let identifier: Identifier

        /// Item index.
        let index: Index
    }

    // MARK: - Private Properties

    private let collectionView: UICollectionView
    private let cellProvider: CellProvider
    private var currentSnapshot: Snapshot

    // MARK: - Private Methods

    private func update(with snapshot: Snapshot) {
        let sectionUpdates = updateSections(with: snapshot)
        let itemUpdates = updates(
            from: itemElements(
                snapshot: currentSnapshot, excludedSections: IndexSet(sectionUpdates.removals)
            ),
            to: itemElements(snapshot: snapshot),
            reloadedIdentifiers: []
        )
        collectionView.deleteItems(at: itemUpdates.removals)
        collectionView.insertItems(at: itemUpdates.insertions)
        for move in itemUpdates.moves {
            collectionView.moveItem(at: move.from, to: move.to)
        }
        self.currentSnapshot = snapshot
    }

    private func updateSections(with snapshot: Snapshot) -> Updates<Int> {
        let sectionUpdates = updates(
            from: sectionElements(snapshot: currentSnapshot),
            to: sectionElements(snapshot: snapshot),
            reloadedIdentifiers: snapshot.reloadedSectionIdentifiers
        )
        collectionView.deleteSections(IndexSet(sectionUpdates.removals))
        collectionView.reloadSections(IndexSet(sectionUpdates.reloads))
        collectionView.insertSections(IndexSet(sectionUpdates.insertions))
        for move in sectionUpdates.moves {
            collectionView.moveSection(move.from, toSection: move.to)
        }
        return sectionUpdates
    }

    /// Transforms section identifiers into section/index pairs suitable for calculating difference.
    private func sectionElements(snapshot: Snapshot) -> [Element<SectionIdentifier, Int>] {
        snapshot.sectionIdentifiers.enumerated().map { Element(identifier: $1, index: $0) }
    }

    /// Transforms item identifiers into item/indexPath pairs suitable for calculating difference.
    private func itemElements(
        snapshot: Snapshot, excludedSections: IndexSet = []
    ) -> [Element<ItemIdentifier, IndexPath>] {
        var itemElements: [Element<ItemIdentifier, IndexPath>] = []
        for (section, sectionIdentifier) in snapshot.sectionIdentifiers.enumerated() {
            guard !excludedSections.contains(section) else {
                continue
            }
            let elements = snapshot.itemIdentifiers(inSection: sectionIdentifier).enumerated().map { offset, element in
                let indexPath = IndexPath(row: offset, section: section)
                return Element(identifier: element, index: indexPath)
            }
            itemElements.append(contentsOf: elements)
        }
        return itemElements
    }

    /// Calculates needed updates to apply to collection view to transform initial elements into final.
    private func updates<Identifier: Hashable, Index: Equatable>(
        from initial: [Element<Identifier, Index>],
        to final: [Element<Identifier, Index>],
        reloadedIdentifiers: Set<Identifier>
    ) -> Updates<Index> {
        var finalIndices = [Identifier: Index](minimumCapacity: final.count)
        for element in final {
            finalIndices[element.identifier] = element.index
        }
        var removals: [Index] = []
        var reloads: [Index] = []
        var initialIndices = [Identifier: Index](minimumCapacity: initial.count)
        for element in initial.reversed() {
            if finalIndices.keys.contains(element.identifier) {
                if reloadedIdentifiers.contains(element.identifier) {
                    reloads.append(element.index)
                }
                // Store element index to it can be used later used to deduce move.
                initialIndices[element.identifier] = element.index
            } else {
                removals.append(element.index)
            }
        }
        var moves: [Updates<Index>.Move] = []
        var insertions: [Index] = []
        for element in final {
            if let initialIndex = initialIndices[element.identifier] {
                if initialIndex != element.index {
                    moves.append(Updates<Index>.Move(from: initialIndex, to: element.index))
                }
            } else {
                insertions.append(element.index)
            }
        }
        return Updates(removals: removals, reloads: reloads, insertions: insertions, moves: moves)
    }
}
