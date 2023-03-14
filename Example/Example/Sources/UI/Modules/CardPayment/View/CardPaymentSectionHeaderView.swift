//
//  CardPaymentSectionHeaderView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 14.03.2023.
//

import UIKit

final class CardPaymentSectionHeaderView: UICollectionReusableView {

    typealias ViewRegistration = UICollectionView.SupplementaryRegistration<CardPaymentSectionHeaderView>

    static let registration = ViewRegistration(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in
        // Ignored
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: CardPaymentViewModelState.SectionIdentifier) {
        titleLabel.text = item.title
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }

    // MARK: - Private Properties

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Private Methods

    private func commonInit() {
        addSubview(contentView)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(Constants.contentInsets) }
        contentView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
