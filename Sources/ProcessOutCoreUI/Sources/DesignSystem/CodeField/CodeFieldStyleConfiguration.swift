//
//  CodeFieldStyleConfiguration.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

struct CodeFieldStyleConfiguration {

    typealias Index = String.Index

    /// Code field maximum length
    let length: Int

    /// Text.
    let text: String

    /// Current index.
    let index: Index?

    /// Changes current index.
    func setIndex(_ index: Index?) {
        _setIndex(index)
    }

    init(length: Int, text: String, index: Index?, setIndex: @escaping (Index?) -> Void) {
        self.length = length
        self.text = text
        self.index = index
        self._setIndex = setIndex
    }

    // MARK: - Private Properties

    private let _setIndex: (_ index: Index?) -> Void
}
