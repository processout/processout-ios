//
//  DiffableDataSourceSnapshot.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.04.2023.
//

struct DiffableDataSourceSnapshot<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    private(set) var sectionIdentifiers: [SectionIdentifier] = []

    mutating func appendSections(_ identifiers: [SectionIdentifier]) {
        sectionIdentifiers += identifiers
    }

    mutating func appendItems(_ identifiers: [ItemIdentifier], toSection sectionIdentifier: SectionIdentifier) {
        assert(sectionIdentifiers.contains(sectionIdentifier))
        if let itemIdentifiers = self._itemIdentifiers[sectionIdentifier] {
            self._itemIdentifiers[sectionIdentifier] = itemIdentifiers + identifiers
        } else {
            self._itemIdentifiers[sectionIdentifier] = identifiers
        }
    }

    private(set) var reloadedSectionIdentifiers: Set<SectionIdentifier> = []

    mutating func reloadSections(_ identifiers: [SectionIdentifier]) {
        reloadedSectionIdentifiers.formUnion(identifiers)
    }

    var numberOfSections: Int {
        sectionIdentifiers.count
    }

    func numberOfItems(inSection identifier: SectionIdentifier) -> Int {
        _itemIdentifiers[identifier]?.count ?? 0
    }

    func sectionIdentifier(for index: Int) -> SectionIdentifier? {
        if sectionIdentifiers.indices.contains(index) {
            return sectionIdentifiers[index]
        }
        return nil
    }

    func itemIdentifiers(inSection identifier: SectionIdentifier) -> [ItemIdentifier] {
        _itemIdentifiers[identifier] ?? []
    }

    // MARK: -

    private var _itemIdentifiers: [SectionIdentifier: [ItemIdentifier]] = [:]
}
